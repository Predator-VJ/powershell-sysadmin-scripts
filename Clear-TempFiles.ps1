<#
.SYNOPSIS
    Removes temporary files from common Windows temp locations.

.DESCRIPTION
    Iterates through user TEMP, system Temp, and (optionally) Prefetch,
    deleting files that are not currently locked. Supports -WhatIf and
    -Confirm thanks to SupportsShouldProcess. Emits a summary object per
    cleaned path.

.PARAMETER Path
    One or more paths to clean. Defaults to user TEMP, user TMP, and
    C:\Windows\Temp. Use -IncludePrefetch to also clean C:\Windows\Prefetch.

.PARAMETER IncludePrefetch
    Also clean C:\Windows\Prefetch. Off by default: prefetch entries
    have a small positive impact on app launch time and are generally
    low-yield to delete.

.EXAMPLE
    PS> .\Clear-TempFiles.ps1 -WhatIf
    Shows what would be deleted without removing anything.

.EXAMPLE
    PS> .\Clear-TempFiles.ps1 -Confirm:$false

.NOTES
    Author  : Vikas Joshi
    Requires: Run as Administrator for system-level paths.
#>
[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
[OutputType([PSCustomObject])]
param (
    [string[]]$Path,
    [switch]$IncludePrefetch
)

if (-not $Path) {
    $Path = @(
        $env:TEMP,
        $env:TMP,
        'C:\Windows\Temp'
    )
    if ($IncludePrefetch) {
        $Path += 'C:\Windows\Prefetch'
    }
}

# De-duplicate (TEMP and TMP are usually the same path)
$Path = $Path | Sort-Object -Unique

foreach ($p in $Path) {
    if (-not (Test-Path -LiteralPath $p)) {
        Write-Verbose "Skipping (not found): $p"
        continue
    }

    $beforeBytes = (Get-ChildItem -LiteralPath $p -Recurse -Force -ErrorAction SilentlyContinue |
        Measure-Object -Property Length -Sum).Sum

    if ($PSCmdlet.ShouldProcess($p, 'Delete temporary files')) {
        Get-ChildItem -LiteralPath $p -Recurse -Force -ErrorAction SilentlyContinue |
            Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    }

    $afterBytes = (Get-ChildItem -LiteralPath $p -Recurse -Force -ErrorAction SilentlyContinue |
        Measure-Object -Property Length -Sum).Sum

    $freedMB = [math]::Round((([double]$beforeBytes - [double]$afterBytes) / 1MB), 2)

    [PSCustomObject]@{
        Path       = $p
        BeforeMB   = [math]::Round([double]$beforeBytes / 1MB, 2)
        AfterMB    = [math]::Round([double]$afterBytes  / 1MB, 2)
        FreedMB    = $freedMB
        CleanedAt  = Get-Date
    }
}
