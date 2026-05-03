# 🖥️ PowerShell SysAdmin Scripts

A curated collection of PowerShell scripts for IT System Administrators. These scripts help automate common tasks like system health checks, user management, disk monitoring, log cleanup, and more.

---

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
| `Get-WindowsUpdateStatus.ps1` | Checks pending and installed updates, service status |

---

## 🚀 Installation

### Option 1: Clone the Repository (Recommended)

```powershell
# Clone the repo
git clone https://github.com/Predator-VJ/powershell-sysadmin-scripts.git

# Navigate to the scripts folder
cd powershell-sysadmin-scripts
```

### Option 2: Download as ZIP

1. Click the **Code** button at the top of this repo
2. Select **Download ZIP**
3. Extract the ZIP file
4. Open PowerShell in the extracted folder

### Option 3: Download Individual Scripts

Click on any script file in the repo and use the **Raw** button to copy the content, then save it as a `.ps1` file on your system.

---

## ⚙️ Requirements

- Windows 10/11 or Windows Server 2016+
- Windows PowerShell 5.1+ or PowerShell 7+
- **Administrator privileges** required for most scripts
- Git (optional, for cloning the repo)

---

## 🔧 How to Run Scripts

### Step 1: Open PowerShell as Administrator

Right-click on **Start** → **Windows PowerShell (Admin)** or **Terminal (Admin)**

### Step 2: Bypass Execution Policy (One-Time Setup)

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Step 3: Navigate to the Scripts Directory

```powershell
cd C:\path\to\powershell-sysadmin-scripts
```

### Step 4: Run Any Script

```powershell
.\Get-SystemHealth.ps1
```

---

## 📖 Usage Examples

### Check System Health (CPU, RAM, Disk)
```powershell
.\Get-SystemHealth.ps1
```

### Export System Inventory to CSV
```powershell
.\Get-SystemInventory.ps1
```

### Check Windows Update Status
```powershell
.\Get-WindowsUpdateStatus.ps1
```

### Check and Auto-Install Pending Updates
```powershell
.\Get-WindowsUpdateStatus.ps1 -InstallAvailable
```

### Monitor Critical Services (with auto-restart)
```powershell
.\Monitor-Services.ps1
```

### List All Local Users
```powershell
.\Manage-LocalUsers.ps1 -Action List
```

### Create a New Local User
```powershell
.\Manage-LocalUsers.ps1 -Action Create -Username "john.doe" -Password "P@ssw0rd123!"
```

### Test Network Connectivity
```powershell
.\Test-NetworkConnectivity.ps1
```

---

## 🖋️ Author

**Vikas Joshi** — System Admin  
GitHub: [Predator-VJ](https://github.com/Predator-VJ)

---

> ⭐ If you find these scripts useful, consider **starring** the repo!
