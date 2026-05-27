Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$runtimeFiles = @(
    "request.txt",
    "status.txt",
    "output.txt",
    "pid.txt",
    "heartbeat.txt"
)

foreach ($fileName in $runtimeFiles) {
    $path = Join-Path $PSScriptRoot $fileName
    if (Test-Path -LiteralPath $path) {
        Remove-Item -LiteralPath $path -Force
        Write-Host "Removed $fileName"
    }
}

Write-Host "Bridge runtime files cleaned."
