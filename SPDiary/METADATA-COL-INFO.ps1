
############ GET VALUE OF MANAGED METADATA COLUMN
#Load SharePoint CSOM Assemblies
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
  
#Set parameters
$SiteURL="https://crescent.sharepoint.com/Sites/pmo"
$ListName="Projects"
$FieldName="Classification" #Internal Name
$ListItemID="1"
 
#Get Credentials to connect
$Cred = Get-Credential
   
#Setup the context
$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($SiteURL)
$Ctx.Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Cred.Username, $Cred.Password)
  
#Get the List Item
$List = $Ctx.Web.lists.GetByTitle($ListName)
$ListItem = $List.GetItemById($ListItemID)
$Ctx.Load($ListItem)
$Ctx.ExecuteQuery()
  
#Get Managed Metadata Field Value
$MMSFieldValue = $ListItem[$FieldName]
Write-host $MMSFieldValue.Label
Write-host $MMSFieldValue.TermGuid



############ RETRIEVE VALUE
#Parameters
$SiteURL="https://crescent.sharepoint.com/Sites/pmo"
$ListName="Projects"
$FieldName="Classification" #Internal Name
$ListItemID="1"
 
#Connect to PnP Online
Connect-PnPOnline -Url $SiteURL -Interactive
 
#Get an item from the list
$ListItem = Get-PnPListItem -List $ListName -Id $ListItemID -Fields $FieldName
 
#Get the Field
$Field = Get-PnPField -List $ListName -Identity $FieldName
 
#Check if the field allows Multiple values
If($Field.TypeAsString -eq "TaxonomyFieldType")
{
    #Get Managed Metadata Field Value
    $MMSFieldValue = $ListItem[$FieldName]
    Write-host $MMSFieldValue.Label
    Write-host $MMSFieldValue.TermGuid
}
Else #TaxonomyFieldTypeMulti
{
    $MMSFieldValue = $ListItem[$FieldName] | ForEach-Object {
        Write-host $_.Label
        Write-host $_.TermGuid
    }
}
