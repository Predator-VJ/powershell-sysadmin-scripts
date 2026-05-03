# Get-SystemInventory.ps1
# Collects hardware and OS information and exports to CSV
# Run as Administrator

param (
    [string]$ExportPath = "C:\Temp\SystemInventory_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
)

Write-Host "===== System Inventory =====" -ForegroundColor Cyan

$cs   = Get-WmiObject Win32_ComputerSystem
$os   = Get-WmiObject Win32_OperatingSystem
$cpu  = Get-WmiObject Win32_Processor | Select-Object -First 1
$bios = Get-WmiObject Win32_BIOS
$disk = Get-WmiObject Win32_LogicalDisk -Filter "DriveType=3" |
        Select-Object DeviceID, @{N='Size(GB)';E={[math]::Round($_.Size/1GB,2)}}

$inventory = [PSCustomObject]@{
    ComputerName    = $cs.Name
    Manufacturer    = $cs.Manufacturer
    Model           = $cs.Model
    CPU             = $cpu.Name
    CPUCores        = $cpu.NumberOfCores
    RAM_GB          = [math]::Round($cs.TotalPhysicalMemory/1GB, 2)
    OS              = $os.Caption
    OSVersion       = $os.Version
    OSArchitecture  = $os.OSArchitecture
    LastBootTime    = $os.ConvertToDateTime($os.LastBootUpTime)
    BIOSVersion     = $bios.SMBIOSBIOSVersion
    SerialNumber    = $bios.SerialNumber
    IPAddress       = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -ne '127.0.0.1' }).IPAddress -join ', '
    CollectedAt     = Get-Date
}

$inventory | Format-List
$inventory | Export-Csv -Path $ExportPath -NoTypeInformation
Write-Host "Exported to: $ExportPath" -ForegroundColor Green
