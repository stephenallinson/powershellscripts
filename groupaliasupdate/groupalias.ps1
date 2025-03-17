# Define Dry-Run Mode (Set to $false to apply changes)
$dryRun = $false

# Define Log File
$logFile = "alias_log.txt"

# Function to log messages
function Write-Log {
    param (
        [string]$message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp - $message"
    Write-Host $logEntry
    Add-Content -Path $logFile -Value $logEntry
}

# Connect to Exchange Online
Write-Log "Connecting to Exchange Online..."
# Connect-ExchangeOnline -UserPrincipalName stephen.allinson.entraadm@ptxag.com

# Import CSV file
$csvPath = "./entragroups.csv"
if (-Not (Test-Path $csvPath)) {
    Write-Log "ERROR: CSV file not found at $csvPath. Exiting..."
    Exit
}
$groups = Import-Csv -Path $csvPath
Write-Log "Successfully imported CSV file with $($groups.Count) entries."

# Iterate through each group and add an alias
foreach ($group in $groups) {
    $primaryEmail = $group.PrimaryEmail
    $alias = ($primaryEmail -split "@")[0] + "@ptxtrimble.com"

    Write-Log "Processing: $primaryEmail (Proposed Alias: $alias)"

    # Check if it's a Microsoft 365 Group
    $groupObj = Get-UnifiedGroup -Identity $primaryEmail -ErrorAction SilentlyContinue
    if ($groupObj) {
        Write-Log "→ Found Microsoft 365 Group: $primaryEmail"

        if ($dryRun) {
            Write-Log "   (DRY RUN) Would add alias: $alias to M365 Group: $primaryEmail"
        } else {
            Set-UnifiedGroup -Identity $primaryEmail -EmailAddresses @{Add="smtp:$alias"}
            Write-Log "   Alias added to M365 Group: $alias"
        }
        continue
    }

    # Check if it's a Distribution List
    $dlObj = Get-DistributionGroup -Identity $primaryEmail -ErrorAction SilentlyContinue
    if ($dlObj) {
        Write-Log "→ Found Distribution List: $primaryEmail"

        if ($dryRun) {
            Write-Log "   (DRY RUN) Would add alias: $alias to Distribution List: $primaryEmail"
        } else {
            Set-DistributionGroup -Identity $primaryEmail -EmailAddresses @{Add="smtp:$alias"}
            Write-Log "   Alias added to Distribution List: $alias"
        }
        continue
    }

    # If no matching group is found
    Write-Log "⚠ WARNING: No matching Group or Distribution List found for $primaryEmail"
}

# Disconnect session
Write-Log "Disconnecting from Exchange Online..."
# Disconnect-ExchangeOnline -Confirm:$false
Write-Log "Script execution completed."
