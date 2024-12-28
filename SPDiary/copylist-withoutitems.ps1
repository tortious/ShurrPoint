#Parameters
$SiteURL = "https://crescent.sharepoint.com/sites/Retail"
$SourceListName = "Documents"
$DestinationListName = "Documents Backup"
 
Try {
    #Connect to PnP Online
    Connect-PnPOnline -Url $SiteURL -Interactive   
  
    #Copy the list using PnP powershell
    Copy-PnPList -Identity $SourceListName -Title $DestinationListName
}
Catch {
    write-host "Error: $($_.Exception.Message)" -foregroundcolor Red
}
