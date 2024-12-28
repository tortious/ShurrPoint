
	
# Parameter
$SiteURL = "https://crescent.sharepoint.com/sites/Retail"
$PageName = "Team-Documents.aspx" #"About-us.aspx"
 
# Connect to PnP Online
Connect-PnPOnline –Url $SiteURL -Interactive
 
# Get the Page
$Page = Get-PnPClientSidePage –Identity $PageName
 
# Save page as template
$Page.SaveAsTemplate($Page.PageTitle)
