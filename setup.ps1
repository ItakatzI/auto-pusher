# setup.ps1

# --- Load .env file ---
function Load-EnvFile {
    $envPath = Join-Path $PSScriptRoot ".env"
    if (Test-Path $envPath) {
        Get-Content $envPath | ForEach-Object {
            if ($_ -match '^\s*([^#][^=]*)\s*=\s*(.*)\s*$') {
                [System.Environment]::SetEnvironmentVariable($matches[1].Trim(), $matches[2].Trim())
            }
        }
    } else {
        Write-Error "[✘] .env file not found at $envPath"
        exit 1
    }
}

Load-EnvFile

# --- Get paths from .env ---
$projectPath = $env:REPO_DIR2
if (-not $projectPath) {
    Write-Error "[X] REPO_DIR2 not defined in .env"
    exit 1
}

$scheduleScript = Join-Path $projectPath "schedule_tasks.ps1"
$bashScript = Join-Path $projectPath "auto_commit.sh"

if (-not (Test-Path $scheduleScript)) {
    Write-Error "[X] schedule_tasks.ps1 not found at $scheduleScript"
    exit 1
}

if (-not (Test-Path $bashScript)) {
    Write-Error "[X] auto_commit.sh not found at $bashScript"
    exit 1
}

# --- Inform user ---
Write-Host "[V] Loaded environment variables from .env"
Write-Host "  > Project path: $projectPath"
Write-Host "  > Bash script:  $bashScript"
Write-Host ""

# --- Run today's schedule creation ---
Write-Host "[→] Running schedule_tasks.ps1 to create today’s random push tasks..."
powershell.exe -ExecutionPolicy Bypass -File "`"$scheduleScript`""

# --- Schedule the daily randomization task ---
Write-Host "[→] Scheduling 'WhitespacePushDailyScheduler' at 11:00 AM..."

$dailyTrigger = New-ScheduledTaskTrigger -Daily -At 11:00am
$dailyAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"$scheduleScript`""

Register-ScheduledTask -Action $dailyAction -Trigger $dailyTrigger -TaskName "WhitespacePushDailyScheduler" -Description "Daily re-randomization of motivational commit tasks" -Force

Write-Host "[V] Scheduled task 'WhitespacePushDailyScheduler' successfully"
