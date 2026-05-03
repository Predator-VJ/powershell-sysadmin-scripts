# Get-SystemHealth.ps1
# Displays CPU, RAM, and Disk usage summary
# Run as Administrator

Write-Host "===== System Health Report ====" -ForegroundColor Cyan
Write-Host "Date: $(Get-Date)" -ForegroundColor Gray
Write-Host ""

# CPU Usage
$cpu = Get-WmiObject Win32_Processor | Measure-Object -Property LoadPercentage -Average
Write-Host "CPU Usage       : $([math]::Round($cpu.Average, 2)) %" -ForegroundColor Yellow

# RAM Usage
$os = Get-WmiObject Win32_OperatingSystem
$totalRAM = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
$freeRAM  = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
$usedRAM  = [math]::Round($totalRAM - $freeRAM, 2)
$ramPct   = [math]::Round(($usedRAM / $totalRAM) * 100, 2)
Write-Host "RAM Total       : $totalRAM GB" -ForegroundColor Green
Write-Host "RAM Used        : $usedRAM GB ($ramPct %)" -ForegroundColor Green
Write-Host "RAM Free        : $freeRAM GB" -ForegroundColor Green
Write-Host ""

# Disk Usage
Write-Host "--- Disk Usage ---" -ForegroundColor Cyan
Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Used -ne $null } | ForEach-Object {
    $total = [math]::Round(($_.Used + $_.Free) / 1GB, 2)
    $used  = [math]::Round($_.Used / 1GB, 2)
    $free  = [math]::Round($_.Free / 1GB, 2)
    $pct   = if ($total -gt 0) { [math]::Round(($used / $total) * 100, 2) } else { 0 }
    Write-Host "Drive $($_.Name): Total=$total GB | Used=$used GB | Free=$free GB | Usage=$pct%"
}
