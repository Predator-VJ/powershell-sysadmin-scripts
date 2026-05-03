# Get-WindowsUpdateStatus.ps1
# Checks Windows Update status, pending updates, and last installation date
# Run as Administrator

param (
    [switch]$InstallAvailable
)

Write-Host "===== Windows Update Status =====" -ForegroundColor Cyan
Write-Host "Checked at: $(Get-Date)" -ForegroundColor Gray
Write-Host ""

# Create Windows Update COM object
try {
    $UpdateSession = New-Object -ComObject Microsoft.Update.Session
    $UpdateSearcher = $UpdateSession.CreateUpdateSearcher()

    # Search for installed updates
    Write-Host "--- Last Installed Updates ---" -ForegroundColor Yellow
    $InstalledUpdates = $UpdateSearcher.Search("IsInstalled=1").Updates | 
        Select-Object -First 10 |
        Select-Object Title, Date, @{N="InstallDate";E={$_.LastDeploymentChangeTime}}
    
    if ($InstalledUpdates) {
        $InstalledUpdates | Format-Table -AutoSize -Wrap
    } else {
        Write-Host "No installed update history found." -ForegroundColor DarkGray
    }

    Write-Host ""

    # Search for pending updates
    Write-Host "--- Pending Updates ---" -ForegroundColor Yellow
    $PendingUpdates = $UpdateSearcher.Search("IsInstalled=0").Updates
    
    if ($PendingUpdates.Count -gt 0) {
        Write-Host "Found $($PendingUpdates.Count) pending update(s):" -ForegroundColor Red
        $PendingUpdates | Select-Object Title, @{N="Size(MB)";E={[math]::Round($_.MaxDownloadSize/1MB,2)}} | Format-Table -AutoSize -Wrap
        
        if ($InstallAvailable) {
            Write-Host "`nInstalling pending updates..." -ForegroundColor Cyan
            $UpdateInstaller = $UpdateSession.CreateUpdateInstaller()
            $UpdatesToInstall = New-Object -ComObject Microsoft.Update.UpdateColl
            foreach ($update in $PendingUpdates) {
                $UpdatesToInstall.Add($update) | Out-Null
            }
            $UpdateInstaller.Updates = $UpdatesToInstall
            $Result = $UpdateInstaller.Install()
            
            if ($Result.ResultCode -eq 2) {
                Write-Host "Updates installed successfully!" -ForegroundColor Green
            } else {
                Write-Host "Update installation returned code: $($Result.ResultCode)" -ForegroundColor Magenta
            }
        } else {
            Write-Host "`nRun with -InstallAvailable switch to install pending updates." -ForegroundColor Gray
        }
    } else {
        Write-Host "No pending updates. System is up to date!" -ForegroundColor Green
    }

    Write-Host ""

    # Check Windows Update service status
    Write-Host "--- Windows Update Service Status ---" -ForegroundColor Yellow
    $WuaService = Get-Service -Name wuauserv -ErrorAction SilentlyContinue
    if ($WuaService) {
        $statusColor = if ($WuaService.Status -eq 'Running') { 'Green' } else { 'Red' }
        Write-Host "Service: $($WuaService.DisplayName) - Status: $($WuaService.Status)" -ForegroundColor $statusColor
    } else {
        Write-Host "Windows Update service not found." -ForegroundColor DarkGray
    }

} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Make sure to run this script as Administrator." -ForegroundColor Yellow
}
