<#
.SYNOPSIS
    Backs up one or more Windows registry hives to .reg files.

.DESCRIPTION
    Uses reg.exe to export a hive (or arbitrary subkey) to a timestamped
    .reg file in the destination folder. Multiple hives can be backed up
    in one invocation. Supports -WhatIf.

.PARAMETER Hive
    One or more hive short names (HKLM, HKCU, HKCR, HKU, HKCC) or full
    keypaths (e.g., 'HKLM\SOFTWARE\Microsoft'). Defaults to HKLM and HKCU.

.PARAMETER DestinationPath
    Folder to write backup files into. Created if missing. Defaults to
    .\registry-backups under the current directory.

.EXAMPLE
    PS> .\Backup-RegistryHive.ps1

.EXAMPLE
    PS> .\Backup-RegistryHive.ps1 -Hive 'HKLM\SOFTWARE\Microsoft\Windows' -DestinationPath C:\Backups

.NOTES
    Author  : Vikas Joshi
    Requires: Run as Administrator. reg.exe (built into Windows).
#>
[CmdletBinding(SupportsShouldProcess = $true)]
[OutputType([PSCustomObject])]
param (
    [string[]]$Hive = @('HKLM', 'HKCU'),

    [string]$DestinationPath = (Join-Path -Path $PWD.Path -ChildPath 'registry-backups')
)

if (-not (Test-Path -LiteralPath $DestinationPath)) {
    if ($PSCmdlet.ShouldProcess($DestinationPath, 'Create backup directory')) {
        New-Item -ItemType Directory -Path $DestinationPath -Force | Out-Null
    }
}

$timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'

foreach ($h in $Hive) {
    # Sanitize for filename
    $safeName = ($h -replace '[\\:]', '_')
    $outFile  = Join-Path -Path $DestinationPath -ChildPath ("{0}_{1}.reg" -f $safeName, $timestamp)

    if ($PSCmdlet.ShouldProcess($h, "Export to $outFile")) {
        $proc = Start-Process -FilePath 'reg.exe' `
            -ArgumentList @('export', $h, $outFile, '/y') `
            -Wait -NoNewWindow -PassThru

        $success = ($proc.ExitCode -eq 0)
        $sizeKB  = if ($success -and (Test-Path -LiteralPath $outFile)) {
            [math]::Round((Get-Item -LiteralPath $outFile).Length / 1KB, 2)
        } else { 0 }

        [PSCustomObject]@{
            Hive       = $h
            BackupFile = $outFile
            SizeKB     = $sizeKB
            Success    = $success
            ExitCode   = $proc.ExitCode
            BackedUpAt = Get-Date
        }
    }
}
