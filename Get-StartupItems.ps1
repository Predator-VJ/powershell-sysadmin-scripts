<#
.SYNOPSIS
    Lists programs configured to run at Windows startup.

.DESCRIPTION
    Aggregates startup entries from the standard Run / RunOnce registry
    locations (HKLM and HKCU, both 32- and 64-bit views) and the user's
    Startup folder. Returns a single normalized object stream so output
    can be filtered, exported, or grouped.

.EXAMPLE
    PS> .\Get-StartupItems.ps1 | Sort-Object Source, Name | Format-Table -AutoSize

.EXAMPLE
    PS> .\Get-StartupItems.ps1 | Where-Object Source -like 'HKLM*'

.NOTES
    Author  : Vikas Joshi
    Requires: PowerShell 5.1+ or 7+. Some HKLM entries require Administrator.
#>
[CmdletBinding()]
[OutputType([PSCustomObject])]
param ()

$registryRoots = @(
    @{ Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run';                Source = 'HKLM\Run' }
    @{ Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce';            Source = 'HKLM\RunOnce' }
    @{ Path = 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run';    Source = 'HKLM\Run (Wow64)' }
    @{ Path = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run';                Source = 'HKCU\Run' }
    @{ Path = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce';            Source = 'HKCU\RunOnce' }
)

foreach ($root in $registryRoots) {
    if (-not (Test-Path -LiteralPath $root.Path)) { continue }
    try {
        $props = Get-ItemProperty -LiteralPath $root.Path -ErrorAction Stop
    }
    catch {
        Write-Verbose "Cannot read $($root.Path): $($_.Exception.Message)"
        continue
    }

    foreach ($prop in $props.PSObject.Properties) {
        if ($prop.Name -in 'PSPath', 'PSParentPath', 'PSChildName', 'PSDrive', 'PSProvider') { continue }
        [PSCustomObject]@{
            Name    = $prop.Name
            Command = $prop.Value
            Source  = $root.Source
        }
    }
}

# Startup folder shortcuts
$startupFolders = @(
    @{ Path = [Environment]::GetFolderPath('Startup');       Source = 'User Startup folder' }
    @{ Path = [Environment]::GetFolderPath('CommonStartup'); Source = 'All Users Startup folder' }
)

foreach ($folder in $startupFolders) {
    if (-not $folder.Path -or -not (Test-Path -LiteralPath $folder.Path)) { continue }
    Get-ChildItem -LiteralPath $folder.Path -File -ErrorAction SilentlyContinue | ForEach-Object {
        [PSCustomObject]@{
            Name    = $_.BaseName
            Command = $_.FullName
            Source  = $folder.Source
        }
    }
}
