# 🖥️ PowerShell SysAdmin Scripts

A curated collection of PowerShell scripts for IT System Administrators. These scripts help automate common tasks like system health checks, user management, disk monitoring, log cleanup, and more.

## 📁 Scripts Overview

| Script | Description |
|--------|-------------|
| `Get-SystemHealth.ps1` | Checks CPU, RAM, and Disk usage |
| `Get-DiskReport.ps1` | Generates disk space report for all drives |
| `Manage-LocalUsers.ps1` | List, create, disable local user accounts |
| `Monitor-Services.ps1` | Checks and restarts stopped critical services |
| `Get-EventLogErrors.ps1` | Fetches recent errors from Windows Event Logs |
| `Clear-TempFiles.ps1` | Cleans up temp files to free disk space |
| `Get-SystemInventory.ps1` | Collects hardware and OS info and exports to CSV |
| `Test-NetworkConnectivity.ps1` | Pings a list of hosts and reports status |

## ⚙️ Requirements

- Windows PowerShell 5.1+ or PowerShell 7+
- Run scripts with **Administrator** privileges where required

## 🚀 Usage

```powershell
# Example: Run system health check
.\Get-SystemHealth.ps1

# Example: Export system inventory to CSV
.\Get-SystemInventory.ps1
```

## 👤 Author

**Vikas Joshi** — System Admin  
GitHub: [Predator-VJ](https://github.com/Predator-VJ)

---
> ⭐ If you find these scripts useful, consider starring the repo!
