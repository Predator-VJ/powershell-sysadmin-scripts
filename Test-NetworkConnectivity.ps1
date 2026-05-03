# Test-NetworkConnectivity.ps1
# Pings a list of hosts and reports their connectivity status
# Customize $hosts list as needed

param (
    [string[]]$Hosts = @('8.8.8.8','1.1.1.1','google.com','github.com'),
    [int]$Count = 2
)

Write-Host "===== Network Connectivity Test =====" -ForegroundColor Cyan
Write-Host "Tested at: $(Get-Date)" -ForegroundColor Gray
Write-Host ""

$results = foreach ($h in $Hosts) {
    $ping = Test-Connection -ComputerName $h -Count $Count -ErrorAction SilentlyContinue
    $status = if ($ping) { 'REACHABLE' } else { 'UNREACHABLE' }
    $avg    = if ($ping) { [math]::Round(($ping | Measure-Object ResponseTime -Average).Average, 2) } else { 'N/A' }
    [PSCustomObject]@{
        Host          = $h
        Status        = $status
        AvgLatency_ms = $avg
    }
}

$results | Format-Table -AutoSize
