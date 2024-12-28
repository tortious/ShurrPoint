#Parameters
$SiteURL = "https://crescent.sharepoint.com/sites/Retail"
$PageName = "Welcome.aspx"
$WebPartTitle = "People" # Not the web part title, but name
 
#Connect to SharePoint Online
Connect-PnPOnline -Url $SiteURL -Interactive
 
#Get the Page
$Page = Get-PnPPage -Identity $PageName
 
#Get the Web Part to update
$webPart = $Page.Controls | Where-Object {$_.Title -eq $WebPartTitle}
 
#Frame JSON to update
$PeopleData="[{`"id`":`"salaudeen@crescent.com`"},{`"id`":`"steve@crescent.com`"}]"
$jsonPorperty='{"layout":1,"persons":'+$PeopleData+'}'
 
#Update Web Part properties
Set-PnPPageWebPart -Page $PageName -Identity $webPart.InstanceId -PropertiesJson $jsonPorperty
