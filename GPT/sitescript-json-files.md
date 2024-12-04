# Site Script JSON Files

### 1. General Setup & Branding (`site-script-1.json`)
This site script sets the theme, logo, and basic navigation links.

```json
{
  "$schema": "https://developer.microsoft.com/json-schemas/sp/site-design-script-actions.schema.json",
  "actions": [
    {
      "verb": "applyTheme",
      "themeName": "LawFirmTheme"
    },
    {
      "verb": "setSiteLogo",
      "url": "YOUR_LOGO_URL"
    },
    {
      "verb": "setNavLink",
      "navigationType": "QuickLaunch",
      "displayName": "Hub Site",
      "url": "HUB_SITE_URL",
      "isWebRelative": false
    },
    {
      "verb": "setNavLink",
      "navigationType": "QuickLaunch",
      "displayName": "Case Management",
      "url": "CASE_MANAGEMENT_URL",
      "isWebRelative": false
    }
  ]
}
```

2. Document Libraries and Metadata (site-script-2.json)
This script creates a Document Library with custom metadata fields, useful for tracking case-specific details.

json
```
Copy code
{
  "actions": [
    {
      "verb": "createSPList",
      "listName": "Case Documents",
      "templateType": 101,
      "subactions": [
        { "verb": "setTitle", "title": "Case Documents" },
        { "verb": "addSPField", "fieldType": "Text", "displayName": "Case Number", "internalName": "CaseNumber", "isRequired": true },
        { "verb": "addSPField", "fieldType": "Choice", "displayName": "Case Status", "internalName": "CaseStatus", "choices": ["Open", "In Progress", "Closed"], "isRequired": true },
        { "verb": "addSPField", "fieldType": "DateTime", "displayName": "Case Opened Date", "internalName": "CaseOpenedDate" }
      ]
    }
  ]
}
```
3. Standard Web Parts (site-script-3.json)
This script adds standard web parts, like a document library view and a calendar.

json
Copy code
```
{
  "actions": [
    {
      "verb": "addSPList",
      "listName": "Case Calendar",
      "templateType": 106
    },
    {
      "verb": "addSPList",
      "listName": "Contacts",
      "templateType": 105,
      "subactions": [
        { "verb": "setTitle", "title": "Case Contacts" }
      ]
    }
  ]
}
```

Additional Customization with PowerShell (Optional)
Since SharePoint JSON scripting has limitations, you can use PnP PowerShell for more complex configurations like permissions. Below is a sample PowerShell script for setting permissions:
```
PowerShell Script Example
powershell
Copy code
```

# Connect to SharePoint

```
Connect-PnPOnline -Url "YOUR_SITE_URL" -UseWebLogin
```
# Set permissions

```
Add-PnPGroupMember -LoginName "Mark@yourcompany.com" -Group "Members"
Add-PnPGroupMember -LoginName "Jane@yourcompany.com" -Group "Visitors"
```
# Customize site columns, content types, or advanced elements

# Example: Adding custom permissions to a document library
```
Set-PnPListPermission -List "Case Documents" -Group "Mark" -AddRole "Contribute"
```

# Additional Notes

## Themes: Define the theme in the SharePoint admin center and refer to it in the JSON scripts above.

## Power Automate Workflows: Set up workflows in Power Automate to automate case tracking linked to your case document library.
Version Control: Use PnP PowerShell to apply version control for customizations and manage changes over time.
Summary
This setup provides a cohesive, repeatable site design with essential components—document libraries, metadata, web parts, and some basic branding and navigation. By combining site scripts with PnP PowerShell, you can create a solution tailored to your case management needs.

Copy code












