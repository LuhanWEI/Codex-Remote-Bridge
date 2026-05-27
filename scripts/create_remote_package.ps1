param(
    [Parameter(Mandatory = $true)]
    [string]$RemoteTargetDir,

    [Parameter(Mandatory = $true)]
    [string]$RemoteTransferDir,

    [Parameter(Mandatory = $true)]
    [string]$MainScriptName,

    [string]$OutputDirName = "Output_Figures",

    [string]$PythonCommand = "python",

    [string]$ModificationSummary = "No modification summary provided."
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Copy-IfPresent {
    param(
        [string]$Source,
        [string]$Destination
    )

    if (Test-Path -LiteralPath $Source) {
        Copy-Item -LiteralPath $Source -Destination $Destination -Recurse -Force
        return $true
    }

    return $false
}

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$packageName = "remote_results_$timestamp"
$packageDir = Join-Path $RemoteTransferDir $packageName
$zipPath = Join-Path $RemoteTransferDir "$packageName.zip"
$outputDir = Join-Path $RemoteTargetDir $OutputDirName
$mainScriptPath = Join-Path $RemoteTargetDir $MainScriptName
$backupPath = "$mainScriptPath.bak"

if ($zipPath -match "\s") {
    throw "Remote zip path contains spaces. Use a REMOTE_TRANSFER_DIR without spaces."
}

New-Item -ItemType Directory -Force -Path $RemoteTransferDir | Out-Null
if (Test-Path -LiteralPath $packageDir) {
    Remove-Item -LiteralPath $packageDir -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $packageDir | Out-Null

$copiedOutput = Copy-IfPresent -Source $outputDir -Destination (Join-Path $packageDir $OutputDirName)
if (-not $copiedOutput) {
    New-Item -ItemType Directory -Force -Path (Join-Path $packageDir $OutputDirName) | Out-Null
}

if (-not (Copy-IfPresent -Source $mainScriptPath -Destination $packageDir)) {
    throw "Main script not found: $MainScriptName"
}

$backupFileName = "Not found"
if (Copy-IfPresent -Source $backupPath -Destination $packageDir) {
    $backupFileName = Split-Path -Leaf $backupPath
}

$helperDir = Join-Path $packageDir "helper_py_files"
New-Item -ItemType Directory -Force -Path $helperDir | Out-Null
Get-ChildItem -LiteralPath $RemoteTargetDir -Filter "*.py" -File |
    Where-Object { $_.Name -ne $MainScriptName } |
    ForEach-Object {
        Copy-Item -LiteralPath $_.FullName -Destination $helperDir -Force
    }

$generatedFiles = @()
if (Test-Path -LiteralPath $outputDir) {
    $generatedFiles = Get-ChildItem -LiteralPath $outputDir -Recurse -File |
        ForEach-Object {
            $_.FullName.Substring($outputDir.Length).TrimStart("\", "/")
        }
}

$pythonVersion = & $PythonCommand --version 2>&1
$hostname = hostname
$reportPath = Join-Path $packageDir "run_report.txt"
$report = @(
    "remote_run_report",
    "timestamp: $timestamp",
    "hostname: $hostname",
    "python_version: $pythonVersion",
    "selected_main_script: $MainScriptName",
    "backup_file_name: $backupFileName",
    "modification_summary: $ModificationSummary",
    "generated_output_files:",
    ($generatedFiles | ForEach-Object { "- $_" })
)

Set-Content -LiteralPath $reportPath -Value $report -Encoding UTF8

if (Test-Path -LiteralPath $zipPath) {
    Remove-Item -LiteralPath $zipPath -Force
}

Compress-Archive -Path (Join-Path $packageDir "*") -DestinationPath $zipPath -Force
Write-Host $zipPath
