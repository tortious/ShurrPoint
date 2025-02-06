# SharePoint Custom GPT Integration Guide

## 1. Prerequisites

### 1.1 Required Permissions
- Global Administrator or SharePoint Administrator role in Microsoft 365
- Azure AD Administrator access
- Ability to create and manage app registrations in Azure AD
- SharePoint Online Management Shell access
- PnP PowerShell access

### 1.2 Environment Setup
- Microsoft 365 tenant with SharePoint Online
- Azure subscription associated with your Microsoft 365 tenant
- PowerShell 7.x or later installed
- Latest SharePoint Online Management Shell
- Latest PnP PowerShell module

## 2. Azure AD App Registration

### 2.1 Create App Registration
1. Navigate to Azure Portal (https://portal.azure.com)
2. Go to Azure Active Directory > App registrations
3. Click "New registration"
4. Configure basic settings:
```plaintext
Name: SharePoint-GPT-Assistant
Supported account types: Single tenant
Redirect URI: Web > https://your-domain.sharepoint.com
```

### 2.2 Configure API Permissions
1. In the app registration, go to "API permissions"
2. Add the following permissions:
```plaintext
Microsoft Graph:
- Sites.FullControl.All
- User.Read.All
- Group.ReadWrite.All
- Directory.ReadWrite.All

SharePoint:
- Sites.FullControl.All
- User.ReadWrite.All
- TermStore.ReadWrite.All
```

### 2.3 Generate Client Secret
1. Go to "Certificates & secrets"
2. Create new client secret:
```plaintext
Description: SharePoint-GPT-Integration
Expiry: 24 months (or as per your security policy)
```
3. **IMPORTANT**: Save the generated secret value immediately

### 2.4 Configure Authentication
1. Go to "Authentication"
2. Enable the following:
```plaintext
Allow public client flows: Yes
Supported account types: Single tenant
Access tokens: Enabled
ID tokens: Enabled
```

## 3. SharePoint Configuration

### 3.1 Register App Principal
Connect to SharePoint Online Management Shell:
```powershell
# Connect to SharePoint Admin Center
Connect-SPOService -Url "https://your-domain-admin.sharepoint.com"

# Register the app principal
$appId = "your-azure-ad-app-id"
$appSecret = "your-client-secret"

# Grant tenant-wide permissions
Register-SPOApplicationPrincipal `
    -ApplicationId $appId `
    -ApplicationSecret $appSecret `
    -DisplayName "SharePoint-GPT-Assistant" `
    -EnableAppOnlyPolicy
```

### 3.2 Configure Site Collection Permissions
```powershell
# Grant permissions to specific site collection
$siteUrl = "https://your-domain.sharepoint.com/sites/your-site"
Set-SPOSite -Identity $siteUrl -DenyAddAndCustomizePages $false

# Grant full control to the app
$realm = Get-SPOAuthRealm -ServiceEndpoint $siteUrl
$appIdentifier = "$appId@$realm"
Set-SPOSiteCollectionAppPrincipalRights `
    -Site $siteUrl `
    -AppPrincipal $appIdentifier `
    -Scope "Site Collection" `
    -Right "FullControl"
```

## 4. Custom GPT Configuration

### 4.1 Create Authentication Helper
```javascript
// auth-helper.js
const msal = require('@azure/msal-node');

const config = {
    auth: {
        clientId: "your-azure-ad-app-id",
        clientSecret: "your-client-secret",
        authority: "https://login.microsoftonline.com/your-tenant-id"
    }
};

const msalConfig = {
    auth: {
        clientId: config.auth.clientId,
        clientSecret: config.auth.clientSecret,
        authority: config.auth.authority
    }
};

const tokenRequest = {
    scopes: ["https://graph.microsoft.com/.default"]
};

const cca = new msal.ConfidentialClientApplication(msalConfig);

async function getToken() {
    try {
        const response = await cca.acquireTokenByClientCredential(tokenRequest);
        return response.accessToken;
    } catch (error) {
        console.error('Error acquiring token:', error);
        throw error;
    }
}

module.exports = { getToken };
```

### 4.2 SharePoint REST API Integration
```javascript
// sharepoint-service.js
const axios = require('axios');
const { getToken } = require('./auth-helper');

class SharePointService {
    constructor(siteUrl) {
        this.siteUrl = siteUrl;
        this.apiEndpoint = `${siteUrl}/_api`;
    }

    async getAuthenticatedClient() {
        const token = await getToken();
        return axios.create({
            baseURL: this.apiEndpoint,
            headers: {
                'Authorization': `Bearer ${token}`,
                'Accept': 'application/json;odata=verbose',
                'Content-Type': 'application/json;odata=verbose'
            }
        });
    }

    async createList(listName, fields) {
        const client = await this.getAuthenticatedClient();
        const response = await client.post('/web/lists', {
            __metadata: { type: 'SP.List' },
            Title: listName,
            BaseTemplate: 100,
            ContentTypesEnabled: true
        });
        
        // Add custom fields
        for (const field of fields) {
            await client.post(
                `/web/lists/getbytitle('${listName}')/fields`,
                {
                    __metadata: { type: 'SP.Field' },
                    Title: field.name,
                    FieldTypeKind: field.type
                }
            );
        }
        
        return response.data;
    }
}

module.exports = SharePointService;
```

## 5. Integration Testing

### 5.1 Test Connection
```javascript
// test-connection.js
const SharePointService = require('./sharepoint-service');

async function testConnection() {
    try {
        const sp = new SharePointService('https://your-domain.sharepoint.com');
        const client = await sp.getAuthenticatedClient();
        const response = await client.get('/web');
        console.log('Connection successful:', response.data.Title);
    } catch (error) {
        console.error('Connection failed:', error);
    }
}

testConnection();
```

### 5.2 Verify Permissions
```powershell
# PowerShell verification script
$appId = "your-azure-ad-app-id"
$siteUrl = "https://your-domain.sharepoint.com/sites/your-site"

# Get current permissions
Get-SPOSiteCollectionAppPrincipalRights -Site $siteUrl | 
    Where-Object { $_.AppPrincipalName -like "*$appId*" } |
    Format-Table -AutoSize
```

## 6. Error Handling and Monitoring

### 6.1 Implement Error Logging
```javascript
// logger.js
const winston = require('winston');

const logger = winston.createLogger({
    level: 'info',
    format: winston.format.combine(
        winston.format.timestamp(),
        winston.format.json()
    ),
    transports: [
        new winston.transports.File({ filename: 'error.log', level: 'error' }),
        new winston.transports.File({ filename: 'combined.log' })
    ]
});

module.exports = logger;
```

### 6.2 Monitor API Usage
```javascript
// monitoring.js
const { ApplicationInsights } = require('@microsoft/applicationinsights-web');

const appInsights = new ApplicationInsights({
    config: {
        instrumentationKey: 'your-instrumentation-key',
        enableAutoRouteTracking: true
    }
});

appInsights.loadAppInsights();
appInsights.trackPageView();

module.exports = appInsights;
```

## 7. Security Best Practices

### 7.1 Certificate-Based Authentication
```powershell
# Generate self-signed certificate
$cert = New-SelfSignedCertificate `
    -Subject "CN=SharePoint-GPT-Assistant" `
    -CertStoreLocation "Cert:\CurrentUser\My" `
    -KeyExportPolicy Exportable `
    -KeySpec Signature `
    -KeyLength 2048 `
    -KeyAlgorithm RSA `
    -HashAlgorithm SHA256

# Export certificate
$certPath = "C:\Certificates\SharePoint-GPT-Assistant.cer"
Export-Certificate -Cert $cert -FilePath $certPath

# Upload to Azure AD app registration
```

### 7.2 Implement Throttling
```javascript
// rate-limiter.js
const rateLimit = require('express-rate-limit');

const limiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 100, // Limit each IP to 100 requests per windowMs
    message: 'Too many requests from this IP, please try again later.'
});

