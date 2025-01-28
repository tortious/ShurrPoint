# Comprehensive Guide to Secure Credential Management in Azure

## Introduction

Proper credential management is crucial for maintaining security in Azure environments. This guide covers best practices for storing and managing credentials using Azure Key Vault, Managed Identities, and related security features.

## 1. Azure Key Vault Setup

### Prerequisites

1. Azure subscription
2. Azure CLI or Azure PowerShell installed
3. Appropriate permissions (Contributor or higher at subscription level)

### Creating a Key Vault

Using Azure PowerShell:

```powershell
# Set variables
$resourceGroupName = "YourResourceGroup"
$location = "eastus"
$keyVaultName = "YourKeyVaultName"

# Create Resource Group if it doesn't exist
New-AzResourceGroup -Name $resourceGroupName -Location $location

# Create Key Vault
New-AzKeyVault `
    -Name $keyVaultName `
    -ResourceGroupName $resourceGroupName `
    -Location $location `
    -EnabledForTemplateDeployment `
    -EnabledForDiskEncryption `
    -EnabledForDeployment `
    -EnableRbacAuthorization $true
```

Using Azure CLI:

```bash
# Set variables
resourceGroupName="YourResourceGroup"
location="eastus"
keyVaultName="YourKeyVaultName"

# Create Resource Group
az group create --name $resourceGroupName --location $location

# Create Key Vault
az keyvault create \
    --name $keyVaultName \
    --resource-group $resourceGroupName \
    --location $location \
    --enable-rbac-authorization true
```

## 2. Storing Different Types of Credentials

### Secrets

```powershell
# Store a secret
$secretValue = ConvertTo-SecureString "YourSecretValue" -AsPlainText -Force
Set-AzKeyVaultSecret `
    -VaultName $keyVaultName `
    -Name "SecretName" `
    -SecretValue $secretValue

# Store connection string
$connectionString = ConvertTo-SecureString "Server=myserver;Database=mydb;User Id=admin;Password=password;" -AsPlainText -Force
Set-AzKeyVaultSecret `
    -VaultName $keyVaultName `
    -Name "SqlConnectionString" `
    -SecretValue $connectionString
```

### Certificates

```powershell
# Import a certificate
$certificatePath = "C:\Certificates\MyCert.pfx"
$certificatePassword = ConvertTo-SecureString -String "CertPassword" -AsPlainText -Force

Import-AzKeyVaultCertificate `
    -VaultName $keyVaultName `
    -Name "CertificateName" `
    -FilePath $certificatePath `
    -Password $certificatePassword
```

### SSH Keys

```powershell
# Generate and store SSH key
$sshKey = ssh-keygen -t rsa -b 4096 -f ./id_rsa -N '""'
$publicKey = Get-Content ./id_rsa.pub
$privateKey = Get-Content ./id_rsa | ConvertTo-SecureString -AsPlainText -Force

Set-AzKeyVaultSecret `
    -VaultName $keyVaultName `
    -Name "SSHPublicKey" `
    -SecretValue (ConvertTo-SecureString $publicKey -AsPlainText -Force)

Set-AzKeyVaultSecret `
    -VaultName $keyVaultName `
    -Name "SSHPrivateKey" `
    -SecretValue $privateKey
```

## 3. Setting Up Managed Identities

### System-Assigned Managed Identity

```powershell
# Enable system-assigned managed identity for an Azure Web App
Set-AzWebApp `
    -ResourceGroupName $resourceGroupName `
    -Name "YourWebAppName" `
    -AssignIdentity $true

# Get the principal ID
$principalId = (Get-AzWebApp -ResourceGroupName $resourceGroupName -Name "YourWebAppName").Identity.PrincipalId
```

### User-Assigned Managed Identity

```powershell
# Create user-assigned managed identity
New-AzUserAssignedIdentity `
    -ResourceGroupName $resourceGroupName `
    -Name "YourManagedIdentity"

# Assign to a Web App
$identity = Get-AzUserAssignedIdentity `
    -ResourceGroupName $resourceGroupName `
    -Name "YourManagedIdentity"

Update-AzWebApp `
    -ResourceGroupName $resourceGroupName `
    -Name "YourWebAppName" `
    -IdentityType UserAssigned `
    -IdentityID $identity.Id
```

## 4. Access Policies and RBAC

### Setting Up RBAC for Key Vault

