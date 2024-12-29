# Complete Guide: Setting Up PowerShell PnP App Credentials

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Azure AD App Registration](#azure-ad-app-registration)
3. [Certificate Creation and Configuration](#certificate-creation-and-configuration)
4. [PowerShell Script Setup](#powershell-script-setup)
5. [Secure Storage Implementation](#secure-storage-implementation)
6. [Testing and Troubleshooting](#testing-and-troubleshooting)

## Prerequisites

Before beginning, ensure you have:
- PowerShell 5.1 or higher installed
- PnP PowerShell module installed (`Install-Module PnP.PowerShell`)
- Administrator access to your Azure AD tenant
- Permissions to register applications in Azure AD

## Azure AD App Registration

### Step 1: Create the Azure AD Application

1. Log in to the Azure Portal (https://portal.azure.com)
2. Navigate to Azure Active Directory → App registrations
3. Click "New registration"
4. Configure the following:
   - Name: `PnP-Automation` (or your preferred name)
   - Supported account types: "Accounts in this organizational directory only"
   - Redirect URI: Leave blank
5. Click "Register"

### Step 2: Configure API Permissions

1. In your new app registration:
   - Go to "API permissions"
   - Click "Add a permission"
   - Choose "SharePoint"
   - Select "Application permissions"
   - Add these permissions:
     - Sites.FullControl.All
     - TermStore.ReadWrite.All (if needed)
2. Click "Grant admin consent"

### Step 3: Record Important Values
- Application (client) ID
- Directory (tenant) ID

## Certificate Creation and Configuration

### Step 1: Create Self-Signed Certificate

```powershell
# Certificate creation script
$certName = "PnP-Automation-Cert"
$cert = New-SelfSignedCertificate -Subject "CN=$certName" `
    -CertStoreLocation "Cert:\CurrentUser\My" `
    -KeyExportPolicy Exportable `
    -KeySpec Signature `
    -KeyLength 2048 `
    -KeyAlgorithm RSA `
    -HashAlgorithm SHA256 `
    -NotAfter (Get-Date).AddYears(2)

# Export certificate to file
$certPassword = ConvertTo-SecureString -String "YourStrongPassword" -Force -AsPlainText
$certPath = "C:\Certificates"
New-Item -ItemType Directory -Path $certPath -Force
Export-PfxCertificate -Cert $cert -FilePath "$certPath\$certName.pfx" -Password $certPassword
Export-Certificate -Cert $cert -FilePath "$certPath\$certName.cer"
```

### Step 2: Upload Certificate to Azure AD

1. In your app registration:
   - Go to "Certificates & secrets"
   - Click "Upload certificate"
   - Upload the .cer file created above
2. Note the thumbprint displayed

## PowerShell Script Setup

### Step 1: Create Secure Credential Storage

```powershell
# Create encrypted credential file
$credentialPath = "C:\PnP-Automation\credentials"
New-Item -ItemType Directory -Path $credentialPath -Force

# Store app details securely
$appDetails = @{
    ClientId = "YOUR-CLIENT-ID"
    TenantId = "YOUR-TENANT-ID"
    Thumbprint = "YOUR-CERTIFICATE-THUMBPRINT"
    CertificatePath = "C:\Certificates\PnP-Automation-Cert.pfx"
    CertificatePassword = "YourStrongPassword"
}

# Convert to secure string and export
$secureAppDetails = ConvertTo-SecureString (ConvertTo-Json $appDetails) -AsPlainText -Force
$secureAppDetails | ConvertFrom-SecureString | Out-File "$credentialPath\appcreds.txt"
```

### Step 2: Create Connection Script

```powershell
function Connect-PnPSecure {
    # Load secure credentials
    $credentialPath = "C:\PnP-Automation\credentials\appcreds.txt"
    $encryptedCreds = Get-Content $credentialPath | ConvertTo-SecureString
    $appDetails = ConvertFrom-Json ([System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($encryptedCreds)))
    
    # Import certificate
    $certPassword = ConvertTo-SecureString $appDetails.CertificatePassword -AsPlainText -Force
    $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2(
        $appDetails.CertificatePath,
        $certPassword,
        [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable
    )
    
    # Connect to PnP
    try {
        Connect-PnPOnline -Url "https://yourtenant.sharepoint.com" `
            -ClientId $appDetails.ClientId `
            -Thumbprint $appDetails.Thumbprint `
            -Tenant $appDetails.TenantId `
            -ReturnConnection
        Write-Host "Successfully connected to SharePoint" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to connect: $_" -ForegroundColor Red
    }
}
```

## Secure Storage Implementation

### Best Practices for Credential Storage

1. **File System Security**
   - Store credentials in a restricted directory
   - Use NTFS permissions to limit access
   ```powershell
   $credentialPath = "C:\PnP-Automation\credentials"
   $acl = Get-Acl $credentialPath
   $acl.SetAccessRuleProtection($true, $false)
   $rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
       "SYSTEM", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow"
   )
   $acl.AddAccessRule($rule)
   $rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
       $env:USERNAME, "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow"
   )
   $acl.AddAccessRule($rule)
   Set-Acl $credentialPath $acl
   ```

2. **Certificate Security**
   - Store certificates in the Windows Certificate Store
   - Use restricted permissions on exported certificate files
   - Regularly rotate certificates (recommended every 6-12 months)

## Testing and Troubleshooting

### Common Issues and Solutions

1. **Certificate Issues**
   - Error: "Certificate not found"
     ```powershell
     # Verify certificate in store
     Get-ChildItem Cert:\CurrentUser\My | Where-Object {$_.Thumbprint -eq "YOUR-THUMBPRINT"}
     ```
   - Error: "Invalid certificate"
     - Ensure the certificate hasn't expired
     - Verify the thumbprint matches exactly (no spaces)

2. **Connection Issues**
   - Error: "Access denied"
     - Verify API permissions are correctly set
     - Check admin consent is granted
     - Validate tenant ID
   - Error: "Invalid client"
     - Verify client ID
     - Ensure app registration is active

### Verification Script

```powershell
function Test-PnPConnection {
    try {
        Connect-PnPSecure
        $web = Get-PnPWeb
        Write-Host "Successfully connected to: $($web.Title)" -ForegroundColor Green
        
        # Test basic operations
        $lists = Get-PnPList
        Write-Host "Successfully retrieved $($lists.Count) lists" -ForegroundColor Green
        
        Disconnect-PnPOnline
        Write-Host "Connection test completed successfully" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "Connection test failed: $_" -ForegroundColor Red
        return $false
    }
}
```

## Security Considerations

1. **Encryption**
   - All credentials are encrypted using Windows Data Protection API (DPAPI)
   - Certificate private keys are protected by Windows Certificate Store
   - Secure string objects are used for sensitive data in memory

2. **Access Control**
   - Implement strict NTFS permissions
   - Use app-only permissions where possible
   - Regular audit of access and permissions

3. **Monitoring**
   - Implement logging for connection attempts
   - Regular review of Azure AD sign-in logs
   - Monitor certificate expiration dates

## Maintenance and Updates

1. **Regular Tasks**
   - Certificate rotation schedule
   - Permission audit schedule
   - Credential backup procedures
   - Update notification system

2. **Documentation**
   - Keep detailed records of all configurations
   - Document emergency access procedures
   - Maintain update history