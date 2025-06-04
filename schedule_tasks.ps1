# === schedule_tasks.ps1 ===

# --- Log execution ---
Add-Content -Path "$env:USERPROFILE\push_scheduler_log.txt" -Value "[$(Get-Date)] schedule_tasks.ps1 executed"

# --- Load .env ---
$envPath = "$PSScriptRoot\.env"
if (!(Test-Path $envPath)) {
    Write-Error ".env file not found at $envPath"
    exit 1
}

Get-Content $envPath | ForEach-Object {
    if ($_ -match '^\s*([^#][^=]+?)\s*=\s*(.+)$') {
        [System.Environment]::SetEnvironmentVariable($matches[1].Trim(), $matches[2].Trim())
    }
}

# --- Validate REPO_DIR ---
$repoDir = $env:REPO_DIR2
if (-not $repoDir) {
    Write-Error "REPO_DIR not defined in .env"
    exit 1
}
# Convert /c/... style to Windows path if needed
$windowsRepoDir = $repoDir 
# Path to script
$scriptPath = Join-Path $windowsRepoDir "auto_commit.sh"
if (-not (Test-Path $scriptPath)) {
    Write-Error "auto_commit.sh not found at $scriptPath"
    exit 1
}




# --- Git Bash path ---
$bashPath = "C:\Program Files\Git\bin\bash.exe"
if (-not (Test-Path $bashPath)) {
    Write-Error "Git Bash not found at $bashPath"
    exit 1
}



# --- Cleanup old tasks ---
Get-ScheduledTask | Where-Object { $_.TaskName -like "WhitespacePush_*" } | Unregister-ScheduledTask -Confirm:$false



$logFile = "$env:USERPROFILE\auto_commit_output.log"

# --- Schedule new tasks ---
$numTasks = Get-Random -Minimum 0 -Maximum 6
$logFile = "$env:TEMP\push_log.txt"

for ($i = 0; $i -lt $numTasks; $i++) {
    $hour = Get-Random -Minimum 11 -Maximum 17
    $minute = Get-Random -Minimum 0 -Maximum 59
    $time = "{0:D2}:{1:D2}" -f $hour, $minute
    $taskName = "WhitespacePush_$i"

    # Properly escaped Bash command
    $bashCommand = "-c `"cd '$repoDir' && bash ./auto_commit.sh | tee -a '$logFile'`""

    $action = New-ScheduledTaskAction -Execute $bashPath -Argument $bashCommand
    $trigger = New-ScheduledTaskTrigger -Daily -At $time

    Register-ScheduledTask -Action $action -Trigger $trigger -TaskName $taskName -Description "Random motivational push" -Force

    Write-Output "[V] Task $taskName scheduled at $time"
}

Write-Output "[V] $numTasks task(s) scheduled. Logs go to $logFile"
