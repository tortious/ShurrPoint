# 1. Site Template Creation Using PnP PowerShell

# Connect to SharePoint Online
Connect-PnPOnline -Url "https://yourtenant.sharepoint.com/sites/YourSite" -Interactive

# Create site script JSON
$siteScript = @{
    "$schema" = "schema.json";
    "actions" = @(
        # Apply branding
        @{
            "verb" = "applyTheme"
            "themeName" = "Ferragamo"
        }
        @{
            "verb" = "setRegionalSettings"
            "timeZone" = 20 # Central Time
            "locale" = 1033 # US English
        }
        # Create CLARK list
        @{
            "verb" = "createSPList"
            "listName" = "CLARK"
            "templateType" = 100
            "subactions" = @(
                @{
                    "verb" = "addContentType"
                    "name" = "CaseItem"
                }
                @{
                    "verb" = "addSPField"
                    "fieldType" = "TaxonomyField"
                    "displayName" = "CaseName"
                    "internalName" = "CaseName"
                    "isRequired" = $true
                    "termSetId" = "your-termset-id"
                }
                # Add other fields as per your requirements
            )
        }
        # Create Casefiles document library
        @{
            "verb" = "createSPList"
            "listName" = "Casefiles"
            "templateType" = 101
            "subactions" = @(
                @{
                    "verb" = "addContentType"
                    "name" = "PleadingsCook"
                }
                # Add fields similar to CLARK list
            )
        }
        # Add navigation
        @{
            "verb" = "addNavLink"
            "url" = "/sites/CaseMgmt"
            "displayName" = "Case Mgmt"
            "isWebRelative" = $true
        }
        # Additional navigation items...
    )
}

# Convert to JSON and save
$siteScript | ConvertTo-Json -Depth 10 | Out-File "SiteScript.json"

# Add site script to tenant
$script = Add-PnPSiteScript -Title "Legal Case Management" -Description "Template for legal case sites" -Content (Get-Content "SiteScript.json" -Raw)

# Create site design
Add-PnPSiteDesign -Title "Legal Case Site" -Description "Creates a legal case management site" -SiteScriptIds $script.Id -WebTemplate "64" # 64 is team site template

# 2. SPFx Button Implementation
# Create new SPFx solution
yo @microsoft/sharepoint

# Add React component for button
# Component code will be in separate file

# 3. Flow Implementation
# Power Automate flow for site creation
# Trigger: When a new item is created in JEFF list
# Actions:
# 1. Create new site using site design
# 2. Update JEFF list with new site URL
# 3. Associate with Case Management hub
# 4. Initialize default content

# Create flow using Power Automate Desktop or cloud flow
$flowDefinition = @{
    "name" = "Create Case Site"
    "trigger" = @{
        "type" = "When an item is created"
        "inputs" = @{
            "list" = "JEFF"
            "site" = "https://yourtenant.sharepoint.com/sites/CaseManagement"
        }
    }
    "actions" = @{
        "Create_site" = @{
            "type" = "HTTP"
            "inputs" = @{
                "uri" = "/_api/SPSiteManager/create"
                "method" = "POST"
                "body" = @{
                    "Title" = "@{triggerBody()?['Title']}"
                    "Url" = "@{concat(variables('BaseSiteUrl'), triggerBody()?['CaseNumber'])}"
                    "WebTemplate" = "64"
                    "SiteDesignId" = "your-site-design-id"
                }
            }
        }
    }
}
