# Get-EventLogErrors.ps1
# Fetches recent Error and Critical events from Windows Event Logs
# Run as Administrator

param (
    [int]$LastHours = 24,
    [string]$LogName = 'System',
    [string]$ExportPath = "C:\Temp\EventErrors_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
)

$since = (Get-Date).AddHours(-$LastHours)
Write-Host "===== Event Log Errors (Last $LastHours hrs) =====" -ForegroundColor Cyan
Write-Host "Log: $LogName | Since: $since" -ForegroundColor Gray
Write-Host ""

$events = Get-WinEvent -FilterHashtable @{
    LogName   = $LogName
    Level     = 1,2   # 1=Critical, 2=Error
    StartTime = $since
} -ErrorAction SilentlyContinue

if ($events) {
    $events | Select-Object TimeCreated, Id, LevelDisplayName, Message |
        Format-Table -AutoSize -Wrap
    $events | Select-Object TimeCreated, Id, LevelDisplayName, Message |
        Export-Csv -Path $ExportPath -NoTypeInformation
    Write-Host "Exported to: $ExportPath" -ForegroundColor Green
} else {
    Write-Host "No errors found in the last $LastHours hours." -ForegroundColor Green
}
