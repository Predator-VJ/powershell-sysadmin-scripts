# Get-DiskReport.ps1
# Generates a disk space report and optionally exports to CSV
# Run as Administrator

param (
    [string]$ExportPath = "C:\Temp\DiskReport_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
)

Write-Host "===== Disk Space Report =====" -ForegroundColor Cyan

$report = Get-WmiObject Win32_LogicalDisk -Filter "DriveType=3" | Select-Object @(
    @{Name='Drive';     Expression={$_.DeviceID}},
    @{Name='Total(GB)'; Expression={[math]::Round($_.Size/1GB,2)}},
    @{Name='Free(GB)';  Expression={[math]::Round($_.FreeSpace/1GB,2)}},
    @{Name='Used(GB)';  Expression={[math]::Round(($_.Size - $_.FreeSpace)/1GB,2)}},
    @{Name='Use%';      Expression={[math]::Round((($_.Size - $_.FreeSpace)/$_.Size)*100,2)}}
)

$report | Format-Table -AutoSize

# Export to CSV
$report | Export-Csv -Path $ExportPath -NoTypeInformation
Write-Host "Report exported to: $ExportPath" -ForegroundColor Green
