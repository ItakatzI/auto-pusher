# schedule_tasks.ps1

# --- Log execution ---
Add-Content -Path "$env:USERPROFILE\push_scheduler_log.txt" -Value "[$(Get-Date)] schedule_tasks.ps1 executed"

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

# --- Get paths from .env ---
$scriptPath = Join-Path $env:REPO_DIR "auto_commit.sh"

# --- Config ---
$numTasks = Get-Random -Minimum 3 -Maximum 6  # Schedule 3 to 5 tasks

# --- Clean up previous tasks ---
Get-ScheduledTask | Where-Object { $_.TaskName -like "WhitespacePush_*" } | Unregister-ScheduledTask -Confirm:$false

# --- Create new scheduled tasks ---
for ($i = 0; $i -lt $numTasks; $i++) {
    $hour = Get-Random -Minimum 11 -Maximum 17
    $minute = Get-Random -Minimum 0 -Maximum 59
    $time = "{0:D2}:{1:D2}" -f $hour, $minute
    $taskName = "WhitespacePush_$i"

    $action = New-ScheduledTaskAction -Execute "C:\Program Files\Git\bin\bash.exe" -Argument "`"$scriptPath`""
    $trigger = New-ScheduledTaskTrigger -Daily -At $time

    Register-ScheduledTask -Action $action -Trigger $trigger -TaskName $taskName -Description "Random whitespace push" -Force
}

Write-Output "[V] $numTasks push tasks scheduled at random times today."
