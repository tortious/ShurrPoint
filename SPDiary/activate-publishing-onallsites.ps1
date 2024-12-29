#Parameters
$SiteURL = "https://crescent.sharepoint.com/sites/marketing"
$FeatureId = "94c94ca6-b32f-4da9-a9e3-1f3d343d7ecb" #Web Scoped Publishing Feature
  
#Function to Activate a Feature in SharePoint Online Web
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
            #Activate feature            
            Enable-PnPFeature -Scope Web -Identity $FeatureId -Force -Verbose -ErrorAction Stop
   
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
  
#Connect to the site collection
Connect-PnPOnline -Url $SiteURL -Interactive
  
#Call the Function for Root Web & all Subwebs
Get-PnPSubWeb -IncludeRootWeb -Recurse | ForEach-Object { Activate-PnPWebFeature $_ -FeatureId $FeatureId}
