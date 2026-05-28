<#
.SYNOPSIS
    Automates the offboarding process for an Active Directory user.
.DESCRIPTION
    Disables the user, clears specific attributes, removes group memberships,
    moves the user to a disabled OU, and logs the results.
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [string]$SamAccountName,

    [Parameter(Mandatory = $true)]
    [string]$TargetOU,

    [Parameter(Mandatory = $false)]
    [string]$LogPath = "C:\Logs\AD_Offboarding.log"
)

# Helper function for clean logging
function Write-Log {
    param ([string]$Message)
    $TimeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "[$TimeStamp] $Message" | Out-File -FilePath $LogPath -Append
}

# Create log directory if it doesn't exist
$LogDir = Split-Path -Path $LogPath
if (-not (Test-Path -Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir | Out-Null }

try {
    # 1. Fetch User and verify existence
    $User = Get-ADUser -Identity $SamAccountName -Properties MemberOf, Description
    Write-Log "Starting offboarding for user: $($User.SamAccountName)"

    # 2. Disable the User Account
    Disable-ADAccount -Identity $User.SamAccountName
    Write-Log "SUCCESS: Disabled account."

    # 3. Update Description and clear attributes
    $DateStamp = Get-Date -Format "yyyy-MM-dd"
    $NewDescription = "Terminated on $DateStamp per HR request. Original Description: $($User.Description)"
    Set-ADUser -Identity $User.SamAccountName -Description $NewDescription -Clear "Office", "TelephoneNumber", "Manager"
    Write-Log "SUCCESS: Updated description and cleared standard attributes."

    # 4. Remove User from all Groups (except Primary Group / Domain Users)
    $Groups = $User.MemberOf | Get-ADGroup
    foreach ($Group in $Groups) {
        if ($Group.GroupScope -ne "DomainLocal" -or $Group.Name -ne "Domain Users") {
            Remove-ADGroupMember -Identity $Group.DistinguishedName -Members $User.SamAccountName -Confirm:$false
            Write-Log "SUCCESS: Removed from group $($Group.Name)"
        }
    }

    # 5. Move to Disabled Users OU
    Move-ADObject -Identity $User.DistinguishedName -TargetPath $TargetOU
    Write-Log "SUCCESS: Moved account to target OU: $TargetOU"
    Write-Log "COMPLETED: Offboarding finalized for $($User.SamAccountName)."

} catch {
    Write-Log "ERROR: Failed to offboard user $SamAccountName. Reason: $_"
    Write-Error $_
}
