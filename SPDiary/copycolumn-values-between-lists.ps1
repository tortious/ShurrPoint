#Parameters
$SourceSiteUrl = "https://crescent.sharepoint.com/sites/Retail" 
$DestinationSiteUrl = "https://crescent.sharepoint.com/sites/Sales"
$SourceListName = "Projects"
$DestinationListName = "ProjectsV2"
$FieldsToCopy = "ProjectName", "ProjectDescription", "ProjectManager", "Date", "Department"
 
#Connect to Source site
Connect-PnPOnline -Url $SourceSiteUrl -Interactive
  
#Get All Items from the Source List
$SourceListItems = Get-PnPListItem -List $SourceListName -Fields $FieldsToCopy -PageSize 2000
 
#Connect to Destination site
Connect-PnPOnline -Url $DestinationSiteUrl -Interactive
 
#Copy Items from the Source to Destination
[int]$Counter = 1
ForEach($ListItem in $SourceListItems)
{
    $ItemValue = @{}
    ForEach($Field in $FieldsToCopy)
    {
        #Check if the Field value is not Null
        If($ListItem[$Field] -ne $Null)
        {
            #Handle Special Fields
            $FieldType  = (Get-PnPField -List $SourceListName -Identity $Field).TypeAsString
   
            If($FieldType -eq "User" -or $FieldType -eq "UserMulti" -or $FieldType -eq "Lookup" -or $FieldType -eq "LookupMulti") #People Picker or Lookup Field
            {
                $LookupIDs = $ListItem[$Field] | ForEach-Object { $_.LookupID.ToString()}
                $ItemValue.add($Field,$LookupIDs)
            }
            ElseIf($FieldType -eq "URL") #Hyperlink
            {
                $URL = $ListItem[$Field].URL
                $Description  = $ListItem[$Field].Description
                $ItemValue.add($Field,"$URL, $Description")
            }
            ElseIf($FieldType -eq "TaxonomyFieldType" -or $FieldType -eq "TaxonomyFieldTypeMulti") #MMS
            {
                $TermGUIDs = $ListItem[$Field] | ForEach-Object { $_.TermGuid.ToString()}                    
                $ItemValue.add($Field,$TermGUIDs)
            }
            Else
            {
                #Get Source Field Value and add to Hashtable
                $ItemValue.add($Field,$ListItem[$Field])
            }
        }
    }
    Write-Progress -Activity "Copying List Items:" -Status "Copying Item ID '$($ListItem.Id)' from Source List ($($Counter) of $($SourceListItems.count))" -PercentComplete (($Counter / $SourceListItems.count) * 100)
  
    #Copy column value from source to target
    Add-PnPListItem -List $DestinationListName -Values $ItemValue | Out-Null
   
    Write-Host "Copied Values from Source to Target Column of Item '$($ListItem.Id)' ($($Counter) of $($SourceListItems.count)) "
    $Counter++
}
