param(
    [Parameter(Mandatory = $true)]
    [string]$RemoteZipPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Resolve-ProjectPath {
    param(
        [string]$ProjectRoot,
        [string]$ConfiguredPath
    )

    if ([System.IO.Path]::IsPathRooted($ConfiguredPath)) {
        return $ConfiguredPath
    }

    return Join-Path $ProjectRoot $ConfiguredPath
}

$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$configPath = Join-Path $projectRoot "config/config.local.json"
if (-not (Test-Path -LiteralPath $configPath)) {
    throw "Missing config/config.local.json. Copy config/config.example.json and fill in private local values."
}

$config = Get-Content -LiteralPath $configPath -Raw | ConvertFrom-Json
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$localArchiveRoot = Resolve-ProjectPath -ProjectRoot $projectRoot -ConfiguredPath ([string]$config.local_archive_root)
$localCodeRoot = Resolve-ProjectPath -ProjectRoot $projectRoot -ConfiguredPath ([string]$config.local_python_code_archive_root)
$localArchiveDir = Join-Path $localArchiveRoot "run_$timestamp"
$localCodeArchiveDir = Join-Path $localCodeRoot "run_$timestamp"
$downloadPath = Join-Path $localArchiveDir (Split-Path -Leaf $RemoteZipPath)
$sshKeyPath = Resolve-ProjectPath -ProjectRoot $projectRoot -ConfiguredPath ([string]$config.ssh_key_path)
$remoteSpec = "$($config.remote_user)@$($config.remote_host):`"$RemoteZipPath`""

New-Item -ItemType Directory -Force -Path $localArchiveDir | Out-Null
New-Item -ItemType Directory -Force -Path $localCodeArchiveDir | Out-Null

scp -i $sshKeyPath $remoteSpec $downloadPath
Expand-Archive -LiteralPath $downloadPath -DestinationPath $localArchiveDir -Force

Get-ChildItem -LiteralPath $localArchiveDir -Recurse -File -Include "*.py","*.bak" |
    ForEach-Object {
        Copy-Item -LiteralPath $_.FullName -Destination $localCodeArchiveDir -Force
    }

Write-Host "LOCAL_ARCHIVE_DIR=$localArchiveDir"
Write-Host "LOCAL_CODE_ARCHIVE_DIR=$localCodeArchiveDir"
