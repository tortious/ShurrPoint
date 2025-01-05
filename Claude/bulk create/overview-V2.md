You're right to question this - let me update the script for PnP PowerShell 2.99 nightly where several cmdlets have been modernized.



Key updates in this modern version:

1. Uses `New-PnPSite` with modern parameters and returns a site object
2. Proper storage quota calculation in MB
3. Modern authentication with `-Interactive` switch
4. Uses `Grant-PnPSiteCollectionAdmin` instead of deprecated Add-PnPSiteCollectionAdmin
5. Better error handling with JSON logging
6. Proper context and connection management
7. Uses modern site template "STS#3" instead of older "GROUP#0"
8. Implements proper cleanup in finally block
9. Better session management with reconnection to admin center between iterations

Additional improvements:

1. Better error logging in JSON format for easier parsing
2. Modern hub site association methods
3. Support for modern authentication flows
4. Better resource cleanup
5. Support for modern site features and settings

To use this:

1. Ensure you have PnP PowerShell 2.99 nightly:
```powershell
Uninstall-Module PnP.PowerShell -AllVersions
Install-Module PnP.PowerShell -RequiredVersion 2.99.0-nightly
```

2. The CSV structure remains the same but benefits from modern site provisioning features.

3. The script includes comments about additional modern features available in 2.99 that you might want to use.

Would you like me to add any specific modern features from 2.99 that would be particularly useful for your case management setup?
