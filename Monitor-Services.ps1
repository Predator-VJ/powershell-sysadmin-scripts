# Monitor-Services.ps1
# Checks status of critical services and restarts stopped ones
# Run as Administrator

# Define your critical services here
$criticalServices = @(
    'wuauserv',    # Windows Update
    'Spooler',     # Print Spooler
    'W32Time',     # Windows Time
    'Dnscache',    # DNS Client
    'LanmanServer' # Server (File Sharing)
)

Write-Host "===== Critical Services Monitor =====" -ForegroundColor Cyan
Write-Host "Checked at: $(Get-Date)" -ForegroundColor Gray
Write-Host ""

foreach ($svc in $criticalServices) {
    $service = Get-Service -Name $svc -ErrorAction SilentlyContinue
    if ($null -eq $service) {
        Write-Host "[NOT FOUND] $svc" -ForegroundColor DarkGray
        continue
    }
    if ($service.Status -ne 'Running') {
        Write-Host "[STOPPED] $svc — Attempting restart..." -ForegroundColor Red
        try {
            Start-Service -Name $svc -ErrorAction Stop
            Write-Host "[RESTARTED] $svc" -ForegroundColor Green
        } catch {
            Write-Host "[FAILED] Could not restart $svc : $_" -ForegroundColor Magenta
        }
    } else {
        Write-Host "[RUNNING] $svc" -ForegroundColor Green
    }
}
