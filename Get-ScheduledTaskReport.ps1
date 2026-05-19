<#
.SYNOPSIS
    Reports on configured scheduled tasks, last run results, and next run times.

.DESCRIPTION
    Combines Get-ScheduledTask with Get-ScheduledTaskInfo to produce a
    single normalized object per task, including the last run result code
    and a human-readable interpretation.

.PARAMETER TaskPath
    Filter on a task path prefix (e.g., '\Microsoft\Windows\'). Default is
    '\' (all tasks).

.PARAMETER FailedOnly
    Return only tasks whose LastTaskResult indicates failure (non-zero,
    non-running).

.EXAMPLE
    PS> .\Get-ScheduledTaskReport.ps1 -FailedOnly

.EXAMPLE
    PS> .\Get-ScheduledTaskReport.ps1 -TaskPath '\' |
            Where-Object State -eq 'Ready' |
            Sort-Object NextRunTime

.NOTES
    Author  : Vikas Joshi
    Requires: PowerShell 5.1+ or 7+. ScheduledTasks module (Windows built-in).
#>
[CmdletBinding()]
[OutputType([PSCustomObject])]
param (
    [string]$TaskPath = '\',
    [switch]$FailedOnly
)

$tasks = Get-ScheduledTask -TaskPath "$TaskPath*" -ErrorAction SilentlyContinue

foreach ($task in $tasks) {
    $info = $null
    try {
        $info = $task | Get-ScheduledTaskInfo -ErrorAction Stop
    }
    catch {
        Write-Verbose "Cannot get info for $($task.TaskName): $($_.Exception.Message)"
    }

    $lastResult = if ($info) { $info.LastTaskResult } else { $null }

    # Common result codes:
    #   0           = Success
    #   267009      = Currently running
    #   267011      = Has not yet run
    #   2147750687  = Disabled
    $resultText = switch ($lastResult) {
        $null       { 'NoInfo' }
        0           { 'Success' }
        267009      { 'Running' }
        267011      { 'NotYetRun' }
        2147750687  { 'Disabled' }
        default     { ('0x{0:X}' -f [int64]$lastResult) }
    }

    if ($FailedOnly -and $resultText -in 'Success', 'Running', 'NotYetRun', 'Disabled', 'NoInfo') {
        continue
    }

    [PSCustomObject]@{
        TaskName      = $task.TaskName
        TaskPath      = $task.TaskPath
        State         = $task.State
        Author        = $task.Author
        LastRunTime   = if ($info) { $info.LastRunTime }   else { $null }
        NextRunTime   = if ($info) { $info.NextRunTime }   else { $null }
        LastResult    = $lastResult
        LastResultMsg = $resultText
        NumberOfMissedRuns = if ($info) { $info.NumberOfMissedRuns } else { $null }
    }
}
