#Parameters
$SourceSiteUrl = "https://crescent.sharepoint.com/sites/Retail" 
$DestinationSiteUrl = "https://crescent.sharepoint.com/sites/Sales"
$SourceListName = "Projects"
$DestinationListName = "Projects"
$FieldsToCopy = "ProjectName", "ProjectDescription", "ProjectManager", "Department" #Internal Names
 
#Connect to the Source site
Connect-PnPOnline -Url $SourceSiteUrl -Interactive
  
#Get All Fields from the Source List
$SourceListFields = Get-PnPField -List $SourceListName
 
#Connect to Destination site
Connect-PnPOnline -Url $DestinationSiteUrl -Interactive
 
#Get All Fields from the Desntination List
$DestinationListFields = Get-PnPField -List $DestinationListName
 
#Copy columns from the Source List to Destination List
ForEach($Field in $FieldsToCopy)
{
    #Check if the destination list has the field already
    $DestinationFieldExist = ($DestinationListFields | Select -ExpandProperty InternalName).Contains($Field)
    If($DestinationFieldExist -eq $false)
    {
        #Get the field to copy
        $SourceField = $SourceListFields | Where {$_.InternalName -eq $Field}
        If($SourceField -ne $Null)
        {
            Add-PnPFieldFromXml -List $DestinationListName -FieldXml $SourceField.SchemaXml | Out-Null
            Write-Host "Copied Field from Source to Destination List:"$Field -f Green
        }
        Else
        {
            Write-Host "Field '$Field' does not Exist in the Source List!" -f Yellow
        }
    }
    Else
    {
        Write-host "Field '$Field' Already Exists in the Destination List!" -f Yellow
    }
}
