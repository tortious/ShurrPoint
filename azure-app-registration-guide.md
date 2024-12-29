# Azure/Entra ID App Registration Guide

## Prerequisites

Before starting, ensure you have:
- Global Administrator or Application Administrator role in your Azure/Entra tenant
- Access to Azure Portal (portal.azure.com)
- A clear understanding of your app's required permissions

## Conceptual Overview

Think of app registration like getting a passport for your application:
- **Application (Client) ID**: Like a passport number - uniquely identifies your app
- **Directory (Tenant) ID**: Your country of origin - identifies your Azure/Entra tenant
- **Client Secret/Certificate**: Like a visa - proves your app's identity
- **API Permissions**: Similar to visa permissions - what your app is allowed to do

## Step-by-Step Registration Process

### 1. Navigate to App Registrations
1. Log into Azure Portal (portal.azure.com)
2. Search for "App registrations" in the top search bar
3. Select "App registrations" under Services

### 2. Create New Registration
1. Click "New registration"
2. Configure basic settings:
   ```
   Name: [Your App Name]
   Supported account types: Choose based on access needs
   - Single tenant: Your organization only
   - Multi-tenant: Any Azure AD directory
   - Multi-tenant + personal: Include personal Microsoft accounts
   
   Redirect URI (Optional): 
   - Web: https://your-app-url
   - Single-page application: https://your-spa-url
   - Mobile/desktop: custom URI scheme
   ```

### 3. Configure Authentication
1. After registration, go to "Authentication" in left menu
2. Configure platform settings:
   - Web applications: Add redirect URIs
   - Single-page applications: Add CORS origins
   - Mobile/desktop: Configure custom redirect URIs
3. Advanced settings:
   ```
   Access tokens: Enable if your app needs access tokens
   ID tokens: Enable for OpenID Connect flows
   Continuous access evaluation: Enable for real-time token revocation
   ```

### 4. Set Up API Permissions
1. Navigate to "API permissions"
2. Click "Add a permission"
3. Common permission sets:
   ```
   Microsoft Graph:
   - User.Read: Basic user profile
   - Mail.Send: Send emails
   - Sites.Read.All: SharePoint site access
   
   SharePoint:
   - Sites.FullControl.All: Full SharePoint access
   - TermStore.Read.All: Taxonomy access
   ```

### 5. Create Client Secrets
1. Go to "Certificates & secrets"
2. Click "New client secret"
3. Set expiration:
   ```
   Recommended durations:
   - 6 months for development
   - 12 months for production
   - 24 months maximum
   ```
   
⚠️ CRITICAL: Copy and securely store the secret value immediately. It won't be shown again.

### 6. Configure Token Configuration (Optional)
1. Navigate to "Token configuration"
2. Add optional claims if needed:
   ```
   ID Token:
   - email
   - preferred_username
   
   Access Token:
   - upn
   - groups
   ```

## Security Best Practices

1. Secret Management:
   ```powershell
   # Store secrets in Azure Key Vault
   $secret = @{
       Name = "AppSecret"
       Value = "your-secret-value"
       ContentType = "text/plain"
       ExpiresOn = (Get-Date).AddMonths(6)
   }
   Set-AzKeyVaultSecret @secret
   ```

2. Certificate Usage:
   ```powershell
   # Generate self-signed cert
   $cert = New-SelfSignedCertificate -Subject "CN=YourAppName" -CertStoreLocation "Cert:\CurrentUser\My" -KeyExportPolicy Exportable -KeySpec Signature -KeyLength 2048 -KeyAlgorithm RSA -HashAlgorithm SHA256
   ```

3. Permission Management:
   - Use least privilege principle
   - Regularly audit permissions
   - Remove unused permissions
   - Document all permission requests

## Common Issues and Solutions

1. Invalid redirect URI:
   ```
   Error: AADSTS50011
   Solution: Ensure URI matches exactly in both app registration and code
   ```

2. Insufficient permissions:
   ```
   Error: Unauthorized
   Solution: Check if app has required permissions and admin consent
   ```

3. Invalid client secret:
   ```
   Error: AADSTS7000215
   Solution: Verify secret hasn't expired and is correctly copied
   ```

## Integration Examples

### 1. SharePoint Connection
```javascript
const siteUrl = "https://yourtenant.sharepoint.com";
const clientId = "your-client-id";
const clientSecret = "your-client-secret";

const getAccessToken = async () => {
    const authority = "https://login.microsoftonline.com/your-tenant-id";
    const resource = "https://yourtenant.sharepoint.com";
    
    // Use MSAL or similar library for token acquisition
    const authResult = await getToken();
    return authResult.accessToken;
};
```

### 2. Power Automate Connection
```json
{
    "type": "authentication",
    "inputs": {
        "authority": "https://login.microsoftonline.com",
        "clientId": "your-client-id",
        "secret": "@parameters('clientSecret')",
        "tenant": "your-tenant-id",
        "audience": "https://yourtenant.sharepoint.com"
    }
}
```

## Monitoring and Maintenance

1. Regular Tasks:
   - Review and rotate secrets before expiration
   - Audit app permissions quarterly
   - Monitor app usage and performance
   - Update redirect URIs for environment changes

2. Diagnostic Settings:
   ```json
   {
       "diagnosticSettings": {
           "workspaceId": "your-workspace-id",
           "logs": [
               {
                   "category": "SignInLogs",
                   "enabled": true
               },
               {
                   "category": "AuditLogs",
                   "enabled": true
               }
           ]
       }
   }
   ```

## Decommissioning Process

1. Gradual Shutdown:
   - Disable new sign-ins
   - Notify users
   - Remove permissions
   - Delete registration

2. Cleanup Checklist:
   ```
   □ Revoke all client secrets
   □ Remove API permissions
   □ Delete app registration
   □ Update dependent applications
   □ Document removal in system inventory
   ```
