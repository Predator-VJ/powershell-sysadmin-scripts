<#
.SYNOPSIS
    Lists, creates, or disables local Windows user accounts.

.DESCRIPTION
    Wraps the Microsoft.PowerShell.LocalAccounts module to perform common
    user-management tasks. Supports -WhatIf and -Confirm for state-changing
    actions (Create, Disable).

.PARAMETER Action
    One of List, Create, or Disable.

.PARAMETER Username
    Account name (required for Create and Disable).

.PARAMETER Password
    SecureString password (required for Create). Use Read-Host -AsSecureString
    or Get-Credential to obtain one safely. Plaintext is intentionally not
    accepted.

.PARAMETER FullName
    Optional display name when creating an account.

.EXAMPLE
    PS> .\Manage-LocalUsers.ps1 -Action List

.EXAMPLE
    PS> $securePwd = Read-Host -AsSecureString
    PS> .\Manage-LocalUsers.ps1 -Action Create -Username 'svc-app' -Password $securePwd

.EXAMPLE
    PS> .\Manage-LocalUsers.ps1 -Action Disable -Username 'oldUser' -WhatIf

.NOTES
    Author  : Vikas Joshi
    Requires: Run as Administrator. Microsoft.PowerShell.LocalAccounts module.
#>
[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
[OutputType([PSCustomObject])]
param (
    [Parameter(Mandatory = $true)]
    [ValidateSet('List', 'Create', 'Disable')]
    [string]$Action,

    [string]$Username,

    [securestring]$Password,

    [string]$FullName
)

if (-not (Get-Module -ListAvailable -Name Microsoft.PowerShell.LocalAccounts)) {
    throw "Microsoft.PowerShell.LocalAccounts is not available. Requires Windows 10 / Server 2016 or later."
}

switch ($Action) {
    'List' {
        Get-LocalUser | Select-Object Name, Enabled, LastLogon, PasswordLastSet, Description
    }

    'Create' {
        if (-not $Username -or -not $Password) {
            throw "Action 'Create' requires both -Username and -Password (SecureString)."
        }
        if ($PSCmdlet.ShouldProcess($Username, 'Create local user')) {
            $name = if ($FullName) { $FullName } else { $Username }
            New-LocalUser -Name $Username -Password $Password -FullName $name `
                -Description 'Created by Manage-LocalUsers.ps1' | Out-Null
            Add-LocalGroupMember -Group 'Users' -Member $Username
            Get-LocalUser -Name $Username
        }
    }

    'Disable' {
        if (-not $Username) {
            throw "Action 'Disable' requires -Username."
        }
        if ($PSCmdlet.ShouldProcess($Username, 'Disable local user')) {
            Disable-LocalUser -Name $Username
            Get-LocalUser -Name $Username
        }
    }
}
