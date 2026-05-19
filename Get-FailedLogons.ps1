<#
.SYNOPSIS
    Lists failed logon attempts from the Windows Security event log.

.DESCRIPTION
    Queries Event ID 4625 (failed logon) from the Security log and extracts
    the most useful fields: account name, source workstation/IP, logon type,
    and failure reason. Useful for spotting brute-force attempts and
    misconfigured services.

.PARAMETER LastHours
    How far back to look. Defaults to 24.

.PARAMETER Top
    Limit output to the top N attempts. 0 (default) = no limit.

.PARAMETER ExportPath
    Optional CSV export path.

.EXAMPLE
    PS> .\Get-FailedLogons.ps1 -LastHours 72 |
            Group-Object TargetUserName |
            Sort-Object Count -Descending |
            Select-Object Count, Name -First 10

.NOTES
    Author  : Vikas Joshi
    Requires: Run as Administrator (Security log access).
#>
[CmdletBinding()]
[OutputType([PSCustomObject])]
param (
    [ValidateRange(1, 8760)]
    [int]$LastHours = 24,

    [ValidateRange(0, 100000)]
    [int]$Top = 0,

    [string]$ExportPath
)

$since = (Get-Date).AddHours(-$LastHours)

try {
    $events = Get-WinEvent -FilterHashtable @{
        LogName   = 'Security'
        Id        = 4625
        StartTime = $since
    } -ErrorAction Stop
}
catch [System.Diagnostics.Eventing.Reader.EventLogException] {
    # No matching events is signalled as an EventLogException; treat as empty.
    Write-Verbose "No failed logons in the last $LastHours hour(s)."
    return
}
catch {
    if ($_.FullyQualifiedErrorId -like 'NoMatchingEventsFound*') {
        Write-Verbose "No failed logons in the last $LastHours hour(s)."
        return
    }
    Write-Error "Failed to query Security log: $($_.Exception.Message)"
    return
}

# Map Logon Type codes to friendly names (winnt.h)
$logonTypes = @{
    2  = 'Interactive'
    3  = 'Network'
    4  = 'Batch'
    5  = 'Service'
    7  = 'Unlock'
    8  = 'NetworkCleartext'
    9  = 'NewCredentials'
    10 = 'RemoteInteractive (RDP)'
    11 = 'CachedInteractive'
}

function Format-HexOrNull {
    param ($Value)
    if ($null -eq $Value) { return $null }
    try   { '0x{0:X}' -f [int64]$Value }
    catch { [string]$Value }
}

$result = foreach ($e in $events) {
    # Event 4625 schema (0-indexed Properties array, per Microsoft docs):
    #   5 TargetUserName, 6 TargetDomainName, 7 Status, 9 SubStatus,
    #   10 LogonType, 13 WorkstationName, 19 IpAddress, 20 IpPort.
    $p = $e.Properties

    $logonTypeNum = if ($null -ne $p[10].Value) { [int]$p[10].Value } else { 0 }

    [PSCustomObject]@{
        TimeCreated     = $e.TimeCreated
        TargetUserName  = $p[5].Value
        TargetDomain    = $p[6].Value
        LogonType       = $logonTypeNum
        LogonTypeName   = if ($logonTypes.ContainsKey($logonTypeNum)) { $logonTypes[$logonTypeNum] } else { 'Unknown' }
        FailureStatus   = Format-HexOrNull $p[7].Value
        SubStatus       = Format-HexOrNull $p[9].Value
        WorkstationName = $p[13].Value
        SourceIP        = $p[19].Value
        SourcePort      = $p[20].Value
    }
}

if ($Top -gt 0) {
    $result = $result | Select-Object -First $Top
}

if ($ExportPath) {
    $parent = Split-Path -Parent $ExportPath
    if ($parent -and -not (Test-Path $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }
    $result | Export-Csv -Path $ExportPath -NoTypeInformation
    Write-Verbose "Exported to: $ExportPath"
}

$result
