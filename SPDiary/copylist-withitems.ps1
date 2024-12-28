#Parameters
$SiteURL = "https://crescent.sharepoint.com/sites/Retail"
$SourceListName = "Documents"
 
$DestinationSiteURL = "https://crescent.sharepoint.com/sites/Sales"
$DestinationListName = "Documents Backup"
 
Try {
    #Connect to PnP Online
    Connect-PnPOnline -Url $SiteURL -Interactive   
  
    #Copy list to another site using powershell
    Copy-PnPList -Identity $SourceListName -Title $DestinationListName -DestinationWebUrl $DestinationSiteURL
}
Catch {
    write-host "Error: $($_.Exception.Message)" -foregroundcolor Red
}
