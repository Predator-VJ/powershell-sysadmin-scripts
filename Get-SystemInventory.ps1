<#
.SYNOPSIS
    Collects hardware and OS inventory data for the local machine.

.DESCRIPTION
    Pulls computer system, OS, CPU, BIOS, and IP information via CIM and
    emits a single PSCustomObject. Optionally exports to CSV.

.PARAMETER ComputerName
    Target machine. Defaults to local.

.PARAMETER ExportPath
    If provided, writes the result as CSV to this path.

.EXAMPLE
    PS> .\Get-SystemInventory.ps1

.EXAMPLE
    PS> .\Get-SystemInventory.ps1 -ExportPath C:\Temp\inventory.csv

.NOTES
    Author  : Vikas Joshi
    Requires: PowerShell 5.1+ or 7+. Administrator recommended.
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
    $cs   = Get-CimInstance -ClassName Win32_ComputerSystem  @cimParams
    $os   = Get-CimInstance -ClassName Win32_OperatingSystem @cimParams
    $cpu  = Get-CimInstance -ClassName Win32_Processor       @cimParams | Select-Object -First 1
    $bios = Get-CimInstance -ClassName Win32_BIOS            @cimParams

    $ipAddresses = @()
    if (Get-Command -Name Get-NetIPAddress -ErrorAction SilentlyContinue) {
        $ipAddresses = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
            Where-Object { $_.IPAddress -ne '127.0.0.1' } |
            Select-Object -ExpandProperty IPAddress
    }

    $inventory = [PSCustomObject]@{
        ComputerName   = $cs.Name
        Manufacturer   = $cs.Manufacturer
        Model          = $cs.Model
        Cpu            = $cpu.Name
        CpuCores       = $cpu.NumberOfCores
        CpuLogical     = $cpu.NumberOfLogicalProcessors
        RamGB          = [math]::Round($cs.TotalPhysicalMemory / 1GB, 2)
        Os             = $os.Caption
        OsVersion      = $os.Version
        OsArchitecture = $os.OSArchitecture
        LastBootTime   = $os.LastBootUpTime
        BiosVersion    = $bios.SMBIOSBIOSVersion
        SerialNumber   = $bios.SerialNumber
        IpAddresses    = ($ipAddresses -join ', ')
        CollectedAt    = Get-Date
    }

    if ($ExportPath) {
        $parent = Split-Path -Parent $ExportPath
        if ($parent -and -not (Test-Path $parent)) {
            New-Item -ItemType Directory -Path $parent -Force | Out-Null
        }
        $inventory | Export-Csv -Path $ExportPath -NoTypeInformation
        Write-Verbose "Exported to: $ExportPath"
    }

    $inventory
}
catch {
    Write-Error "Failed to collect inventory: $($_.Exception.Message)"
}
