<#
.SYNOPSIS
    Lists listening TCP ports and the processes that own them.

.DESCRIPTION
    Joins the output of Get-NetTCPConnection (state=Listen) with
    Get-Process to produce a table of port -> process. Useful for
    diagnosing port conflicts and unexpected listeners.

.PARAMETER LocalPort
    Filter to one or more specific ports.

.PARAMETER IncludeIPv6
    Include IPv6 listeners. By default only IPv4 is shown.

.EXAMPLE
    PS> .\Get-OpenPorts.ps1 | Sort-Object LocalPort

.EXAMPLE
    PS> .\Get-OpenPorts.ps1 -LocalPort 80, 443, 3389

.NOTES
    Author  : Vikas Joshi
    Requires: PowerShell 5.1+ or 7+. Process owner requires Administrator.
#>
[CmdletBinding()]
[OutputType([PSCustomObject])]
param (
    [int[]]$LocalPort,
    [switch]$IncludeIPv6
)

$conns = Get-NetTCPConnection -State Listen -ErrorAction Stop

if (-not $IncludeIPv6) {
    $conns = $conns | Where-Object { $_.LocalAddress -notmatch ':' }
}

if ($LocalPort) {
    $conns = $conns | Where-Object { $LocalPort -contains $_.LocalPort }
}

# Cache process lookup for performance
$processCache = @{}

foreach ($c in $conns) {
    if (-not $processCache.ContainsKey($c.OwningProcess)) {
        $processCache[$c.OwningProcess] =
            Get-Process -Id $c.OwningProcess -ErrorAction SilentlyContinue
    }
    $proc = $processCache[$c.OwningProcess]

    [PSCustomObject]@{
        LocalAddress = $c.LocalAddress
        LocalPort    = $c.LocalPort
        State        = $c.State
        ProcessId    = $c.OwningProcess
        ProcessName  = if ($proc) { $proc.ProcessName } else { 'unknown' }
        ProcessPath  = if ($proc) { $proc.Path }        else { $null }
    }
}
