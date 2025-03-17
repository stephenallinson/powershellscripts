$upn = "stephen.allinson@JCA99.onmicrosoft.com"
$newProxy = "smtp:stephen.allinson@jcatechnologies.com"
$logFile = ".\ADUserProxyUpdate.log"

# Function to log messages
Function Write-Log {
    param ([string]$message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $message" | Out-File -Append -FilePath $logFile
}

Write-Log "Starting proxy migration run for user: $upn"

# Try fetching the user and handle errors
try {
    $user = Get-ADUser -Filter "UserPrincipalName -eq '$upn'" -Properties proxyAddresses
    if ($null -eq $user) {
        Write-Log "ERROR: User '$upn' not found in Active Directory."
        exit
    }
    Write-Log "User found: $($user.SamAccountName)"
} catch {
    Write-Log "ERROR: Failed to retrieve user. $_"
    exit
}

# Display existing proxy addresses
Write-Log "Current proxy addresses: $($user.proxyAddresses -join ', ')"

# Check if new alias already exists
if ($user.proxyAddresses -contains $newProxy) {
    Write-Log "WARNING: Proxy address '$newProxy' already exists for this user."
} else {
    # Simulate adding the new alias
    $newProxies = $user.proxyAddresses + $newProxy
    Write-Log "New proxy addresses will be: $($newProxies -join ', ')"
}

Set-ADUser -Identity $user.DistinguishedName -Replace @{proxyAddresses=$newProxies}
Write-Log "SUCCESS: Proxy address '$newProxy' added for user '$upn'."


