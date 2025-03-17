# Define Dry-Run Mode (Set to $false to apply changes)
$dryRun = $false

# Define Log File
$logFile = "sharedmailbox.log"

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
# Connect-ExchangeOnline -UserPrincipalName admin@yourdomain.com

# Import CSV file
$csvPath = "./sharedmailboxes.csv"
if (-Not (Test-Path $csvPath)) {
    Write-Log "ERROR: CSV file not found at $csvPath. Exiting..."
    Exit
}
$mailboxes = Import-Csv -Path $csvPath
Write-Log "Successfully imported CSV file with $($mailboxes.Count) entries."

# Iterate through each Shared Mailbox and add an alias
foreach ($mailbox in $mailboxes) {
    # Trim any whitespace from column values
    $primaryEmail = ($mailbox.PrimaryEmail).Trim()

    # Validate PrimaryEmail
    if (-not $primaryEmail -or $primaryEmail -eq "") {
        Write-Log "⚠ WARNING: Skipping empty PrimaryEmail entry in CSV"
        continue
    }

    # Generate alias email
    $alias = ($primaryEmail -split "@")[0] + "@ptxtrimble.com"
    Write-Log "Processing: $primaryEmail (Proposed Alias: $alias)"

    if ($dryRun) {
        Write-Log "   (DRY RUN) Would add alias: $alias to Shared Mailbox: $primaryEmail"
    } else {
        Set-Mailbox -Identity $primaryEmail -EmailAddresses @{Add="smtp:$alias"}
        Write-Log "   Alias added to Shared Mailbox: $alias"
    }
    continue

    # If no matching shared mailbox is found
    Write-Log "⚠ WARNING: No Shared Mailbox found for $primaryEmail"
}

# Disconnect session
Write-Log "Disconnecting from Exchange Online..."
# Disconnect-ExchangeOnline -Confirm:$false
Write-Log "Script execution completed."
