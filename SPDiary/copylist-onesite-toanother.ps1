	
#Parameters
$SourceSiteURL = "https://crescent.sharepoint.com/sites/Retail"
$TargetSiteURL = "https://crescent.sharepoint.com/sites/Sales"
$ListName= "Projects"
$TemplateFile ="$env:TEMP\Template.xml"
 
#Connect to the Source Site
Connect-PnPOnline -Url $SourceSiteURL -Interactive
 
#Create the Template
Get-PnPSiteTemplate -Out $TemplateFile -ListsToExtract $ListName -Handlers Lists
 
#Get Data from source List
Add-PnPDataRowsToSiteTemplate -Path $TemplateFile -List $ListName
 
#Connect to destination Site
Connect-PnPOnline -Url $TargetSiteURL -Interactive
 
#Import the exported list - Apply the Template
Invoke-PnPSiteTemplate -Path $TemplateFile
