# PowerShell to Hide Default Themes in SharePoint Online
Hiding the default themes in SharePoint Online is a relatively simple process through PowerShell. Open SharePoint Online Management Shell, and run this PowerShell script to hide default themes in SharePoint Online:
```
#SharePoint Online Admin Center URL
$AdminURL = "https://crescent-admin.sharepoint.com"
 
#Get Credentials to connect
$Cred = Get-Credential
 
#Connect to SharePoint Online
Connect-SPOService -url $AdminURL -credential $Cred
 
#Check If Default Themes are hidden already
If(Get-SPOHideDefaultThemes) 
{
    Write-Host -f Yellow "Default themes are already hidden!"
}
Else
{
    Set-SPOHideDefaultThemes $True
    Write-Host -f Yellow "Default themes are now hidden!"
}
```
Now, this is what you get when you click on “Change the Look” from the Site Settings menu in modern SharePoint Online sites:

https://www.sharepointdiary.com/wp-content/uploads/2017/12/hide-default-themes-in-sharepoint-online.png

To reverse (Enable all default themes), call the “Set-SPOHideDefaultThemes” cmdlet with the “$False” parameter.

    Set-SPOHideDefaultThemes $False
    
## PnP PowerShell to Hide Default Themes in SharePoint Online
In SharePoint Online, the default themes can’t be deleted. However, these themes can be hidden from view! Let me show you how to hide default themes in SharePoint Online using PnP PowerShell. 
```
#Config Variables
$AdminSiteURL = "https://crescent-admin.sharepoint.com"
 
#Connect to Admin Center
Connect-PnPOnline -Url $AdminSiteURL -Interactive
 
#Hide Default Themes
Set-PnPHideDefaultThemes -HideDefaultThemes $True
```

SharePoint Online provides default themes that you can use to customize the look and feel of your site. However, sometimes, you may want to limit the available themes to prevent users from selecting inappropriate or conflicting themes.

In this article, we’ve shown how to use PowerShell to hide the default themes in SharePoint Online. This will ensure employees only utilize company-approved branding on their SharePoint portals going forward.