```powershell
# Get managed identity object ID
$objectId = (Get-AzADServicePrincipal -DisplayName "YourManagedIdentity").Id

# Assign Key Vault Secrets User role
New-AzRoleAssignment `
    -ObjectId $objectId `
    -RoleDefinitionName "Key Vault Secrets User" `
    -Scope "/subscriptions/{subscription-id}/resourceGroups/$resourceGroupName/providers/Microsoft.KeyVault/vaults/$keyVaultName"
```

### Access Policy Configuration (Legacy Method)

```powershell
# Set access policy
Set-AzKeyVaultAccessPolicy `
    -VaultName $keyVaultName `
    -ObjectId $objectId `
    -PermissionsToSecrets get,list `
    -PermissionsToCertificates get,list `
    -PermissionsToKeys get,list
```

## 5. Accessing Credentials in Applications

### .NET Core Example

```csharp
// Program.cs
public static IHostBuilder CreateHostBuilder(string[] args) =>
    Host.CreateDefaultBuilder(args)
        .ConfigureAppConfiguration((context, config) =>
        {
            var builtConfig = config.Build();
            
            var keyVaultEndpoint = new Uri($"https://{builtConfig["KeyVaultName"]}.vault.azure.net/");
            
            config.AddAzureKeyVault(keyVaultEndpoint, 
                new DefaultAzureCredential());
        });

// Usage in a service
public class MyService
{
    private readonly string _connectionString;
    
    public MyService(IConfiguration configuration)
    {
        _connectionString = configuration["SqlConnectionString"];
    }
}
```

### PowerShell Example

```powershell
# Get secret using managed identity
$secret = Get-AzKeyVaultSecret `
    -VaultName $keyVaultName `
    -Name "SecretName" `
    -AsPlainText
```

## 6. Monitoring and Auditing

### Enable Diagnostic Logging

```powershell
# Enable diagnostics
$workspace = Get-AzOperationalInsightsWorkspace `
    -ResourceGroupName "LogAnalyticsRG" `
    -Name "YourWorkspace"

Set-AzDiagnosticSetting `
    -ResourceId (Get-AzKeyVault -VaultName $keyVaultName).ResourceId `
    -WorkspaceId $workspace.ResourceId `
    -Enabled $true `
    -Category AuditEvent
```

### Monitor Access Attempts

```powershell
# Query for failed access attempts
$query = @"
AzureDiagnostics
| where ResourceType == "VAULTS"
| where OperationName == "VaultGet" or OperationName == "VaultPut"
| where ResultType == "Failed"
"@

Get-AzOperationalInsightsSearchResult `
    -WorkspaceName "YourWorkspace" `
    -Query $query
```

## 7. Best Practices

1. **Credential Rotation**
   - Implement automated credential rotation
   - Use Azure Automation for scheduling
   - Set expiration dates on secrets

2. **Network Security**
   - Enable Azure Private Link
   - Restrict network access
   - Use service endpoints

3. **Access Control**
   - Follow principle of least privilege
   - Regular access reviews
   - Use Managed Identities whenever possible

4. **Backup and Recovery**
   - Regular Key Vault backups
   - Document recovery procedures
   - Test recovery processes

## 8. Security Recommendations

1. **Enable Soft Delete and Purge Protection**
```powershell
Update-AzKeyVault `
    -VaultName $keyVaultName `
    -EnableSoftDelete $true `
    -EnablePurgeProtection $true
```

2. **Enable Advanced Threat Protection**
```powershell
Update-AzKeyVault `
    -VaultName $keyVaultName `
    -EnablePurgeProtection $true
```

3. **Network Security**
```powershell
# Configure network rules
$networkRule = New-AzKeyVaultNetworkRuleSetObject `
    -DefaultAction Deny `
    -Bypass AzureServices `
    -IpAddressRange "1.2.3.4/32"

Update-AzKeyVault `
    -VaultName $keyVaultName `
    -NetworkRuleSet $networkRule
```

## 9. Troubleshooting

Common issues and solutions:

1. **Access Denied**
   - Verify managed identity is properly configured
   - Check RBAC assignments
   - Verify network access rules

2. **Certificate Issues**
   - Verify certificate format
   - Check expiration dates
   - Confirm proper import process

3. **Performance Issues**
   - Monitor Key Vault metrics
   - Check throttling limits
   - Implement proper caching

Remember to always follow the principle of least privilege and regularly audit access to your Key Vault. Implement proper monitoring and alerting to detect and respond to security incidents quickly.