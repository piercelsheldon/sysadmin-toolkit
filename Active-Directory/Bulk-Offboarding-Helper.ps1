# Configuration
Import-Module ActiveDirectory
$CSVPath    = "C:\Imports\TerminatedUsers.csv"
$DisabledOU = "OU=Disabled Users,DC=yourdomain,DC=local"
$LogFile    = "C:\Logs\Bulk_Offboarding.log"
$ScriptPath = "C:\Scripts\Invoke-ADUserOffboarding.ps1"

# Import users and loop through them
if (Test-Path $CSVPath) {
    $UsersToProcess = Import-Csv -Path $CSVPath
    foreach ($Row in $UsersToProcess) {
        # Check if the user exists in AD before running the script
        if (Get-ADUser -Filter "SamAccountName -eq '$($Row.Username)'") {
            & $ScriptPath -SamAccountName $Row.Username -TargetOU $DisabledOU -LogPath $LogFile
        } else {
            "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') [WARNING] User $($Row.Username) not found in Active Directory." | Out-File -FilePath $LogFile -Append
        }
    }
} else {
    Write-Host "Error: CSV file not found at $CSVPath" -ForegroundColor Red
}
