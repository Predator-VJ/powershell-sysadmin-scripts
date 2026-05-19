# Contributing

Thanks for your interest in improving this script collection. PRs and issues are welcome.

## Quick rules

- One script = one job. Keep scripts focused.
- Verb-Noun naming using [approved PowerShell verbs](https://learn.microsoft.com/en-us/powershell/scripting/developer/cmdlet/approved-verbs-for-windows-powershell-commands) (e.g., `Get-`, `Set-`, `Test-`, `Clear-`, `Backup-`).
- All scripts must pass `PSScriptAnalyzer` with the rules in `PSScriptAnalyzerSettings.psd1` (CI enforces this).
- Prefer `Get-CimInstance` over the deprecated `Get-WmiObject`.
- Emit objects, not formatted text. Let the caller decide on `Format-Table` / `Export-Csv` / `Out-GridView`.

## Required script header

Every new script must start with comment-based help and `[CmdletBinding()]`:

```powershell
<#
.SYNOPSIS
    One-line summary.

.DESCRIPTION
    Longer description of what the script does, side effects, and any
    privileges required.

.PARAMETER Name
    Describe each parameter.

.EXAMPLE
    PS> .\Your-Script.ps1 -Param Value
    Show typical usage and expected output.

.NOTES
    Author : Your Name
    Requires: PowerShell 5.1+ (or 7+), Run as Administrator if applicable.
#>
[CmdletBinding(SupportsShouldProcess = $true)]
[OutputType([PSCustomObject])]
param (
    # ...
)
```

## Destructive scripts

Anything that deletes, disables, or modifies state must:

1. Declare `[CmdletBinding(SupportsShouldProcess = $true)]`.
2. Wrap state-changing calls with `if ($PSCmdlet.ShouldProcess(...))`.
3. Support `-WhatIf` and `-Confirm` automatically.

## Submitting changes

1. Fork and create a feature branch (`feat/short-description` or `fix/short-description`).
2. Run `Invoke-ScriptAnalyzer -Path . -Recurse -Settings ./PSScriptAnalyzerSettings.psd1` locally.
3. Open a PR describing **what** changed and **why**. Include sample output for new scripts.

## Testing

Manual smoke testing on Windows PowerShell 5.1 and PowerShell 7+ is expected for any script touching system state. CI only runs static analysis.
