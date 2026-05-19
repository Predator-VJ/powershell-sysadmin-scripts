<#
.SYNOPSIS
    Reports current CPU, RAM, and disk usage for the local machine.

.DESCRIPTION
    Gathers system health metrics using CIM (the modern replacement for WMI):
        - Average CPU load percentage across all logical processors.
        - Physical memory total / used / free in GB.
        - Per-drive disk usage for all FileSystem PSDrives.
    Emits a single PSCustomObject so output can be piped to Format-Table,
    Export-Csv, ConvertTo-Json, etc.

.PARAMETER ComputerName
    Optional. Target a remote machine (requires WinRM enabled and rights).
    Defaults to the local computer.

.EXAMPLE
    PS> .\Get-SystemHealth.ps1
    Returns a health-report object for the local machine.

.EXAMPLE
    PS> .\Get-SystemHealth.ps1 | ConvertTo-Json -Depth 4
    JSON-formatted output suitable for monitoring pipelines.

.NOTES
    Author  : Vikas Joshi
    Requires: PowerShell 5.1+ or 7+. Administrator recommended for full data.
#>
[CmdletBinding()]
[OutputType([PSCustomObject])]
param (
    [string]$ComputerName = $env:COMPUTERNAME
)

$cimParams = @{ ErrorAction = 'Stop' }
if ($ComputerName -and $ComputerName -ne $env:COMPUTERNAME) {
    $cimParams['ComputerName'] = $ComputerName
}

try {
    # CPU: average load across all processors
    $cpuLoad = (Get-CimInstance -ClassName Win32_Processor @cimParams |
        Measure-Object -Property LoadPercentage -Average).Average

    # Memory: TotalVisibleMemorySize and FreePhysicalMemory are in KILOBYTES
    $os         = Get-CimInstance -ClassName Win32_OperatingSystem @cimParams
    $totalRamGB = [math]::Round(($os.TotalVisibleMemorySize * 1KB) / 1GB, 2)
    $freeRamGB  = [math]::Round(($os.FreePhysicalMemory      * 1KB) / 1GB, 2)
    $usedRamGB  = [math]::Round($totalRamGB - $freeRamGB, 2)
    $ramPct     = if ($totalRamGB -gt 0) { [math]::Round(($usedRamGB / $totalRamGB) * 100, 2) } else { 0 }

    # Disk: enumerate fixed drives via CIM (DriveType=3)
    $disks = Get-CimInstance -ClassName Win32_LogicalDisk -Filter 'DriveType=3' @cimParams |
        ForEach-Object {
            $totalGB = [math]::Round($_.Size      / 1GB, 2)
            $freeGB  = [math]::Round($_.FreeSpace / 1GB, 2)
            $usedGB  = [math]::Round($totalGB - $freeGB, 2)
            $usePct  = if ($totalGB -gt 0) { [math]::Round(($usedGB / $totalGB) * 100, 2) } else { 0 }
            [PSCustomObject]@{
                Drive    = $_.DeviceID
                TotalGB  = $totalGB
                UsedGB   = $usedGB
                FreeGB   = $freeGB
                UsedPct  = $usePct
            }
        }

    [PSCustomObject]@{
        ComputerName = $ComputerName
        CollectedAt  = Get-Date
        CpuLoadPct   = [math]::Round([double]$cpuLoad, 2)
        RamTotalGB   = $totalRamGB
        RamUsedGB    = $usedRamGB
        RamFreeGB    = $freeRamGB
        RamUsedPct   = $ramPct
        Disks        = $disks
    }
}
catch {
    Write-Error "Failed to collect system health: $($_.Exception.Message)"
}
