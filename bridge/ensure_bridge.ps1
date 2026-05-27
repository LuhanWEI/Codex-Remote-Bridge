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

function Test-BridgeAlive {
    param(
        [string]$PidPath,
        [string]$HeartbeatPath
    )

    if (-not (Test-Path -LiteralPath $PidPath)) {
        return $false
    }

    $rawPid = (Get-Content -LiteralPath $PidPath -Raw).Trim()
    if (-not ($rawPid -match "^\d+$")) {
        return $false
    }

    $process = Get-Process -Id ([int]$rawPid) -ErrorAction SilentlyContinue
    if (-not $process) {
        return $false
    }

    if (-not (Test-Path -LiteralPath $HeartbeatPath)) {
        return $false
    }

    try {
        $heartbeatRaw = (Get-Content -LiteralPath $HeartbeatPath -Raw).Trim()
        $heartbeat = [datetime]::Parse($heartbeatRaw, $null, [Globalization.DateTimeStyles]::RoundtripKind)
        return ((Get-Date) - $heartbeat).TotalSeconds -lt 30
    } catch {
        return $false
    }
}

$projectRoot = Get-ProjectRoot
$config = Read-BridgeConfig -ProjectRoot $projectRoot
$pidPath = Join-Path $projectRoot "bridge/pid.txt"
$heartbeatPath = Join-Path $projectRoot "bridge/heartbeat.txt"
$taskName = [string]$config.task_scheduler_name

if (Test-BridgeAlive -PidPath $pidPath -HeartbeatPath $heartbeatPath) {
    Write-Host "BRIDGE_OK"
    exit 0
}

$task = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
if (-not $task) {
    Write-Host "BRIDGE_TASK_NOT_FOUND"
    Write-Host "Run bridge/register_bridge_task.ps1 once from the local project root."
    exit 2
}

Start-ScheduledTask -TaskName $taskName

$deadline = (Get-Date).AddSeconds(10)
while ((Get-Date) -lt $deadline) {
    Start-Sleep -Milliseconds 500
    if (Test-BridgeAlive -PidPath $pidPath -HeartbeatPath $heartbeatPath) {
        Write-Host "BRIDGE_STARTED"
        exit 0
    }
}

Write-Host "BRIDGE_START_TIMEOUT"
exit 1
