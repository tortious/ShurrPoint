#Parameters
$TenantAdminURL = "https://Crescent-Admin.SharePoint.com"
$FeatureId = "a7a2793e-67cd-4dc1-9fd0-43f61581207a" #"Following Content" Web Scoped Feature
  
#Function to Activate a Web Feature in SharePoint Online
Function Activate-PnPWebFeature
{ 
    [cmdletbinding()]
    Param(
        [parameter(Mandatory = $true, ValueFromPipeline = $True)] $Web,
        [parameter(Mandatory = $true, ValueFromPipeline = $False)] $FeatureId
    )
  
    Try {
        Write-host -f Yellow "Trying to Activate Feature on:"$web.Url
        #Get the Feature to activate
        $Feature = Get-PnPFeature -Scope Web -Identity $FeatureId -ErrorAction Stop
  
        #Check if the Feature is Activate
        If($Feature.DefinitionId -eq $null)
        {
            #Activate the feature
            Enable-PnPFeature -Scope Web -Identity $FeatureId -Force -ErrorAction Stop 
            Write-host -f Green "`tFeature Activated Successfully!"
        }
        Else
        {
            Write-host -f Cyan "`tFeature is already active!"
        }
    }
    Catch {
        write-host "`tError Activating Feature: $($_.Exception.Message)" -foregroundcolor Red
    }
}
  
#Connect to Admin Center
$Cred = Get-Credential
Connect-PnPOnline -Url $TenantAdminURL -Credentials $Cred
  
#Get All Site collections - Exclude: Seach Center, Mysite Host, App Catalog, Content Type Hub, eDiscovery and Bot Sites
$SitesCollections = Get-PnPTenantSite | Where -Property Template -NotIn ("SRCHCEN#0", "REDIRECTSITE#0","SPSMSITEHOST#0", "APPCATALOG#0", "POINTPUBLISHINGHUB#0", "EDISC#0", "STS#-1")
  
#Loop through each site collection
ForEach($Site in $SitesCollections)
{
    #Connect to site collection
    $SiteConn = Connect-PnPOnline -Url $Site.Url -Credentials $Cred
  
    #Call the Function for Web & all Subwebs
    Get-PnPSubWeb -IncludeRootWeb -Recurse | ForEach-Object { Activate-PnPWebFeature $_ -FeatureId $FeatureId} 
