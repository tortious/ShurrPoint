$SiteURL = "https://crescent.sharepoint.com/sites/purchase"
$ListName = "Invoices"
$TemplateName = "Invoice Library V2"
$TemplateDescription = "Document Library Template for Invoices"
$TemplateThumbnail = "https://crescent.sharepoint.com/SiteAssets/Invoice-library-template.jpeg"
 
#Connect to Admin Center
Connect-PnPOnline -url $SiteURL -Interactive
 
# Get the Template from the Library
$ListTemplate = Get-PnPSiteScriptFromList -List $ListName
 
#Create a site script from the template
$SiteScript = Add-PnPSiteScript -Title $TemplateName -Description $TemplateDescription -Content $ListTemplate
 
#Create a List design for the site script
Add-PnPListDesign -Title $TemplateName -Description $TemplateDescription -SiteScript $SiteScript -Thumbnail $TemplateThumbnail
