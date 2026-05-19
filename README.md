<div align="center">

<img src="https://capsule-render.vercel.app/api?type=waving&color=0:0d1117,50:1a1a2e,100:16213e&height=200&section=header&text=PowerShell%20SysAdmin%20Scripts&fontSize=40&fontColor=00d4ff&animation=fadeIn&fontAlignY=35&desc=Automate.%20Monitor.%20Dominate.&descAlignY=55&descSize=18&descColor=a0c4ff" />

</div>

<div align="center">

![PowerShell](https://img.shields.io/badge/PowerShell-5391FE?style=for-the-badge&logo=powershell&logoColor=white)
![Windows](https://img.shields.io/badge/Windows-0078D6?style=for-the-badge&logo=windows&logoColor=white)
![IT SysAdmin](https://img.shields.io/badge/IT%20SysAdmin-00D4FF?style=for-the-badge&logo=windowsterminal&logoColor=white)
![Scripts](https://img.shields.io/badge/Scripts-14-blueviolet?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Active-brightgreen?style=for-the-badge)
[![PSScriptAnalyzer](https://github.com/Predator-VJ/powershell-sysadmin-scripts/actions/workflows/psscriptanalyzer.yml/badge.svg)](https://github.com/Predator-VJ/powershell-sysadmin-scripts/actions/workflows/psscriptanalyzer.yml)
![License](https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge)

</div>

<br/>

<div align="center">
<a href="https://github.com/Predator-VJ/powershell-sysadmin-scripts">
<img src="https://readme-typing-svg.demolab.com?font=JetBrains+Mono&weight=700&size=20&pause=1000&color=00D4FF&center=true&vCenter=true&multiline=false&width=600&height=40&lines=System+Health+Monitoring;User+%26+Account+Management;Disk+%26+Storage+Automation;Event+Log+%26+Security+Analysis;Network+Connectivity+Tests" alt="Features" />
</a>
</div>

<br/>

---

## Script Arsenal

<div align="center">

| Script | Description | Category |
|--------|-------------|----------|
| `Get-SystemHealth.ps1` | CPU, RAM and disk usage in a single object | Monitoring |
| `Get-DiskReport.ps1` | Per-drive disk usage with CSV export | Storage |
| `Get-SystemInventory.ps1` | Hardware/OS inventory snapshot | Inventory |
| `Manage-LocalUsers.ps1` | List, create, disable local users (SecureString) | Users |
| `Monitor-Services.ps1` | Check status; opt-in `-Restart` for stopped services | Services |
| `Get-EventLogErrors.ps1` | Recent Critical/Error events from any log | Logs |
| `Get-FailedLogons.ps1` | Event ID 4625 with logon-type and source IP | Security |
| `Get-WindowsUpdateStatus.ps1` | Pending updates, install history, optional install | Updates |
| `Clear-TempFiles.ps1` | Clean temp folders (supports `-WhatIf`) | Cleanup |
| `Test-NetworkConnectivity.ps1` | Ping a list of hosts, return objects | Network |
| `Get-OpenPorts.ps1` | Listening TCP ports joined with process info | Network |
| `Get-StartupItems.ps1` | Run / RunOnce registry + Startup folder entries | Startup |
| `Get-ScheduledTaskReport.ps1` | Tasks with last/next run and result decoded | Tasks |
| `Backup-RegistryHive.ps1` | Export hives to timestamped `.reg` files | Backup |

</div>

---

## Quick Start

```powershell
# Clone
git clone https://github.com/Predator-VJ/powershell-sysadmin-scripts.git
cd powershell-sysadmin-scripts

# All scripts emit objects, so pipe them however you like:
.\Get-SystemHealth.ps1 | Format-List
.\Get-DiskReport.ps1   | Export-Csv .\disks.csv -NoTypeInformation
.\Get-OpenPorts.ps1    | Sort-Object LocalPort | Out-GridView

# Destructive scripts support -WhatIf and -Confirm
.\Clear-TempFiles.ps1 -WhatIf
```

---

## Requirements

- **Windows PowerShell 5.1** or **PowerShell 7+** on Windows.
- **Administrator** for scripts touching system state (Security log, services, registry, temp cleanup, user management, Windows Update).
- Execution policy: `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`.

> Scripts use `Get-CimInstance` (modern, cross-edition) instead of the deprecated `Get-WmiObject`.

---

## Conventions

Every script in this repo follows a consistent shape:

- Comment-based help (`Get-Help .\Get-SystemHealth.ps1 -Full`).
- `[CmdletBinding()]` so `-Verbose`, `-ErrorAction`, etc. work everywhere.
- `[OutputType([PSCustomObject])]` and **emits objects, not formatted text**, so output is composable.
- State-changing scripts declare `SupportsShouldProcess` and respect `-WhatIf` / `-Confirm`.

See [`CONTRIBUTING.md`](./CONTRIBUTING.md) for the full template.

---

## Continuous Integration

Every push and pull request runs [PSScriptAnalyzer](https://github.com/PowerShell/PSScriptAnalyzer) on Windows via GitHub Actions. See [`.github/workflows/psscriptanalyzer.yml`](./.github/workflows/psscriptanalyzer.yml) and [`PSScriptAnalyzerSettings.psd1`](./PSScriptAnalyzerSettings.psd1).

Run it locally before submitting a PR:

```powershell
Install-Module PSScriptAnalyzer -Scope CurrentUser
Invoke-ScriptAnalyzer -Path . -Recurse -Settings .\PSScriptAnalyzerSettings.psd1
```

---

## Examples

Sample output files live in [`examples/`](./examples) so you can see what each script returns without running anything.

---

## Author

<div align="center">

**Vikas Joshi** &mdash; IT SysAdmin | PowerShell Automation

[![GitHub](https://img.shields.io/badge/GitHub-Predator--VJ-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/Predator-VJ)

</div>

## License

[MIT](./LICENSE)

<div align="center">
<img src="https://capsule-render.vercel.app/api?type=waving&color=0:16213e,50:1a1a2e,100:0d1117&height=120&section=footer" />
</div>
