Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$configPath = Join-Path $projectRoot "config/config.local.json"
if (-not (Test-Path -LiteralPath $configPath)) {
    throw "Missing config/config.local.json. Copy config/config.example.json and fill in private local values."
}

$config = Get-Content -LiteralPath $configPath -Raw | ConvertFrom-Json
$sshKeyPath = Join-Path $projectRoot ([string]$config.ssh_key_path)
$remote = "$($config.remote_user)@$($config.remote_host)"
$remotePython = [string]$config.remote_python_command
$targetDir = [string]$config.remote_target_dir

$remoteCommand = @"
hostname
$remotePython --version
powershell -NoProfile -Command "Set-Location -LiteralPath '$targetDir'; Write-Host CURRENT_REMOTE_WORKING_DIRECTORY=(Get-Location).Path; Get-ChildItem -LiteralPath . -Filter '*.py' -File | Select-Object -ExpandProperty Name"
"@

$escapedRemoteCommand = $remoteCommand.Replace('"', '\"').Replace("`r", "").Replace("`n", "; ")
$bridgeCommand = "ssh -i `"$sshKeyPath`" $remote `"$escapedRemoteCommand`""

& (Join-Path $projectRoot "bridge/submit_request.ps1") -Command $bridgeCommand -TimeoutSeconds 120
