# Modern SharePoint Site Design Implementation for Matter Management

## Part 1: Site Script Development

1. **Create Base Site Script JSON**
```json
{
    "$schema": "https://developer.microsoft.com/json-schemas/sp/site-design-script-actions.schema.json",
    "version": 1,
    "actions": [
        {
            "verb": "createSPList",
            "listName": "Matter Details",
            "templateType": 100,
            "subactions": [
                {
                    "verb": "setTitle",
                    "title": "Matter Details"
                },
                {
                    "verb": "addSPField",
                    "fieldType": "Text",
                    "displayName": "Matter Number",
                    "internalName": "matterNumber",
                    "isRequired": true,
                    "addToDefaultView": true
                },
                {
                    "verb": "addSPField",
                    "fieldType": "Text",
                    "displayName": "Client Name",
                    "internalName": "clientName",
                    "isRequired": true,
                    "addToDefaultView": true
                },
                {
                    "verb": "addSPField",
                    "fieldType": "User",
                    "displayName": "Responsible Attorney",
                    "internalName": "responsibleAttorney",
                    "isRequired": true,
                    "addToDefaultView": true
                },
                {
                    "verb": "addSPField",
                    "fieldType": "Choice",
                    "displayName": "Matter Status",
                    "internalName": "matterStatus",
                    "choices": ["Active", "Pending", "Closed"],
                    "addToDefaultView": true
                }
            ]
        },
        {
            "verb": "createSPList",
            "listName": "Key Dates",
            "templateType": 100,
            "subactions": [
                {
                    "verb": "setTitle",
                    "title": "Key Dates"
                },
                {
                    "verb": "addSPField",
                    "fieldType": "DateTime",
                    "displayName": "Deadline",
                    "internalName": "deadline",
                    "isRequired": true,
                    "addToDefaultView": true
                }
            ]
        },
        {
            "verb": "createDocumentLibrary",
            "libraryName": "Matter Documents",
            "subactions": [
                {
                    "verb": "addContentType",
                    "name": "Legal Document"
                }
            ]
        },
        {
            "verb": "setSiteExternalSharingCapability",
            "capability": "Disabled"
        },
        {
            "verb": "triggerFlow",
            "flowId": "",
            "name": "Matter Site Provisioning Flow"
        }
    ]
}
```

2. **Deploy Site Script Using PowerShell**
```powershell
# Connect to SharePoint Online
Connect-SPOService -Url "https://yourtenant-admin.sharepoint.com"

# Add the site script
$siteScript = Get-Content -Path "matter-site-script.json" -Raw
$scriptResult = Add-SPOSiteScript -Title "Matter Management Script" -Content $siteScript

# Create site design
Add-SPOSiteDesign `
    -Title "Matter Management Site" `
    -WebTemplate "64" `
    -SiteScripts $scriptResult.Id `
    -Description "Template for new legal matters"
```

## Part 2: Power Automate Integration

1. **Create Power Automate Flow for Site Provisioning**
   - Trigger: When a new item is created in a master matters list
   - Actions:
     ```
     1. Create site using site design
     2. Update site properties
     3. Configure additional permissions
     4. Update master tracking list with new site URL
     ```

2. **Create Hub Site Configuration**
   - Register main site as hub site using PowerShell:
     ```powershell
     Register-SPOHubSite -Site "https://yourtenant.sharepoint.com/sites/LegalHub"
     ```
   - Associate matter sites with hub automatically in flow

## Part 3: Quick Creation System

1. **Create Power Apps Form**
```powershell
# Grant permissions to Power Apps
Grant-SPOSiteDesignRights `
    -Identity $siteDesign.Id `
    -PrincipalNames "everyone@yourtenant.com" `
    -Rights View
```

2. **Power Apps Component**
   - Form fields:
     - Matter Number (auto-generated)
     - Client Name
     - Matter Description
     - Practice Area
     - Responsible Attorney
   - Integration with Power Automate flow
   - Embedded in SharePoint page

## Part 4: Site Design Enhancement

1. **Add Theme**
```json
{
    "verb": "applyTheme",
    "themeName": "Legal Matter Theme"
}
```

2. **Navigation Setup**
```json
{
    "verb": "navigation",
    "navigation": [
        {
            "displayName": "Home",
            "url": "~site/SitePages/Home.aspx"
        },
        {
            "displayName": "Matter Documents",
            "url": "~site/Matter Documents"
        }
    ]
}
```

## Part 5: PowerShell Management Scripts

1. **Apply Site Design to Existing Sites**
```powershell
# Get site design ID
$siteDesignId = (Get-SPOSiteDesign | Where-Object {$_.Title -eq "Matter Management Site"}).Id

# Apply to specific site
Invoke-SPOSiteDesign `
    -Identity $siteDesignId `
    -WebUrl "https://yourtenant.sharepoint.com/sites/Matter123"
```

2. **Monitor Site Design Application**
```powershell
# Get site design runs
Get-SPOSiteDesignRun `
    -WebUrl "https://yourtenant.sharepoint.com/sites/Matter123"
```

## Best Practices

1. **Version Control**
   - Maintain site scripts in source control
   - Document all changes
   - Test in development tenant first

2. **Security**
   - Use PnP PowerShell for sensitive operations
   - Implement least-privilege access
   - Regular security reviews

3. **Maintenance**
   - Regular script updates
   - Monitor site design success rates
   - Regular backup of scripts and configurations

4. **Performance**
   - Limit number of actions in single script
   - Use batch operations where possible
   - Monitor flow execution times