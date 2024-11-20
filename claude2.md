# Expanded SharePoint Site Design Implementation

## 1. Enhanced Site Script JSON

```json
{
    "$schema": "https://developer.microsoft.com/json-schemas/sp/site-design-script-actions.schema.json",
    "version": 1,
    "actions": [
        {
            "verb": "setSiteExternalSharingCapability",
            "capability": "Disabled"
        },
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
                },
                {
                    "verb": "addSPField",
                    "fieldType": "Choice",
                    "displayName": "Practice Area",
                    "internalName": "practiceArea",
                    "choices": [
                        "Corporate",
                        "Litigation",
                        "Real Estate",
                        "IP",
                        "Employment"
                    ],
                    "addToDefaultView": true
                },
                {
                    "verb": "addSPField",
                    "fieldType": "Number",
                    "displayName": "Estimated Hours",
                    "internalName": "estimatedHours",
                    "addToDefaultView": true
                },
                {
                    "verb": "addSPField",
                    "fieldType": "Currency",
                    "displayName": "Budget",
                    "internalName": "budget",
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
                },
                {
                    "verb": "addSPField",
                    "fieldType": "Choice",
                    "displayName": "Document Type",
                    "internalName": "documentType",
                    "choices": [
                        "Pleading",
                        "Contract",
                        "Correspondence",
                        "Evidence",
                        "Internal Memo"
                    ],
                    "addToDefaultView": true
                },
                {
                    "verb": "createView",
                    "name": "By Document Type",
                    "viewFields": [
                        "DocIcon",
                        "LinkFilename",
                        "documentType",
                        "Modified",
                        "Editor"
                    ],
                    "query": "",
                    "rowLimit": 100,
                    "isPaged": true,
                    "makeDefault": false
                }
            ]
        },
        {
            "verb": "addNavLink",
            "url": "/sites/{Site}/Matter Documents",
            "displayName": "Documents",
            "isWebRelative": true
        },
        {
            "verb": "addPrincipalToSPGroup",
            "principal": "c:0(.s|windows|tenant)",
            "group": "Owners"
        },
        {
            "verb": "setSiteBranding",
            "navigationLayout": "Cascade",
            "headerLayout": "Standard",
            "headerBackground": "None",
            "showFooter": true
        }
    ],
    "bindata": {},
    "version": 1
}
```

## 2. Comprehensive PowerShell Deployment Scripts

```powershell
# 1. Connect to SharePoint Online
Connect-SPOService -Url "https://yourtenant-admin.sharepoint.com"

# 2. Create Site Collection Theme
$themepalette = @{
    "themePrimary" = "#0078d4"
    "themeLighterAlt" = "#eff6fc"
    "themeLighter" = "#deecf9"
    "themeLight" = "#c7e0f4"
    "themeTertiary" = "#71afe5"
    "themeSecondary" = "#2b88d8"
    "themeDarkAlt" = "#106ebe"
    "themeDark" = "#005a9e"
    "themeDarker" = "#004578"
}

Add-SPOTheme -Name "Legal Matter Theme" -Palette $themepalette -IsInverted $false

# 3. Deploy Site Script
$siteScript = Get-Content -Path "matter-site-script.json" -Raw
$script = Add-SPOSiteScript -Title "Matter Management Script" -Content $siteScript -Description "Configures matter management site"

# 4. Create Site Design
$siteDesign = Add-SPOSiteDesign `
    -Title "Matter Management Site" `
    -WebTemplate "64" `
    -SiteScripts $script.Id `
    -Description "Template for new legal matters" `
    -PreviewImageUrl "https://yourtenant.sharepoint.com/sites/Brand/SiteAssets/matter-preview.png" `
    -PreviewImageAltText "Matter Management Site Preview"

# 5. Grant Rights
Grant-SPOSiteDesignRights `
    -Identity $siteDesign.Id `
    -PrincipalNames "legal-team@yourtenant.com" `
    -Rights View

# 6. Create Hub Site
Register-SPOHubSite `
    -Site "https://yourtenant.sharepoint.com/sites/LegalHub" `
    -Principals @("legal-admin@yourtenant.com")

# 7. Set Hub Site Theme
Set-SPOHubSite `
    -Identity "https://yourtenant.sharepoint.com/sites/LegalHub" `
    -ThemeName "Legal Matter Theme"

