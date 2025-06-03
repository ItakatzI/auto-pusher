# === CONFIG ===
$projectPath = "C:\Users\itai\Desktop\whitespace-pusher"
$scheduleScript = Join-Path $projectPath "schedule_tasks.ps1"
$bashScript = Join-Path $projectPath "auto_commit.sh"

# Make sure bash script is executable (Git Bash doesn't care, but WSL might)
# This just adds a note for completeness
Write-Host "-Bash script assumed ready at $bashScript"

# Run initial scheduling
Write-Host "--Running schedule_tasks.ps1 to create today’s random schedule..."
powershell -ExecutionPolicy Bypass -File $scheduleScript

# Schedule the PowerShell task to run once daily at 11:00 AM
$dailyTrigger = New-ScheduledTaskTrigger -Daily -At 11:00am
$dailyAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"$scheduleScript`""

Register-ScheduledTask -Action $dailyAction -Trigger $dailyTrigger -TaskName "WhitespacePushDailyScheduler" -Description "Daily re-randomization of whitespace commit tasks" -Force

Write-Host "---Daily re-randomizer task scheduled at 1:00 AM"
