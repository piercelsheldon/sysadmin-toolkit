# SysAdmin Toolkit

A collection of production-ready PowerShell scripts designed to automate system administration, identity management, and endpoint maintenance tasks.

## Tools Included

### 1. Active Directory User Offboarding
Automates the Identity and Access Management (IAM) offboarding process by disabling accounts, stripping memberships, and archiving users to a secure OU.
* **Path:** `/Active-Directory/Invoke-ADUserOffboarding.ps1`

### 2. Windows 11 Inactive Profile Cleaner
Safely purges local Windows 11 user profile footprints (including files and registry hooks) for accounts inactive for over 6 months.
* **Path:** `/Windows-11/Invoke-Win11ProfileCleanup.ps1`
