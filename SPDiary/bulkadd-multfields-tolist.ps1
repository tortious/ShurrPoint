
#Parameters 
$SiteURL = "https://crescent.sharepoint.com/sites/PMO"
$ListName = "Projects"
$CSVFilePath = "C:\Temp\FieldTemplate.csv"
 
Try {    
    #Connect to the site
    Connect-PnPOnline -Url $SiteURL -Interactive       
     
    #Get the List
    $List = Get-PnPList -Identity $ListName
 
    #Get Data from the CSV file
    $CSVData = Import-Csv -Path $CSVFilePath
 
    #Process each row in the CSV
    ForEach($Row in $CSVData)
    {
        Try { 
                Write-host "Adding Column '$($Row.DisplayName)' to the List:" -f Magenta
                #Check if the column exists in list already
                $Fields = Get-PnPField -List $ListName
                $NewField = $Fields | where { ($_.Internalname -eq $Row.Internalname) -or ($_.Title -eq $Row.DisplayName) }
                If($NewField -ne $NULL)  
                {
                    Write-host "`tColumn $Name already exists in the List!" -f Yellow
                }
                Else
                {
                    #Create the field based on field type
                    Switch ($Row.Type)
                    {
                        'Single Line of text' {
                            Add-PnPField -List $ListName -Type Text -DisplayName $Row.DisplayName -InternalName $Row.Internalname -Required:([System.Convert]::ToBoolean($Row.IsRequired)) -AddToDefaultView | Out-Host
                        }
                        'Multiple lines of text' {
                            Add-PnPField -List $ListName -Type Note -DisplayName $Row.DisplayName -InternalName $Row.Internalname -Required:([System.Convert]::ToBoolean($Row.IsRequired)) -AddToDefaultView | Out-Host
                        }
                        'Number' {
                            Add-PnPField -List $ListName -Type Number -DisplayName $Row.DisplayName -InternalName $Row.Internalname -Required:([System.Convert]::ToBoolean($Row.IsRequired)) -AddToDefaultView | Out-Host
                        }
                        'Person or Group' {
                            Add-PnPField -List $ListName -Type User -DisplayName $Row.DisplayName -InternalName $Row.Internalname -Required:([System.Convert]::ToBoolean($Row.IsRequired)) -AddToDefaultView | Out-Host
                        }
                        'Date and Time' {
                            Add-PnPField -List $ListName -Type DateTime -DisplayName $Row.DisplayName -InternalName $Row.Internalname -Required:([System.Convert]::ToBoolean($Row.IsRequired)) -AddToDefaultView | Out-Host
                        }
                        'Yes or No' {
                            Add-PnPField -List $ListName -Type Boolean -DisplayName $Row.DisplayName -InternalName $Row.Internalname -Required:([System.Convert]::ToBoolean($Row.IsRequired)) -AddToDefaultView | Out-Host
                        }
                        'Currency' {
                            Add-PnPField -List $ListName -Type Currency -DisplayName $Row.DisplayName -InternalName $Row.Internalname -Required:([System.Convert]::ToBoolean($Row.IsRequired)) -AddToDefaultView | Out-Host
                        }
                        'Choice' {
                            Add-PnPField -List $ListName -Type Choice -Choices @($Row.Data.Split(",")) -DisplayName $Row.DisplayName -InternalName $Row.Internalname -Required:([System.Convert]::ToBoolean($Row.IsRequired)) -AddToDefaultView | Out-Host
                        }
                        'Hyperlink or Picture' {
                            Add-PnPField -List $ListName -Type URL -DisplayName $Row.DisplayName -InternalName $Row.Internalname -Required:([System.Convert]::ToBoolean($Row.IsRequired)) -AddToDefaultView | Out-Host
                        }
                        'Managed Metadata' {
                            Add-PnPTaxonomyField -DisplayName $Row.DisplayName -InternalName $Row.Internalname -TermSetPath $Row.Data -List $ListName -Required:([System.Convert]::ToBoolean($Row.IsRequired)) -AddToDefaultView | Out-Host
                        }
                        'Lookup' {
                            #Get Lookup options - first part represents the Lookup Parent list, second part for lookup field in the parent list
                            $LookupOptions = $Row.Data.Split(";")
                            Add-PnPField -List $ListName -Type Lookup -DisplayName $Row.DisplayName -InternalName $Row.Internalname -Required:([System.Convert]::ToBoolean($Row.IsRequired)) -AddToDefaultView | Out-Host
                            Set-PnPField -List $ListName -Identity $Row.Internalname -Values @{LookupList=(Get-PnPList $LookupOptions[0]).Id.ToString(); LookupField=$LookupOptions[1]}
                        }
                        Default {
                            Write-host "`tColumn Type '$($Row.Type)' not Found!" -f Red
                        }
                    }
                }
            }
        Catch {
            write-host -f Red "`tError Adding Column '$($Row.DisplayName)' to List:" $_.Exception.Message
        }
    }
}
Catch {
    write-host -f Red "Error:" $_.Exception.Message
}
