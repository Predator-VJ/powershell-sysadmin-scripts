# Manage-LocalUsers.ps1
# List, create, or disable local Windows user accounts
# Run as Administrator

param (
    [ValidateSet('List','Create','Disable')]
    [string]$Action = 'List',
    [string]$Username = '',
    [string]$Password = ''
)

switch ($Action) {
    'List' {
        Write-Host "===== Local User Accounts =====" -ForegroundColor Cyan
        Get-LocalUser | Select-Object Name, Enabled, LastLogon, PasswordLastSet | Format-Table -AutoSize
    }
    'Create' {
        if (-not $Username -or -not $Password) {
            Write-Error "Please provide -Username and -Password to create a user."
            exit 1
        }
        $secPwd = ConvertTo-SecureString $Password -AsPlainText -Force
        New-LocalUser -Name $Username -Password $secPwd -FullName $Username -Description "Created by SysAdmin Script"
        Add-LocalGroupMember -Group "Users" -Member $Username
        Write-Host "User '$Username' created successfully." -ForegroundColor Green
    }
    'Disable' {
        if (-not $Username) {
            Write-Error "Please provide -Username to disable."
            exit 1
        }
        Disable-LocalUser -Name $Username
        Write-Host "User '$Username' has been disabled." -ForegroundColor Yellow
    }
}
