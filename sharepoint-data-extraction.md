# SharePoint List Data Extraction Guide

## Method 1: PnP PowerShell (Recommended for Automation)

### Setup and Authentication
```powershell
# Install PnP PowerShell if not already installed
Install-Module -Name "PnP.PowerShell" -Force

# Connect to SharePoint site
Connect-PnPOnline -Url "https://yourtenant.sharepoint.com/sites/yoursite" -Interactive

# For automated scripts, use certificate-based auth
Connect-PnPOnline -Url "https://yourtenant.sharepoint.com/sites/yoursite" `
                  -ClientId "your-app-id" `
                  -CertificatePath "path/to/cert.pfx" `
                  -CertificatePassword (ConvertTo-SecureString -String "password" -AsPlainText -Force)
```

### Basic Data Extraction
```powershell
# Get all items from a list
$items = Get-PnPListItems -List "YourListName"

# Export to CSV
$items | Select-Object -Property * | Export-Csv -Path "list-data.csv" -NoTypeInformation

# Export to JSON
$items | ConvertTo-Json -Depth 10 | Out-File "list-data.json"
```

### Advanced Querying
```powershell
# Filter items using CAML
$camlQuery = "<View><Query><Where><Eq><FieldRef Name='Status'/><Value Type='Text'>Active</Value></Eq></Where></Query></View>"
$filteredItems = Get-PnPListItems -List "YourListName" -Query $camlQuery

# Get specific fields only
$fields = "Title", "Status", "Modified", "Created", "Author"
$selectedItems = Get-PnPListItems -List "YourListName" -Fields $fields

# Batch processing for large lists
$batchSize = 2000
$position = 0
$allItems = @()

do {
    $items = Get-PnPListItems -List "YourListName" -PageSize $batchSize -Skip $position
    $allItems += $items
    $position += $items.Count
    Write-Host "Retrieved $($allItems.Count) items..."
} while ($items.Count -eq $batchSize)
```

## Method 2: REST API

### Authentication Setup
```powershell
# Get access token using Azure AD app
$clientId = "your-client-id"
$clientSecret = "your-client-secret"
$tenantId = "your-tenant-id"
$resource = "https://yourtenant.sharepoint.com"

$tokenEndpoint = "https://login.microsoftonline.com/$tenantId/oauth2/token"
$body = @{
    grant_type    = "client_credentials"
    client_id     = $clientId
    client_secret = $clientSecret
    resource      = $resource
}

$token = Invoke-RestMethod -Uri $tokenEndpoint -Method Post -Body $body
$accessToken = $token.access_token
```

### REST API Calls
```powershell
# Define headers
$headers = @{
    "Accept"        = "application/json;odata=verbose"
    "Authorization" = "Bearer $accessToken"
}

# Get list items
$listUrl = "https://yourtenant.sharepoint.com/sites/yoursite/_api/web/lists/getbytitle('YourListName')/items"
$response = Invoke-RestMethod -Uri $listUrl -Headers $headers -Method Get

# Export data
$response.d.results | ConvertTo-Json -Depth 10 | Out-File "rest-data.json"
```

## Method 3: Microsoft Graph API

### Python Implementation
```python
import requests
import json
import pandas as pd
from msgraph.core import GraphClient
from azure.identity import ClientSecretCredential

# Auth setup
credential = ClientSecretCredential(
    tenant_id="your-tenant-id",
    client_id="your-client-id",
    client_secret="your-client-secret"
)

graph_client = GraphClient(credential=credential)

# Get list items
site_id = "your-site-id"
list_id = "your-list-id"
endpoint = f"/sites/{site_id}/lists/{list_id}/items?expand=fields"

response = graph_client.get(endpoint)
items = response.json()['value']

# Export to CSV
df = pd.DataFrame([item['fields'] for item in items])
df.to_csv('graph-data.csv', index=False)
```

## Troubleshooting Guide

### Common Issues and Solutions

1. Authentication Errors
   - Check app permissions in Azure AD
   - Verify certificate expiration
   - Ensure proper OAuth scope configuration

2. Large List Throttling
   - Use indexed columns for filtering
   - Implement batch processing
   - Schedule extractions during off-peak hours

3. Missing Data
   - Check field internal names
   - Verify user permissions
   - Enable versioning if needed

4. Performance Issues
   - Use selective fields instead of Select *
   - Implement pagination
   - Use appropriate batch sizes

### Best Practices

1. Data Extraction
   - Always use incremental extraction where possible
   - Implement error handling and logging
   - Use batching for large datasets

2. Authentication
   - Use certificate-based auth for automation
   - Rotate secrets regularly
   - Implement proper error handling

3. Performance
   - Index frequently queried columns
   - Use appropriate page sizes
   - Implement retry logic with exponential backoff

## Sample Error Handling Implementation
```powershell
function Get-ListDataSafely {
    param (
        [string]$ListName,
        [int]$BatchSize = 2000,
        [int]$MaxRetries = 3
    )
    
    try {
        $retry = 0
        $success = $false
        
        do {
            try {
                $items = Get-PnPListItems -List $ListName -PageSize $BatchSize
                $success = $true
            }
            catch {
                $retry++
                if ($retry -ge $MaxRetries) { throw }
                Start-Sleep -Seconds ([Math]::Pow(2, $retry))
            }
        } while (-not $success -and $retry -lt $MaxRetries)
        
        return $items
    }
    catch {
        Write-Error "Failed to retrieve data after $MaxRetries attempts: $_"
        throw
    }
}
```

## Data Quality Checks
```powershell
function Test-DataQuality {
    param (
        [array]$Items,
        [string]$RequiredField
    )
    
    $missingData = $Items | Where-Object { -not $_[$RequiredField] }
    if ($missingData) {
        Write-Warning "Found $($missingData.Count) items with missing $RequiredField"
    }
    
    $duplicates = $Items | Group-Object $RequiredField | Where-Object { $_.Count -gt 1 }
    if ($duplicates) {
        Write-Warning "Found duplicate values for $RequiredField"
    }
}
```

Remember to always test your extraction scripts in a non-production environment first and implement proper logging and error handling for production use.