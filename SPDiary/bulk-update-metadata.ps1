#Parameters
$SiteURL = "https://crescent.sharepoint.com/sites/marketing"
$ListName= "Branding"
$CSVOutput = "C:\Temp\DocInventory.csv"
 
#Connect to SharePoint Online site
Connect-PnPOnline $SiteURL -Interactive
  
#Get all Files from the document library
$ListItems = Get-PnPListItem -List $ListName -PageSize 2000 -Fields "FileLeafRef" | Where {$_.FileSystemObjectType -eq "File"}
 
#Iterate through each item
$DocumentsList = @()
Foreach ($Item in $ListItems) 
{
    #Extract File Name and URL
    $DocumentsList += New-Object PSObject -Property ([ordered]@{
        FileName          = $Item.FieldValues.FileLeafRef
        ServerRelativeURL = $Item.FieldValues.FileRef
    })
}
#Export the results
$DocumentsList | Export-Csv -Path $CSVOutput -NoTypeInformation
