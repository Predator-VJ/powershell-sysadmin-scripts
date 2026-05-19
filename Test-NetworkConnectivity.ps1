<#
.SYNOPSIS
    Tests reachability of one or more hosts via ICMP ping.

.DESCRIPTION
    Sends ICMP echo requests to each target host and emits a PSCustomObject
    per host with reachability status and average round-trip time.

.PARAMETER ComputerName
    One or more hostnames or IP addresses to test. Defaults to a small set
    of public DNS / well-known hosts.

.PARAMETER Count
    Number of pings per host. Defaults to 2.

.EXAMPLE
    PS> .\Test-NetworkConnectivity.ps1

.EXAMPLE
    PS> .\Test-NetworkConnectivity.ps1 -ComputerName 'fileserver','db01' -Count 4

.NOTES
    Author  : Vikas Joshi
    Requires: PowerShell 5.1+ or 7+. ICMP must be allowed by the firewall.
#>
[CmdletBinding()]
[OutputType([PSCustomObject])]
param (
    [Alias('Hosts')]
    [string[]]$ComputerName = @('8.8.8.8', '1.1.1.1', 'google.com', 'github.com'),

    [ValidateRange(1, 100)]
    [int]$Count = 2
)

foreach ($target in $ComputerName) {
    $ping = $null
    try {
        $ping = Test-Connection -ComputerName $target -Count $Count -ErrorAction Stop
    }
    catch {
        Write-Verbose "Ping failed for $target : $($_.Exception.Message)"
    }

    $reachable = [bool]$ping
    $avgMs     = if ($reachable) {
        # PowerShell 7+ returns Latency, PS5.1 returns ResponseTime
        $latencyProp = if ($ping[0].PSObject.Properties.Name -contains 'Latency') { 'Latency' } else { 'ResponseTime' }
        [math]::Round(($ping | Measure-Object -Property $latencyProp -Average).Average, 2)
    } else {
        $null
    }

    [PSCustomObject]@{
        Target       = $target
        Reachable    = $reachable
        AvgLatencyMs = $avgMs
        PingCount    = $Count
        TestedAt     = Get-Date
    }
}
