<#
.SYNOPSIS
    Identifies stale computer accounts in Active Directory.
.DESCRIPTION
    Finds computer accounts that have not logged on in a specified number of days.
    Useful for AD cleanup and security auditing.
.PARAMETER DaysInactive
    Number of days of inactivity to consider a computer as stale.
.PARAMETER DistinguishedName
    OU path to search within. Default is entire domain.
.EXAMPLE
    .\Get-StaleComputers.ps1 -DaysInactive 90
.NOTES
    Requires ActiveDirectory module. Run as Administrator.
#>

param(
    [int]$DaysInactive = 90,
    [string]$DistinguishedName = ""
)

Import-Module ActiveDirectory -ErrorAction Stop

$days = (Get-Date).AddDays(-$DaysInactive).Date

Write-Host "Searching for computer accounts inactive for more than $DaysInactive days..." -ForegroundColor Yellow

 $Computers = Get-ADComputer -Filter {Enabled -eq $true -and LastLogonDate -lt $days} `
    -Properties LastLogonDate, Enabled, DistinguishedName, IPv4Address |
    Select-Object Name, LastLogonDate, Enabled, @{Name="DaysInactive";Expression={
        (New-TimeSpan -Start $_.LastLogonDate -End (Get-Date)).Days
    }}, DistinguishedName | Sort-Object DaysInactive -Descending

if ($Computers.Count -eq 0) {
    Write-Host "No stale computers found." -ForegroundColor Green
} else {
    Write-Host "Found $($Computers.Count) stale computer accounts:" -ForegroundColor Red
    $Computers | Format-Table -AutoSize
}

$Computers | Export-Csv -Path ".\stale-computers.csv" -NoTypeInformation
Write-Host "Report exported to .\stale-computers.csv" -ForegroundColor Green
