# Script: Apply-TerryTemplate.ps1
# Purpose: Extract and apply PnP template between SharePoint sites

# 1. Install required module if not present
if (!(Get-Module -ListAvailable -Name "PnP.PowerShell")) {
    Install-Module -Name "PnP.PowerShell" -Force -AllowClobber
}

# 2. Configuration variables
$tenantName = "[mytenant]"
$sourceSite = "TerryTemplate"
$targetSite = "Cezar4940"
$templatePath = "C:\Templates\TerryTemplate.xml"
$templateFolder = Split-Path $templatePath -Parent

# 3. Ensure template directory exists
if (!(Test-Path $templateFolder)) {
    New-Item -ItemType Directory -Path $templateFolder -Force
}

# 4. Connect to source site and extract template
try {
    Write-Host "Connecting to source site..." -ForegroundColor Yellow
    Connect-PnPOnline -Url "https://$tenantName.sharepoint.com/teams/$sourceSite" -Interactive

    Write-Host "Extracting template..." -ForegroundColor Yellow
    $handlers = @(
        "Lists",
        "Fields",
        "ContentTypes",
        "Pages",
        "Navigation",
        "Files",
        "CustomActions",
        "Features",
        "WebSettings",
        "PropertyBagEntries",
        "Security",
        "SiteHeader",
        "RegionalSettings"
    )

    Get-PnPSiteTemplate -Out $templatePath `
        -Handler $handlers `
        -IncludeAllPages `
        -PersistBrandingFiles `
        -IncludeNativePublishingFiles `
        -Force

    Write-Host "Template extracted successfully" -ForegroundColor Green
} 
catch {
    Write-Host "Error extracting template: $_" -ForegroundColor Red
    exit
}

# 5. Connect to target site and apply template
try {
    Write-Host "Connecting to target site..." -ForegroundColor Yellow
    Connect-PnPOnline -Url "https://$tenantName.sharepoint.com/teams/$targetSite" -Interactive

    # 5.1 Apply template
    Write-Host "Applying template..." -ForegroundColor Yellow
    
    # Configure provisioning to handle errors
    $provisioningOptions = @{
        ClearNavigation = $true
        OverwriteSystemPropertyBagValues = $true
        IgnoreDuplicateDataRowErrors = $true
        ProvisionContentTypesToSubWebs = $true
        ProvisionFieldsToSubWebs = $true
    }

    Invoke-PnPSiteTemplate -Path $templatePath @provisioningOptions

    Write-Host "Template applied successfully" -ForegroundColor Green

    # 5.2 Post-template application tasks
    Write-Host "Performing post-template tasks..." -ForegroundColor Yellow
    
    # Update navigation settings
    Set-PnPWeb -QuickLaunchEnabled $true
    
    # Ensure required features are activated
    Enable-PnPFeature -Identity "87294c72-f260-42f3-a41b-981a2ffce37a" -Scope Site # Content Type Hub
    Enable-PnPFeature -Identity "3bae86a2-776d-499d-9db8-fa4cdc7884f8" -Scope Site # Metadata Navigation and Filtering
    
    Write-Host "Post-template tasks completed" -ForegroundColor Green
}
catch {
    Write-Host "Error applying template: $_" -ForegroundColor Red
    exit
}

# 6. Validation
try {
    Write-Host "Validating template application..." -ForegroundColor Yellow
    
    # Check lists
    $lists = Get-PnPList
    Write-Host "Found $($lists.Count) lists" -ForegroundColor Green

    # Check content types
    $contentTypes = Get-PnPContentType
    Write-Host "Found $($contentTypes.Count) content types" -ForegroundColor Green

    # Verify specific required lists
    $requiredLists = @(
        "CasePleadings",
        "Correspondence",
        "Discovery",
        "CaseMedia",
        "AssignmentDocuments"
    )

    foreach ($listName in $requiredLists) {
        $list = Get-PnPList -Identity $listName -ErrorAction SilentlyContinue
        if ($list) {
            Write-Host "Required list '$listName' exists" -ForegroundColor Green
        } else {
            Write-Host "Warning: Required list '$listName' not found" -ForegroundColor Yellow
        }
    }

    Write-Host "Validation completed" -ForegroundColor Green
}
catch {
    Write-Host "Error during validation: $_" -ForegroundColor Red
}

# 7. Cleanup
Disconnect-PnPOnline
Write-Host "Process completed" -ForegroundColor Green
