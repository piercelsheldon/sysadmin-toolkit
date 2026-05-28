[CmdletBinding(SupportsShouldProcess = $true)]
param (
    [Parameter(Mandatory = $false)]
    [int]$MonthsThreshold = 6,

    [Parameter(Mandatory = $false)]
    [string[]]$ExcludedUsers = @("Administrator", "Public", "Default")
)

# 1. Calculate the exact cutoff date
$CutoffDate = (Get-Date).AddMonths(-$MonthsThreshold)
Write-Output "Searching for user profiles that haven't been accessed since: $($CutoffDate.ToString('yyyy-MM-dd'))"

# 2. Fetch system profiles using the CIM interface (Modern WMI replacement)
try {
    $AllProfiles = Get-CimInstance -ClassName Win32_UserProfile -ErrorAction Stop
} catch {
    Write-Error "Failed to query system user profiles. Reason: $_"
    exit
}

# 3. Process profiles
foreach ($Profile in $AllProfiles) {
    # Skip critical built-in system profiles (NetworkService, LocalService, etc.)
    if ($Profile.Special -eq $true) {
        continue
    }

    # Safely handle missing LastUseTime (means profile was created but never fully initialized)
    if ($null -eq $Profile.LastUseTime) {
        Write-Verbose "Skipping $($Profile.LocalPath) - No login history recorded."
        continue
    }

    # Extract the folder name from the full local path (e.g. C:\Users\jdoe -> jdoe)
    $ProfileName = Split-Path -Leaf $Profile.LocalPath

    # Skip any user explicitly passed into our exclusion array
    if ($ExcludedUsers -contains $ProfileName) {
        Write-Output "SKIPPING: Profile '$ProfileName' is explicitly protected by policy rules."
        continue
    }

    # 4. Check if the profile is older than our 6-month cutoff date
    if ($Profile.LastUseTime -lt $CutoffDate) {
        $DaysInactive = ((Get-Date) - $Profile.LastUseTime).Days
        
        Write-Output "TARGET FOUND: User '$ProfileName' was last active $DaysInactive days ago ($($Profile.LastUseTime))."

        # 5. Remove the instance safely (supports -WhatIf safety check)
        try {
            $Profile | Remove-CimInstance -ErrorAction Stop
            Write-Output "SUCCESS: Completely purged registry keys and file footprints for '$ProfileName'."
        } catch {
            Write-Warning "ERROR: Could not remove profile for '$ProfileName'. Ensure it's not locked by an active process. Details: $_"
        }
    }
}
