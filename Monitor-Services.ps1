<#
.SYNOPSIS
    Checks status of critical Windows services. Optionally restarts stopped ones.

.DESCRIPTION
    Reports the running status of each service in -ServiceName. By default
    this script is non-destructive: it only reports. Pass -Restart to
    actually start any stopped services. -Restart honors -WhatIf and
    -Confirm via SupportsShouldProcess.

.PARAMETER ServiceName
    One or more service short names to check. Defaults to a common set.

.PARAMETER Restart
    Attempt to start any service whose status is not Running. Off by default.

.EXAMPLE
    PS> .\Monitor-Services.ps1
    Reports status of the default service set.

.EXAMPLE
    PS> .\Monitor-Services.ps1 -ServiceName Spooler, wuauserv -Restart -WhatIf
    Shows which services would be started, without doing it.

.NOTES
    Author  : Vikas Joshi
    Requires: Run as Administrator when -Restart is used.
#>
[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
[OutputType([PSCustomObject])]
param (
    [string[]]$ServiceName = @(
        'wuauserv',     # Windows Update
        'Spooler',      # Print Spooler
        'W32Time',      # Windows Time
        'Dnscache',     # DNS Client
        'LanmanServer'  # Server (File Sharing)
    ),
    [switch]$Restart
)

foreach ($name in $ServiceName) {
    $svc = Get-Service -Name $name -ErrorAction SilentlyContinue

    if ($null -eq $svc) {
        [PSCustomObject]@{
            Service     = $name
            DisplayName = $null
            Status      = 'NotFound'
            Action      = 'None'
            CheckedAt   = Get-Date
        }
        continue
    }

    if ($svc.Status -eq 'Running') {
        [PSCustomObject]@{
            Service     = $svc.Name
            DisplayName = $svc.DisplayName
            Status      = 'Running'
            Action      = 'None'
            CheckedAt   = Get-Date
        }
        continue
    }

    # Service exists and is not Running
    $action = 'ReportOnly'
    if ($Restart) {
        if ($PSCmdlet.ShouldProcess($svc.Name, 'Start service')) {
            try {
                Start-Service -Name $svc.Name -ErrorAction Stop
                $action = 'Started'
            }
            catch {
                $action = "FailedToStart: $($_.Exception.Message)"
            }
        }
        else {
            # -WhatIf path
            $action = 'WhatIfSkipped'
        }
    }

    $current = Get-Service -Name $svc.Name -ErrorAction SilentlyContinue
    [PSCustomObject]@{
        Service     = $svc.Name
        DisplayName = $svc.DisplayName
        Status      = if ($current) { $current.Status } else { 'Unknown' }
        Action      = $action
        CheckedAt   = Get-Date
    }
}
