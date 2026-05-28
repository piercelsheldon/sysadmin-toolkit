# SysAdmin & Automation Toolkit

A centralized repository of production-ready PowerShell frameworks designed to automate Identity & Access Management (IAM), security compliance, and endpoint lifecycle maintenance.

## 📁 Repository Structure
* `/Active-Directory`: Enterprise user lifecycle and offboarding tools.
* `/templates`: Standardized data input structures for bulk automation tasks.
* `/Windows-11`: System maintenance, profile cleanup, and disk optimization utilities.

---

## 🛠️ Modules & Tools

### 1. Active Directory User Offboarding Framework
Automates corporate user termination processes to enforce compliance and eliminate stale account security vulnerabilities.

* **Key Features:** Account disabling, bulk processing via HR CSV lists, automatic security group stripping, metadata updates, and target OU archiving.
* **Target Script:** `/Active-Directory/Invoke-ADUserOffboarding.ps1`
* **Bulk Helper Script:** `/Active-Directory/Bulk-Offboarding-Helper.ps1`
* **Input Template:** `/templates/TerminatedUsers.example.csv`

#### How To Use:
To process an individual account migration:
```powershell
.\Active-Directory\Invoke-ADUserOffboarding.ps1 -SamAccountName "jdoe" -TargetOU "OU=Disabled Users,DC=domain,DC=local"
```

---

### 2. Windows 11 Inactive Profile Purge Utility
Enforces local asset data hygiene by identifying and safely removing local user profile footprints inactive for more than 6 months.

* **Key Features:** Clean deletion via the modern `CimInstance` registry namespace (prevents profile path corruption), built-in system safety exclusions, and `-WhatIf` testing support.
* **Target Script:** `/Windows-11/Invoke-Win11ProfileCleanup.ps1`

#### How To Use:
To test and log which old profiles will be purged without making system changes:
```powershell
.\Windows-11\Invoke-Win11ProfileCleanup.ps1 -MonthsThreshold 6 -WhatIf
```

---

## 🛑 Requirements & Safety
* **Permissions:** Scripts interacting with AD require delegated IAM permissions or Domain Admin rights. Local Windows 11 cleanups require elevated Administrator privileges.
* **Testing:** Always execute scripts with `-WhatIf` or within a staging sandbox 
