Add-Content -Path "$env:USERPROFILE\push_scheduler_log.txt" -Value "[$(Get-Date)] schedule_tasks.ps1 executed"

# === CONFIG ===
$scriptPath = "C:\Users\itai\Desktop\whitespace-pusher\auto_commit.sh"  # UPDATE IF NEEDED
$numTasks = Get-Random -Minimum 0 -Maximum 6  # Schedule 3 to 5 times

# Remove old scheduled tasks (optional cleanup)
Get-ScheduledTask | Where-Object { $_.TaskName -like "WhitespacePush*" } | Unregister-ScheduledTask -Confirm:$false

for ($i = 0; $i -lt $numTasks; $i++) {
    $hour = Get-Random -Minimum 11 -Maximum 17
    $minute = Get-Random -Minimum 0 -Maximum 59
    $time = "{0:D2}:{1:D2}" -f $hour, $minute
    $taskName = "WhitespacePush_$i"

    $action = New-ScheduledTaskAction -Execute "C:\Program Files\Git\bin\bash.exe" -Argument "`"$scriptPath`""
    $trigger = New-ScheduledTaskTrigger -Daily -At $time

    Register-ScheduledTask -Action $action -Trigger $trigger -TaskName $taskName -Description "Random whitespace push" -Force
}

Write-Output "$numTasks push tasks scheduled at random times today."

