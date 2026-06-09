<#
.SYNOPSIS
    Retrieves all open TCP/UDP ports and their associated processes.
.DESCRIPTION
    Uses netstat and Get-Process to list all listening ports with process names, PIDs, and connection states.
.EXAMPLE
    .\Get-OpenPorts.ps1 -IncludeRemote
.NOTES
    Run as Administrator for complete results.
#>

param(
    [switch]$IncludeRemote,
    [string]$OutputPath = ".\open-ports-report.csv"
)

$ports = Get-NetTCPConnection -ErrorAction SilentlyContinue | \
    Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort, State, \
    @{Name="ProcessName";Expression={(Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).ProcessName}}, \
    @{Name="PID";Expression={$_.OwningProcess}}

if ($IncludeRemote) {
    $ports | Sort-Object LocalPort | Format-Table -AutoSize
} else {
    $localPorts = $ports | Where-Object { $_.RemoteAddress -eq $null -or $_.RemoteAddress -eq "" } | \
        Select-Object ProcessName, LocalPort, State, PID
    $localPorts | Sort-Object LocalPort | Format-Table -AutoSize
}

$ports | Export-Csv -Path $OutputPath -NoTypeInformation
Write-Host "Report saved to: $OutputPath" -ForegroundColor Green
