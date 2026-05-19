@{
    # Severity levels reported by CI
    Severity     = @('Error', 'Warning')

    # Rules that are noisy or not applicable to a script collection.
    # Keep this list as small as possible. Every script that mutates state
    # must implement SupportsShouldProcess, so we do NOT exclude
    # PSUseShouldProcessForStateChangingFunctions.
    ExcludeRules = @(
        # Write-Host is fine for foreground human output (we don't actually
        # use it currently, but contributors may add summary banners).
        'PSAvoidUsingWriteHost'
    )

    Rules = @{
        PSPlaceOpenBrace = @{
            Enable             = $true
            OnSameLine         = $true
            NewLineAfter       = $true
            IgnoreOneLineBlock = $true
        }
        PSPlaceCloseBrace = @{
            Enable             = $true
            NewLineAfter       = $true
            IgnoreOneLineBlock = $true
            NoEmptyLineBefore  = $false
        }
    }
}