module.exports = limiter;
```

## 8. Maintenance and Updates

### 8.1 Regular Certificate Rotation
```powershell
# Schedule in Task Scheduler
$action = New-ScheduledTaskAction -Execute 'PowerShell.exe' `
    -Argument '-File "C:\Scripts\rotate-certificates.ps1"'
$trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Monday -At 3am
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "RotateGPTCerts"
```

### 8.2 Permission Audit
```powershell
# Audit script
function Audit-AppPermissions {
    param(
        [string]$appId,
        [string]$tenantUrl
    )
    
    Connect-SPOService -Url $tenantUrl
    
    $sites = Get-SPOSite -Limit All
    foreach ($site in $sites) {
        Get-SPOSiteCollectionAppPrincipalRights -Site $site.Url |
            Where-Object { $_.AppPrincipalName -like "*$appId*" } |
            Export-Csv -Path "AppPermissionsAudit.csv" -Append -NoTypeInformation
    }
}
```

## 9. Troubleshooting Guide

### 9.1 Common Issues and Solutions
1. Authentication Failures
```javascript
// Test authentication
async function testAuth() {
    try {
        const token = await getToken();
        console.log('Token acquired successfully');
        return true;
    } catch (error) {
        console.error('Authentication failed:', error.message);
        return false;
    }
}
```

2. Permission Issues
```powershell
# Verify app permissions
Get-SPOAppPrincipalPermission -Site $siteUrl | 
    Format-Table -AutoSize Principal, Scope, Resource, Right
```

### 9.2 Diagnostic Tools
```javascript
// health-check.js
async function performHealthCheck() {
    const checks = {
        auth: await testAuth(),
        api: await testApiConnection(),
        permissions: await validatePermissions()
    };
    
    return {
        status: Object.values(checks).every(Boolean) ? 'healthy' : 'unhealthy',
        details: checks
    };
}
```