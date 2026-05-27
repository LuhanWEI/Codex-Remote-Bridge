Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-ProjectRoot {
    return (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
}

function Read-BridgeConfig {
    param([string]$ProjectRoot)

    $configPath = Join-Path $ProjectRoot "config/config.local.json"
    if (-not (Test-Path -LiteralPath $configPath)) {
        throw "Missing config/config.local.json. Copy config/config.example.json and fill in private local values."
    }

    return Get-Content -LiteralPath $configPath -Raw | ConvertFrom-Json
}

function Test-ProcessAlive {
    param([string]$PidPath)

    if (-not (Test-Path -LiteralPath $PidPath)) {
        return $false
    }

    $rawPid = (Get-Content -LiteralPath $PidPath -Raw).Trim()
    if (-not ($rawPid -match "^\d+$")) {
        return $false
    }

    return [bool](Get-Process -Id ([int]$rawPid) -ErrorAction SilentlyContinue)
}

function Write-TextFile {
    param(
        [string]$Path,
        [string]$Value
    )

    Set-Content -LiteralPath $Path -Value $Value -Encoding UTF8
}

function Invoke-BridgeRequest {
    param(
        [string]$Request,
        [string]$ProjectRoot
    )

    $outputBuilder = [System.Text.StringBuilder]::new()
    $errorBuilder = [System.Text.StringBuilder]::new()

    $process = [System.Diagnostics.Process]::new()
    $encodedRequest = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($Request))
    $process.StartInfo.FileName = "powershell.exe"
    $process.StartInfo.WorkingDirectory = $ProjectRoot
    $process.StartInfo.Arguments = "-NoProfile -ExecutionPolicy Bypass -EncodedCommand $encodedRequest"
    $process.StartInfo.UseShellExecute = $false
    $process.StartInfo.RedirectStandardOutput = $true
    $process.StartInfo.RedirectStandardError = $true

    [void]$process.Start()
    $stdout = $process.StandardOutput.ReadToEnd()
    $stderr = $process.StandardError.ReadToEnd()
    $process.WaitForExit()

    [void]$outputBuilder.AppendLine("COMMAND:")
    [void]$outputBuilder.AppendLine($Request)
    [void]$outputBuilder.AppendLine("")
    [void]$outputBuilder.AppendLine("STDOUT:")
    [void]$outputBuilder.AppendLine($stdout.TrimEnd())
    [void]$outputBuilder.AppendLine("")
    [void]$outputBuilder.AppendLine("STDERR:")
    [void]$errorBuilder.AppendLine($stderr.TrimEnd())
    [void]$outputBuilder.AppendLine($errorBuilder.ToString().TrimEnd())
    [void]$outputBuilder.AppendLine("")
    [void]$outputBuilder.AppendLine("EXIT_CODE:")
    [void]$outputBuilder.AppendLine([string]$process.ExitCode)

    return [pscustomobject]@{
        ExitCode = $process.ExitCode
        Output = $outputBuilder.ToString()
    }
}

$projectRoot = Get-ProjectRoot
$config = Read-BridgeConfig -ProjectRoot $projectRoot
$bridgeDir = Join-Path $projectRoot "bridge"
$requestPath = Join-Path $bridgeDir "request.txt"
$statusPath = Join-Path $bridgeDir "status.txt"
$outputPath = Join-Path $bridgeDir "output.txt"
$pidPath = Join-Path $bridgeDir "pid.txt"
$heartbeatPath = Join-Path $bridgeDir "heartbeat.txt"

New-Item -ItemType Directory -Force -Path $bridgeDir | Out-Null

if (Test-ProcessAlive -PidPath $pidPath) {
    Write-Host "A bridge worker is already running."
    exit 0
}

Write-TextFile -Path $pidPath -Value ([string]$PID)
Write-TextFile -Path $statusPath -Value "READY"
Write-TextFile -Path $outputPath -Value "Bridge worker ready."
Write-TextFile -Path $heartbeatPath -Value (Get-Date -Format "o")

$lastRequestWriteTimeUtc = [datetime]::MinValue
if (Test-Path -LiteralPath $requestPath) {
    $lastRequestWriteTimeUtc = (Get-Item -LiteralPath $requestPath).LastWriteTimeUtc
}

Write-Host "Bridge worker started for project: $($config.project_name)"
Write-Host "Project root: $projectRoot"
Write-Host "Close this window to stop the bridge worker."

while ($true) {
    try {
        Write-TextFile -Path $heartbeatPath -Value (Get-Date -Format "o")

        if (-not (Test-Path -LiteralPath $requestPath)) {
            Start-Sleep -Seconds 1
            continue
        }

        $requestItem = Get-Item -LiteralPath $requestPath
        if ($requestItem.LastWriteTimeUtc -le $lastRequestWriteTimeUtc) {
            Start-Sleep -Seconds 1
            continue
        }

        $request = (Get-Content -LiteralPath $requestPath -Raw).Trim()
        if ([string]::IsNullOrWhiteSpace($request)) {
            $lastRequestWriteTimeUtc = $requestItem.LastWriteTimeUtc
            Start-Sleep -Seconds 1
            continue
        }

        $lastRequestWriteTimeUtc = $requestItem.LastWriteTimeUtc
        Write-TextFile -Path $statusPath -Value "RUNNING"
        Write-TextFile -Path $outputPath -Value "Running request."

        $result = Invoke-BridgeRequest -Request $request -ProjectRoot $projectRoot
        Write-TextFile -Path $outputPath -Value $result.Output

        if ($result.ExitCode -eq 0) {
            Write-TextFile -Path $statusPath -Value "DONE"
        } else {
            Write-TextFile -Path $statusPath -Value "ERROR"
        }
    } catch {
        $message = "BRIDGE_WORKER_ERROR:`n$($_.Exception.Message)`n$($_.ScriptStackTrace)"
        Write-TextFile -Path $outputPath -Value $message
        Write-TextFile -Path $statusPath -Value "ERROR"
        Start-Sleep -Seconds 2
    }
}
