#Function to Get Form Libraries
Function Get-PnPFormLibraries
{
[cmdletbinding()]
  
    param(
    [parameter(Mandatory = $true, ValueFromPipeline = $True)]$Web,
    [parameter(Mandatory = $true, ValueFromPipeline = $False)][String] $CSVPath
    )
    
    Try {
        Write-host "Searching Web '$($Web.URL)'" -f Yellow
          
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
  
#Set Variables
$SiteURL = "https://crescent.sharepoint.com/sites/marketing"
$CSVPath = "C:\Temp\FormLibs.csv"
  
#Connect to PnP Online
Connect-PnPOnline -Url $SiteURL -Interactive
 
#Get All Webs in the site collection and Iterate through
$Webs = Get-PnPSubWeb -Recurse -IncludeRootWeb
  
#Delete the Output Report if exists
If (Test-Path $CSVPath) { Remove-Item $CSVPath }
 
ForEach($Web in $Webs)
{ 
    #Call the function
    Get-PnPFormLibraries -Web $Web -CSVPath $CSVPath
}
