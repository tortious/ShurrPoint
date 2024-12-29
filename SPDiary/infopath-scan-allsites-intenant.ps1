#Parameters
$Domain =  "CrescentIntranet" #Your Domain Name in SharePoint Online. E.g. https://Crescent.sharepoint.com
$CSVPath = "C:\Temp\InfoPathRpt.csv"
$Cred = Get-Credential
 
#Frame Tenant URL and Tenant Admin URL
$TenantURL = "https://$Domain.SharePoint.com"
$TenantAdminURL = "https://$Domain-Admin.SharePoint.com"
 
#Function to Get Form Libraries
Function Get-PnPFormLibraries
{
[cmdletbinding()]
 
    param(
    [parameter(Mandatory = $true, ValueFromPipeline = $False)]$Web,
    [parameter(Mandatory = $False, ValueFromPipeline = $False)][String] $CSVPath
    )
   
    Try {
        Write-host "`tSearching Web '$($Web.URL)'" -f Yellow
         
        #Get All Form libraries
        $Lists= Get-PnPProperty -ClientObject $Web -Property Lists 
        $FormLibraries = $Lists | Where-Object {$_.BaseTemplate -eq 115 -and $_.Hidden -eq $false}
 
        #Export Form Libraries Inventory to CSV
        If($FormLibraries.count -gt 0)
        {
            Write-host "`tFound '$($FormLibraries.count)' Form Librarie(s)!" -f Green
            $FormLibraries | Select Title, DefaultViewUrl, Created | Export-Csv -Path $CSVPath -NoTypeInformation -Append
        }
    }
    catch {
        write-host "Error: $($_.Exception.Message)" -foregroundcolor Red
    }
}
 
#Connect to Admin Center
Connect-PnPOnline -Url $TenantAdminURL -Credentials $Cred
     
#Get All Site collections - Exclude BOT, Video Portals and MySites
$Sites = Get-PnPTenantSite -Filter "Url -like $TenantURL -and Url -notlike '-my.sharepoint.com/' -and Url -notlike '/portals/'"
    
#Iterate through all site collections
$Sites | ForEach-Object {
    #Connect to each site collection
    Connect-PnPOnline -Url $_.URL -Credentials $Cred
     
    Write-host "`nProcessing Site Collection:"$_.URL -ForegroundColor Magenta
    #Get All Webs in the site collection and Iterate through
    Get-PnPSubWeb -Recurse -IncludeRootWeb | ForEach-Object {Get-PnPFormLibraries -Web $_ -CSVPath $CSVPath}
