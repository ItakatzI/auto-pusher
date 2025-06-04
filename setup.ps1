# setup.ps1

# --- Load .env file ---
function Load-EnvFile {
    $envPath = "$PSScriptRoot\.env"
    if (Test-Path $envPath) {
        Get-Content $envPath | ForEach-Object {
            if ($_ -match '^\s*([^#][^=]+)\s*=\s*(.*)\s*$') {
                [System.Environment]::SetEnvironmentVariable($matches[1].Trim(), $matches[2].Trim())
            }
        }
    } else {
        Write-Error ".env file not found at $envPath"
        exit 1
    }
}

Load-EnvFile

# --- Get paths from env ---
$projectPath = $env:REPO_DIR
$scheduleScript = Join-Path $projectPath "schedule_tasks.ps1"
$bashScript = Join-Path $projectPath "auto_commit.sh"

# --- Inform user ---
Write-Host "V Loaded environment variables from .env"
Write-Host "> Project path: $projectPath"
Write-Host "> Bash script:  $bashScript"

# --- Run schedule_tasks.ps1 to create today's schedule ---
Write-Host "-- Running schedule_tasks.ps1 to create today’s random push tasks..."
powershell -ExecutionPolicy Bypass -File $scheduleScript

# --- Schedule schedule_tasks.ps1 to run daily at 11:00 AM ---
$dailyTrigger = New-ScheduledTaskTrigger -Daily -At 11:00am
$dailyAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"$scheduleScript`""

Register-ScheduledTask -Action $dailyAction -Trigger $dailyTrigger -TaskName "WhitespacePushDailyScheduler" -Description "Daily re-randomization of whitespace commit tasks" -Force

Write-Host "--- V Daily task 'WhitespacePushDailyScheduler' scheduled at 11:00 AM"
