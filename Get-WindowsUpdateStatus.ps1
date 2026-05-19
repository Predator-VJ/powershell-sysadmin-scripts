<#
.SYNOPSIS
    Reports Windows Update status: pending updates, install history, service state.

.DESCRIPTION
    Uses the Microsoft.Update.Session COM object to enumerate pending and
    recently installed updates. Optionally installs pending updates when
    -InstallAvailable is supplied (which is a state-changing operation
    gated by ShouldProcess).

.PARAMETER InstallAvailable
    Install any pending updates found.

.PARAMETER HistoryCount
    Number of recent installed updates to return. Defaults to 10.

.EXAMPLE
    PS> .\Get-WindowsUpdateStatus.ps1

.EXAMPLE
    PS> .\Get-WindowsUpdateStatus.ps1 -InstallAvailable -WhatIf

.NOTES
    Author  : Vikas Joshi
    Requires: Run as Administrator. Windows-only (uses COM).
#>
[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
[OutputType([PSCustomObject])]
param (
    [switch]$InstallAvailable,

    [ValidateRange(1, 200)]
    [int]$HistoryCount = 10
)

if ($PSVersionTable.Platform -and $PSVersionTable.Platform -ne 'Win32NT') {
    throw "Get-WindowsUpdateStatus.ps1 only runs on Windows (uses Microsoft.Update.Session COM object)."
}

try {
    $session  = New-Object -ComObject Microsoft.Update.Session
    $searcher = $session.CreateUpdateSearcher()

    # Recent install history
    $installed = $searcher.Search('IsInstalled=1').Updates |
        Select-Object -First $HistoryCount |
        Select-Object @{N = 'Title';       E = { $_.Title }},
                      @{N = 'InstallDate'; E = { $_.LastDeploymentChangeTime }}

    # Pending
    $pendingResult = $searcher.Search('IsInstalled=0').Updates
    $pending = @()
    foreach ($u in $pendingResult) {
        $sizeBytes = if ($null -ne $u.MaxDownloadSize) { [double]$u.MaxDownloadSize } else { 0 }
        $pending += [PSCustomObject]@{
            Title  = $u.Title
            SizeMB = [math]::Round($sizeBytes / 1MB, 2)
        }
    }

    # Service status
    $wuaService = Get-Service -Name wuauserv -ErrorAction SilentlyContinue
    $serviceStatus = if ($wuaService) { $wuaService.Status.ToString() } else { 'NotFound' }

    $report = [PSCustomObject]@{
        ComputerName       = $env:COMPUTERNAME
        ServiceStatus      = $serviceStatus
        PendingCount       = $pending.Count
        PendingUpdates     = $pending
        InstalledRecent    = $installed
        Installed          = $false
        InstallResultCode  = $null
        CollectedAt        = Get-Date
    }

    if ($InstallAvailable -and $pending.Count -gt 0) {
        if ($PSCmdlet.ShouldProcess($env:COMPUTERNAME, "Install $($pending.Count) Windows Update(s)")) {
            $installer = $session.CreateUpdateInstaller()
            $coll      = New-Object -ComObject Microsoft.Update.UpdateColl
            foreach ($u in $pendingResult) { $coll.Add($u) | Out-Null }
            $installer.Updates = $coll
            $result = $installer.Install()
            $report.Installed         = ($result.ResultCode -eq 2)
            $report.InstallResultCode = $result.ResultCode
        }
    }

    $report
}
catch {
    Write-Error "Failed to query Windows Update: $($_.Exception.Message)"
}
