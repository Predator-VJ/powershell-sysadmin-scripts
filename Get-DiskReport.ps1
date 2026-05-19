<#
.SYNOPSIS
    Generates a disk-space report for all fixed drives.

.DESCRIPTION
    Queries Win32_LogicalDisk via CIM (DriveType=3 = fixed) and emits a
    PSCustomObject per drive with total / free / used / percent-used.
    Optionally exports the result to CSV.

.PARAMETER ComputerName
    Target machine. Defaults to local.

.PARAMETER ExportPath
    If provided, writes the result as CSV to this path.

.EXAMPLE
    PS> .\Get-DiskReport.ps1 | Format-Table -AutoSize

.EXAMPLE
    PS> .\Get-DiskReport.ps1 -ExportPath C:\Temp\disks.csv

.NOTES
    Author  : Vikas Joshi
    Requires: PowerShell 5.1+ or 7+.
#>
[CmdletBinding()]
[OutputType([PSCustomObject])]
param (
    [string]$ComputerName = $env:COMPUTERNAME,
    [string]$ExportPath
)

$cimParams = @{ ErrorAction = 'Stop' }
if ($ComputerName -and $ComputerName -ne $env:COMPUTERNAME) {
    $cimParams['ComputerName'] = $ComputerName
}

try {
    $report = Get-CimInstance -ClassName Win32_LogicalDisk -Filter 'DriveType=3' @cimParams |
        ForEach-Object {
            $totalGB = [math]::Round($_.Size      / 1GB, 2)
            $freeGB  = [math]::Round($_.FreeSpace / 1GB, 2)
            $usedGB  = [math]::Round($totalGB - $freeGB, 2)
            $usePct  = if ($totalGB -gt 0) { [math]::Round(($usedGB / $totalGB) * 100, 2) } else { 0 }
            [PSCustomObject]@{
                ComputerName = $ComputerName
                Drive        = $_.DeviceID
                VolumeName   = $_.VolumeName
                TotalGB      = $totalGB
                UsedGB       = $usedGB
                FreeGB       = $freeGB
                UsedPct      = $usePct
                CollectedAt  = Get-Date
            }
        }

    if ($ExportPath) {
        $parent = Split-Path -Parent $ExportPath
        if ($parent -and -not (Test-Path $parent)) {
            New-Item -ItemType Directory -Path $parent -Force | Out-Null
        }
        $report | Export-Csv -Path $ExportPath -NoTypeInformation
        Write-Verbose "Report exported to: $ExportPath"
    }

    $report
}
catch {
    Write-Error "Failed to collect disk report: $($_.Exception.Message)"
}
