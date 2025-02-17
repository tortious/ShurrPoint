# HTTP Requests in Power Automate for SharePoint Case Management Automation

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Authentication Setup](#authentication-setup)
3. [Flow Configuration](#flow-configuration)
4. [HTTP Request Implementation](#http-request-implementation)
5. [Error Handling](#error-handling)
6. [Template Management](#template-management)
7. [Troubleshooting Guide](#troubleshooting-guide)

## Prerequisites

Before implementing the HTTP requests in Power Automate, ensure you have:

- An Azure-registered application with the following permissions:
  - Microsoft Graph API permissions:
    - Sites.FullControl.All
    - Directory.ReadWrite.All
  - SharePoint API permissions:
    - Sites.FullControl.All

## Authentication Setup

### Getting Required IDs and Secrets

1. **Tenant ID** (`{tenant-id}`):
   - Location: Azure Portal > Azure Active Directory > Properties
   - Look for "Directory (tenant) ID"
   - Required Permission: Global Admin or Azure AD Admin

2. **Client ID** (`{client-id}`):
   - Location: Azure Portal > App Registrations > Your App
   - Listed as "Application (client) ID"
   - Required Permission: Application Owner or Global Admin

3. **Client Secret** (`{client-secret}`):
   - Location: Azure Portal > App Registrations > Your App > Certificates & Secrets
   - Create a new client secret and save it immediately
   - Required Permission: Application Owner or Global Admin

### OAuth Token Configuration

```json
{
    "method": "POST",
    "uri": "https://login.microsoftonline.com/{tenant-id}/oauth2/v2.0/token",
    "headers": {
        "Content-Type": "application/x-www-form-urlencoded"
    },
    "body": {
        "client_id": "{client-id}",
        "client_secret": "{client-secret}",
        "grant_type": "client_credentials",
        "scope": "https://graph.microsoft.com/.default"
    }
}
```

## Flow Configuration

### Initial Flow Setup

1. Create a new flow with your desired trigger
2. Add an HTTP action for authentication
3. Parse the JSON response to extract the access token
4. Store the token in a variable for subsequent requests

### Dynamic Variables

Set up the following variables at the start of your flow:

```
CaseNumber: Trigger input or generated unique identifier
SiteId: Response from site creation step
TermSetId: Your predefined term set ID for managed metadata
```

## HTTP Request Implementation

### 1. Creating New Teams-Connected Site

Important: Using TEAM#0 instead of STS#3 is crucial for:
- Proper Microsoft Teams integration
- Modern SharePoint features
- Automatic Teams channel creation
- Group-connected permissions management
- Modern communication features

```json
{
    "method": "POST",
    "uri": "https://graph.microsoft.com/v1.0/sites/mordini-law.sharepoint.com:/sites/cases/teamsites",
    "headers": {
        "Authorization": "Bearer @{variables('accessToken')}",
        "Content-Type": "application/json"
    },
    "body": {
        "displayName": "Case Site - @{variables('CaseNumber')}",
        "template": "TEAM#0",
        "webUrl": "https://mordini-law.sharepoint.com/sites/cases/@{variables('CaseNumber')}"
    }
}
```

### 2. Applying Site Template

```json
{
    "method": "POST",
    "uri": "https://mordini-law.sharepoint.com/sites/cases/@{variables('CaseNumber')}/_api/sitepages/pages/CreateTemplateFromSite",
    "headers": {
        "Authorization": "Bearer @{variables('accessToken')}",
        "Content-Type": "application/json"
    },
    "body": {
        "templateName": "MordiniLawTemplate",
        "siteId": "@{variables('SiteId')}"
    }
}
```

### 3. Creating Document Libraries

```json
{
    "method": "POST",
    "uri": "https://mordini-law.sharepoint.com/sites/cases/@{variables('CaseNumber')}/_api/web/lists",
    "headers": {
        "Authorization": "Bearer @{variables('accessToken')}",
        "Content-Type": "application/json",
        "Accept": "application/json;odata=verbose"
    },
    "body": {
        "Title": "Case Pleadings",
        "BaseTemplate": 101,
        "ContentTypesEnabled": true
    }
}
```

Note: Repeat this request for each library (Discovery, Assignment Files)

### 4. Setting Up Managed Metadata

```json
{
    "method": "POST",
    "uri": "https://mordini-law.sharepoint.com/sites/cases/@{variables('CaseNumber')}/_api/web/lists/getbytitle('Case Pleadings')/fields",
    "headers": {
        "Authorization": "Bearer @{variables('accessToken')}",
        "Content-Type": "application/json"
    },
    "body": {
        "__metadata": {
            "type": "SP.Field"
        },
        "Title": "Case Category",
        "FieldTypeKind": 7,
        "Required": "true",
        "Group": "Case Management Columns",
        "TermSetId": "@{variables('TermSetId')}",
        "TextField": {
            "__metadata": {
                "type": "SP.taxonomy.TaxonomyFieldTypeMulti"
            }
        }
    }
}
```

### 5. Adding Navigation Links

```json
{
    "method": "POST",
    "uri": "https://mordini-law.sharepoint.com/sites/cases/@{variables('CaseNumber')}/_api/web/navigation/quicklaunch",
    "headers": {
        "Authorization": "Bearer @{variables('accessToken')}",
        "Content-Type": "application/json"
    },
    "body": {
        "__metadata": {
            "type": "SP.NavigationNode"
        },
        "Title": "Case Resources",
        "Url": "https://mordini-law.sharepoint.com/sites/cases/resources",
        "IsExternal": false
    }
}
```

## Error Handling

Implement error handling after each HTTP request:

```json
{
    "type": "If",
    "expression": "@not(equals(outputs('HTTP_Action')['statusCode'], 200))",
    "actions": {
        "Log_Error": {
            "type": "Compose",
            "inputs": "Error in step: @{actions('HTTP_Action')['inputs']['uri']} - @{outputs('HTTP_Action')['body']}"
        },
        "Send_Error_Notification": {
            "type": "Office365.SendEmail",
            "inputs": {
                "to": "admin@mordini-law.com",
                "subject": "Site Creation Error - Case @{variables('CaseNumber')}",
                "body": "@{outputs('Log_Error')}"
            }
        }
    }
}
```

## Template Management

### Finding the Site Template ID

1. Navigate to your template site
2. Access site settings
3. Look for the site template ID in the URL or settings page
4. Required Permission: Site Collection Administrator

### Dynamic Template Selection

```javascript
switch(triggerBody()?['CaseType']) {
    case "Corporate":
        return "TEMPLATE_ID_CORPORATE";
    case "Litigation":
        return "TEMPLATE_ID_LITIGATION";
    default:
        return "TEMPLATE_ID_DEFAULT";
}
```

## Troubleshooting Guide

Common issues and solutions:

1. **401 Unauthorized**
   - Check Azure app permissions
   - Verify client secret hasn't expired
   - Ensure proper scope in token request

2. **403 Forbidden**
   - Verify site collection admin rights
   - Check SharePoint admin permissions
   - Confirm API permissions in Azure

3. **404 Not Found**
   - Verify site URLs
   - Check if site exists
   - Confirm API endpoint versions

4. **500 Internal Server Error**
   - Review JSON formatting
   - Check for missing required fields
   - Verify template IDs exist

Remember to implement appropriate logging and monitoring to track the success and failure of each step in the process.