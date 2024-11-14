<#
.SYNOPSIS
Combines data from SharePoint Online into a single Excel workbook with separate worksheets for Site Owners, Storage Quota, and Groups Report.

.DESCRIPTION
This script connects to SharePoint Online Admin Center and retrieves information about site owners, storage quotas, and SharePoint groups for each site collection. It then exports this data into separate worksheets within a specified Excel workbook.

.PARAMETER AdminCenterURL
The URL of the SharePoint Online Admin Center to connect to.

.EXAMPLE
.\SharePointReports.ps1 -AdminCenterURL "https://abcd.sharepoint.com"

This example runs the script to gather SharePoint data from "https://abcd.sharepoint.com" and save report in CSV files.

.NOTES
Author: Kashyap Patel
Date: 22/06/2024
Version: 1.0

Prerequisites - Install the necessary modules:
Install-Module -Name Microsoft.Online.SharePoint.PowerShell (SharePoint Online Management Shell module)
Install-Module -Name "PnP.PowerShell" -AllowClobber -Force (PnP PowerShell module)
Import-Module PnP.PowerShell
Install-Module Microsoft.Graph -Scope CurrentUser (Microsoft.Graph module)
#>

# Parameters
param (
    [string]$AdminCenterURL
)

# Get the script directory
$ScriptDir = Split-Path -Parent $PSCommandPath

# Construct the CSV file paths
$SiteOwnersCSVPath = Join-Path -Path $ScriptDir -ChildPath "SiteOwners.csv"
$SPOStorageCSVPath = Join-Path -Path $ScriptDir -ChildPath "SPOStorage.csv"
$GroupsReportCSVPath = Join-Path -Path $ScriptDir -ChildPath "GroupsReport.csv"

# Get Credentials to connect
$Cred = Get-Credential

# Connect to SharePoint Online and Azure AD
Connect-SPOService -url $AdminCenterURL -Credential $Cred
Connect-AzureAD -Credential $Cred | Out-Null

# Get all Site Collections
$Sites = Get-SPOSite -Limit ALL

# Script 1: Get Site Owners
$SiteOwners = @()
$Sites | ForEach-Object {
    If ($_.Template -like 'GROUP*') {
        $Site = Get-SPOSite -Identity $_.URL
        # Get Group Owners
        $GroupOwners = (Get-AzureADGroupOwner -ObjectId $Site.GroupID | Select -ExpandProperty UserPrincipalName) -join "; "
    } else {
        $GroupOwners = $_.Owner
    }
    # Collect Data
    $SiteOwners += New-Object PSObject -Property @{
        'Site Title' = $_.Title
        'URL' = $_.Url
        'Owner(s)' = $GroupOwners
    }
}
# Export Site Owners report to CSV
$SiteOwners | Export-Csv -path $SiteOwnersCSVPath -NoTypeInformation

# Script 2: Get Site Storage Details
$ResultSet = @()
Foreach ($Site in $Sites) {
    Write-Host "Processing Site Collection :" $Site.URL -f Yellow
    $Result = New-Object PSObject
    $Result | Add-Member -MemberType NoteProperty -Name "SiteURL" -Value $Site.URL
    $Result | Add-Member -MemberType NoteProperty -Name "Allocated" -Value $Site.StorageQuota
    $Result | Add-Member -MemberType NoteProperty -Name "Used" -Value $Site.StorageUsageCurrent
    $Result | Add-Member -MemberType NoteProperty -Name "Warning Level" -Value $Site.StorageQuotaWarningLevel
    $ResultSet += $Result
}
# Export Result to CSV file
$ResultSet | Export-Csv $SPOStorageCSVPath -NoTypeInformation

Write-Host "Site Quota Report Generated Successfully!" -f Green

# Script 3: Get Site Groups
$GroupsData = @()
$Sites | ForEach-Object {
    Write-Host -f Yellow "Processing Site Collection:" $_.URL
    # Get SharePoint Online groups
    $SiteGroups = Get-SPOSiteGroup -Site $_.URL
    Write-Host "Total Number of Groups Found:" $SiteGroups.Count
    ForEach ($Group in $SiteGroups) {
        $GroupsData += New-Object PSObject -Property @{
            'Site URL' = $_.URL
            'Group Name' = $Group.Title
            'Permissions' = $Group.Roles -join ","
            'Users' = $Group.Users -join ","
        }
    }
}
# Export the data to CSV
$GroupsData | Export-Csv $GroupsReportCSVPath -NoTypeInformation

Write-Host -f Green "Groups Report Generated Successfully!"
