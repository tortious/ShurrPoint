#Parameters
$TenantAdminURL = "https://Crescent-Admin.SharePoint.com"
#Site Collection feature "Open Documents in Client Applications by Default"
$FeatureId = "8a4b8de2-6fd8-41e9-923c-c7c3c00f8295"
 
#Connect to Admin Center
$Cred = Get-Credential
Connect-PnPOnline -Url $TenantAdminURL -Credentials $Cred
 
#Get All Site collections - Exclude: Seach Center, Mysite Host, App Catalog, Content Type Hub, eDiscovery and Bot Sites
$SitesCollections = Get-PnPTenantSite | Where -Property Template -NotIn ("SRCHCEN#0", "REDIRECTSITE#0","SPSMSITEHOST#0", "APPCATALOG#0", "POINTPUBLISHINGHUB#0", "EDISC#0", "STS#-1")
 
#Loop through each site collection
ForEach($Site in $SitesCollections)
{
    #Connect to site collection
    Write-host -f Yellow "Trying to Activate the feature on site:"$Site.Url    
    Connect-PnPOnline -Url $Site.Url -Credentials $Cred
 
    #Get the Feature
    $Feature = Get-PnPFeature -Scope Site -Identity $FeatureId
 
    #Check if feature is activated
    If($Feature.DefinitionId -eq $null)
    {
        #Enable site collection feature
        Enable-PnPFeature -Scope Site -Identity $FeatureId -Force
 
        Write-host -f Green "`tFeature Activated Successfully!"
    }
    Else
    {
        Write-host -f Cyan "`tFeature is already active!"
    }
}
