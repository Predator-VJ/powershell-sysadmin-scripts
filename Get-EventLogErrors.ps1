<#
.SYNOPSIS
    Returns recent Critical and Error events from a Windows event log.

.DESCRIPTION
    Uses Get-WinEvent with a filter hashtable for performant queries against
    large logs. Emits objects so callers can pipe to Where-Object,
    Group-Object, Export-Csv, etc.

.PARAMETER LogName
    Event log to query. Defaults to 'System'.

.PARAMETER LastHours
    How far back to look, in hours. Defaults to 24.

.PARAMETER ExportPath
    If provided, writes the result as CSV to this path.

.EXAMPLE
    PS> .\Get-EventLogErrors.ps1 -LogName Application -LastHours 48

.EXAMPLE
    PS> .\Get-EventLogErrors.ps1 | Group-Object Id | Sort-Object Count -Descending

.NOTES
    Author  : Vikas Joshi
    Requires: Run as Administrator for the Security log.
#>
[CmdletBinding()]
[OutputType([PSCustomObject])]
param (
    [ValidateRange(1, 8760)]
    [int]$LastHours = 24,

    [string]$LogName = 'System',

    [string]$ExportPath
)

$since = (Get-Date).AddHours(-$LastHours)
Write-Verbose "Querying log '$LogName' since $since"

try {
    $events = Get-WinEvent -FilterHashtable @{
        LogName   = $LogName
        Level     = 1, 2   # 1=Critical, 2=Error
        StartTime = $since
    } -ErrorAction Stop
}
catch [System.Diagnostics.Eventing.Reader.EventLogException] {
    Write-Verbose "No matching events found in '$LogName' for the last $LastHours hour(s)."
    return
}
catch {
    # NoMatchingEventsFound is reported with this FullyQualifiedErrorId
    # regardless of system locale.
    if ($_.FullyQualifiedErrorId -like 'NoMatchingEventsFound*') {
        Write-Verbose "No matching events found in '$LogName' for the last $LastHours hour(s)."
        return
    }
    Write-Error "Failed to query event log '$LogName': $($_.Exception.Message)"
    return
}

$result = $events | Select-Object TimeCreated,
    Id,
    LevelDisplayName,
    ProviderName,
    @{N = 'Message'; E = { $_.Message -replace '\s+', ' ' }}

if ($ExportPath) {
    $parent = Split-Path -Parent $ExportPath
    if ($parent -and -not (Test-Path $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }
    $result | Export-Csv -Path $ExportPath -NoTypeInformation
    Write-Verbose "Exported to: $ExportPath"
}

$result
