pt for SharePoint Setup

Creating a comprehensive site design and site script for your SharePoint setup requires a detailed blueprint. Since you’re managing civil defense law cases with a small team in a structured SharePoint environment, the design will focus on consistency, ease of access, and automation where possible. I’ll outline a setup that covers your needs:

- **Consistent Branding and Theme**
- **Document Libraries for Case Management**
- **Basic Permissions Setup for the Team**
- **Navigation Links to Hub Sites**
- **Custom Columns for Metadata**
- **Automated Case Status Tracking**
- **Standard Web Parts**

## Site Design JSON File

The site design JSON references one or more site scripts. Here’s a basic outline for your site design JSON:

```json
{
  "$schema": "https://developer.microsoft.com/json-schemas/sp/site-design-script-actions.schema.json",
  "id": "your-site-design-id",
  "version": 1,
  "siteScript": [
    {
      "title": "Law Firm Case Template",
      "description": "Site design for case management in SharePoint Online.",
      "siteScriptIds": [
        "your-site-script-id-1",
        "your-site-script-id-2"
      ],
      "webTemplate": "64", // Team Site (or use "68" for Communication Site)
      "previewImageAltText": "Law Firm Case Template",
      "isDefault": false
    }
  ]
}


# Site Script JSON Files

## 1. General Setup & Branding (site-script-1.json)

This site script will set the theme, logo and basic navigation links. 

{
  "$schema": "https://developer.microsoft.com/json-schemas/sp/site-design-script-actions.schema.json",
  "actions": [
    {
      "verb": "applyTheme",
      "themeName": "LawFirmTheme"
    },
    {
      "verb": "setSiteLogo",
      "url": "https://yourcompany.sharepoint.com/sites/branding/logo.png"
    },
    {
      "verb": "setNavLink",
      "navigationType": "QuickLaunch",
      "displayName": "Hub Site",
      "url": "https://yourcompany.sharepoint.com/sites/hubsite",
      "isWebRelative": false
    },
    {
      "verb": "setNavLink",
      "navigationType": "QuickLaunch",
      "displayName": "Case Management",
      "url": "https://yourcompany.sharepoint.com/sites/casemanagement",
      "isWebRelative": false
    }
  ]
}

## 2. Document Libraries and Metadata (site-script-2.json)

This site script will create a Document Library with custom metadata fields, useful for tracking case-specific details.

{
  "actions": [
    {
      "verb": "createSPList",
      "listName": "Case Documents",
      "templateType": 101,
      "subactions": [
        {
          "verb": "setTitle",
          "title": "Case Documents"
        },
        {
          "verb": "addSPField",
          "fieldType": "Text",
          "displayName": "Case Number",
          "internalName": "CaseNumber",
          "isRequired": true
        },
        {
          "verb": "addSPField",
          "fieldType": "Choice",
          "displayName": "Case Status",
          "internalName": "CaseStatus",
          "choices": [
            "Open",
            "In Progress",
            "Closed"
          ],
          "isRequired": true
        },
        {
          "verb": "addSPField",
          "fieldType": "DateTime",
          "displayName": "Case Opened Date",
          "internalName": "CaseOpenedDate"
        }
      ]
    }
  ]
}



## 3. Standard Web Parts (site-script-3.json)

This script includes standard web parts, like a document library view and calendar.

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
        {
          "verb": "setTitle",
          "title": "Case Contacts"
        }
      ]
    }
  ]
}




## Additional Customization with PowerShell (Optional)

Since SharePoint’s JSON scripting has limitations, use PnP PowerShell for more complex configurations like permissions. Here’s a sample PowerShell script for setting permissions:

# Connect to SharePoint
Connect-PnPOnline -Url "https://yourcompany.sharepoint.com/sites/YourSite" -UseWebLogin

# Set permissions
Add-PnPGroupMember -LoginName "Mark@yourcompany.com" -Group "Members"
Add-PnPGroupMember -LoginName "Jane@yourcompany.com" -Group "Visitors"

# Customize site columns, content types, or advanced elements
# Example: Adding custom permissions to a document library
Set-PnPListPermission -List "Case Documents" -Group "Mark" -AddRole "Contribute"


## Additional Notes

### Themes: You’ll need to define the theme in the SharePoint admin center and refer to it in the JSON.

### Power Automate Workflows: For automated case tracking, set up workflows in Power Automate and link them to your case document library.

### Version Control: Use PnP PowerShell to version control customizations and manage changes over time.
Summary
This setup gives you a cohesive, repeatable site design with all essential components—document libraries, metadata, web parts, and some basic branding and navigation. It combines site scripts with PnP PowerShell for a solution tailored to your case management needs.

