# Define file paths
$csvFile = "./ProxyUpdates.csv"
$logFile = "./ADUserProxyUpdate2.log"

# Function to log messages
Function Write-Log {
    param ([string]$message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $message" | Out-File -Append -FilePath $logFile
}

Write-Log "Starting proxy migration run."

# Import CSV file
if (!(Test-Path $csvFile)) {
    Write-Log "ERROR: CSV file '$csvFile' not found. Exiting."
    exit
}

$csvData = Import-Csv -Path $csvFile

# Process each row in the CSV
foreach ($row in $csvData) {
    $upn = $row."User principal name"
    $newProxy = $row."Proxy addresses"
    
    Write-Log "Processing user: $upn with proxy: $newProxy"
    
    try {
        $user = Get-ADUser -Filter "UserPrincipalName -eq '$upn'" -Properties proxyAddresses
        if ($null -eq $user) {
            Write-Log "ERROR: User '$upn' not found in Active Directory."
            continue
        }
        Write-Log "User found: $($user.SamAccountName)"
    } catch {
        Write-Log "ERROR: Failed to retrieve user '$upn'. $_"
        continue
    }
    
    # Display existing proxy addresses
    Write-Log "Current proxy addresses: $($user.proxyAddresses -join ', ')"
    
    # Check if new alias already exists
    if ($user.proxyAddresses -contains $newProxy) {
        Write-Log "WARNING: Proxy address '$newProxy' already exists for '$upn'. Skipping."
        continue
    }
    
    # Add new alias
    $newProxies = $user.proxyAddresses + $newProxy
    try {
        # Set-ADUser -Identity $user.DistinguishedName -Replace @{proxyAddresses=$newProxies}
        Write-Log "DRY RUN: Setting users proxyAddress to: '$newProxies'"
        Write-Log "SUCCESS: Proxy address '$newProxy' added for user '$upn'."
    } catch {
        Write-Log "ERROR: Failed to update proxy addresses for '$upn'. $_"
    }
}

Write-Log "Proxy migration run completed."

