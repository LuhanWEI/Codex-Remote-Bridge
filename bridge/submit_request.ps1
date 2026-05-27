param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Command,

    [int]$TimeoutSeconds = 300
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$requestPath = Join-Path $projectRoot "bridge/request.txt"
$statusPath = Join-Path $projectRoot "bridge/status.txt"
$outputPath = Join-Path $projectRoot "bridge/output.txt"

Set-Content -LiteralPath $statusPath -Value "READY" -Encoding UTF8
Set-Content -LiteralPath $outputPath -Value "Request submitted." -Encoding UTF8
Set-Content -LiteralPath $requestPath -Value $Command -Encoding UTF8

$deadline = (Get-Date).AddSeconds($TimeoutSeconds)
while ((Get-Date) -lt $deadline) {
    Start-Sleep -Milliseconds 500

    if (-not (Test-Path -LiteralPath $statusPath)) {
        continue
    }

    $status = (Get-Content -LiteralPath $statusPath -Raw).Trim()
    if ($status -eq "DONE" -or $status -eq "ERROR") {
        if (Test-Path -LiteralPath $outputPath) {
            Get-Content -LiteralPath $outputPath -Raw
        }

        if ($status -eq "DONE") {
            exit 0
        }

        exit 1
    }
}

Write-Error "Timed out waiting for bridge status DONE or ERROR."
exit 124
