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

$projectRoot = Get-ProjectRoot
$config = Read-BridgeConfig -ProjectRoot $projectRoot
$taskName = [string]$config.task_scheduler_name
$workerPath = Join-Path $projectRoot "bridge/bridge_worker.ps1"
$currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name

if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) {
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
    Write-Host "Removed existing scheduled task: $taskName"
}

$actionArgs = "-NoExit -NoProfile -ExecutionPolicy Bypass -File `"$workerPath`""
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument $actionArgs -WorkingDirectory $projectRoot
$trigger = New-ScheduledTaskTrigger -AtLogOn -User $currentUser
$principal = New-ScheduledTaskPrincipal -UserId $currentUser -LogonType Interactive -RunLevel Limited
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DisallowStartIfOnBatteries:$false -MultipleInstances IgnoreNew

Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal -Settings $settings | Out-Null
Start-ScheduledTask -TaskName $taskName

Write-Host "BRIDGE_TASK_REGISTERED"
Write-Host "Task name: $taskName"
Write-Host "Worker script: $workerPath"
Write-Host "The bridge worker should open in a visible PowerShell window."