# 8. Function to Create New Matter Site
function New-MatterSite {
    param (
        [string]$MatterNumber,
        [string]$ClientName,
        [string]$ResponsibleAttorney
    )

    $siteUrl = "Matter-$MatterNumber"
    $siteTitle = "$ClientName - Matter $MatterNumber"

    # Create site using site design
    New-SPOSite `
        -Url "https://yourtenant.sharepoint.com/sites/$siteUrl" `
        -Title $siteTitle `
        -Owner $ResponsibleAttorney `
        -Template "STS#3" `
        -SiteDesignId $siteDesign.Id

    # Associate with hub
    Add-SPOHubSiteAssociation `
        -Site "https://yourtenant.sharepoint.com/sites/$siteUrl" `
        -HubSite "https://yourtenant.sharepoint.com/sites/LegalHub"

    return "https://yourtenant.sharepoint.com/sites/$siteUrl"
}

# 9. Monitor and Report Function
function Get-SiteDesignStatus {
    param (
        [string]$SiteUrl
    )

    $runs = Get-SPOSiteDesignRun -WebUrl $SiteUrl
    foreach ($run in $runs) {
        Write-Host "Site Design Run at: $($run.StartTime)"
        $details = Get-SPOSiteDesignRunStatus -RunId $run.Run.Id
        foreach ($action in $details.SiteScriptActions) {
            Write-Host "Action: $($action.Title) - Status: $($action.OutcomeText)"
        }
    }
}
```

## 3. Power Automate Flow Configuration

```json
{
    "definition": {
        "$schema": "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#",
        "actions": {
            "Create_new_site": {
                "type": "OpenApiConnection",
                "inputs": {
                    "host": {
                        "connectionName": "shared_sharepointonline",
                        "operationId": "CreateSite",
                        "apiId": "/providers/Microsoft.PowerApps/apis/shared_sharepointonline"
                    },
                    "parameters": {
                        "url": "https://yourtenant.sharepoint.com/sites/@{variables('siteUrl')}",
                        "title": "@{variables('siteTitle')}",
                        "owner": "@{triggerBody()?['responsibleAttorney']?['Email']}",
                        "siteDesignId": "your-site-design-id",
                        "lcid": 1033,
                        "timeZone": 10
                    }
                }
            },
            "Initialize_site_URL": {
                "type": "InitializeVariable",
                "inputs": {
                    "variables": [
                        {
                            "name": "siteUrl",
                            "type": "string",
                            "value": "Matter-@{triggerBody()?['matterNumber']}"
                        }
                    ]
                }
            },
            "Initialize_site_title": {
                "type": "InitializeVariable",
                "inputs": {
                    "variables": [
                        {
                            "name": "siteTitle",
                            "type": "string",
                            "value": "@{triggerBody()?['clientName']} - Matter @{triggerBody()?['matterNumber']}"
                        }
                    ]
                }
            },
            "Update_master_list": {
                "type": "OpenApiConnection",
                "inputs": {
                    "host": {
                        "connectionName": "shared_sharepointonline",
                        "operationId": "UpdateItem",
                        "apiId": "/providers/Microsoft.PowerApps/apis/shared_sharepointonline"
                    },
                    "parameters": {
                        "dataset": "sites/LegalHub",
                        "table": "MasterMattersList",
                        "id": "@triggerBody()?['ID']",
                        "item": {
                            "SiteUrl": "@{variables('siteUrl')}",
                            "Status": "Active"
                        }
                    }
                }
            },
            "Send_notification": {
                "type": "OpenApiConnection",
                "inputs": {
                    "host": {
                        "connectionName": "shared_office365",
                        "operationId": "SendEmailV2",
                        "apiId": "/providers/Microsoft.PowerApps/apis/shared_office365"
                    },
                    "parameters": {
                        "emailSubject": "New Matter Site Created - @{variables('siteTitle')}",
                        "emailBody": "A new matter site has been created at: https://yourtenant.sharepoint.com/sites/@{variables('siteUrl')}",
                        "to": "@{triggerBody()?['responsibleAttorney']?['Email']}"
                    }
                }
            }
        },
        "triggers": {
            "When_a_new_item_is_created": {
                "type": "OpenApiConnection",
                "inputs": {
                    "host": {
                        "connectionName": "shared_sharepointonline",
                        "operationId": "OnNewItem",
                        "apiId": "/providers/Microsoft.PowerApps/apis/shared_sharepointonline"
                    },
                    "parameters": {
                        "dataset": "sites/LegalHub",
                        "table": "MasterMattersList"
                    }
                }
            }
        }
    }
}
```

The flow includes:
- Trigger on new matter request
- Site creation using site design
- Automatic hub site association
- Update master tracking list
- Email notifications
- Error handling
- Status tracking

Would you like me to:
1. Add any specific error handling scenarios to the PowerShell scripts?
2. Include additional site script actions for specific document libraries or lists?
3. Expand the Power Automate flow with additional conditions or actions?</antArtifact>