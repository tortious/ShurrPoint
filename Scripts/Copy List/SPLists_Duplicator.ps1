# link to site w/ instructions - https://github.com/sstalsberg/SharePoint-Lists-Duplicator/blob/main/SPLists_Duplicator.ps1

# Parameters
$SiteURL = "Youre SharePoint Site"
$SourceListId = "Source List Here"
$TargetListId = "Target List Here"
$ImageField = "Image"  # The internal name of the field containing images
$DownloadFolderPath = "TempFolder for storing images"  # Local folder for temporary image storage

# Connect to the SharePoint site
Connect-PnPOnline -Url $SiteURL -Interactive

# Get the source and target lists by their GUIDs
$SourceList = Get-PnPList -Identity $SourceListId -Includes Fields
$TargetList = Get-PnPList -Identity $TargetListId

# Get items from the source list
$SourceItems = Get-PnPListItem -List $SourceList

# Get fields
$Fields = Get-PnPField -List $SourceList | Where-Object { $_.ReadOnlyField -eq $false -and $_.FieldName -notlike "*_0" -and $_.InternalName -ne "MetaInfo" -and $_.InternalName -ne "ContentType" }

# Categorize fields by type
$BasicFields = $Fields    | Where-Object { $_.TypeAsString -notlike "Lookup*" -and $_.TypeAsString -notlike "User*" -and $_.TypeAsString -notlike "Taxonomy*" -and $_.TypeAsString -ne "Attachments" }
$LookupFields = $Fields   | Where-Object { $_.TypeAsString -like "Lookup*" }
$UserFields = $Fields     | Where-Object { $_.TypeAsString -like "User*" }
$TaxonomyFields = $Fields | Where-Object { $_.TypeAsString -like "TaxonomyFieldType*" }

# Ensure the download folder exists
if (-not (Test-Path $DownloadFolderPath)) {
    New-Item -ItemType Directory -Path $DownloadFolderPath
}

# Process each item in the source list
foreach ($SourceItem in $SourceItems) {
    $TargetValues = @{}
  
    # Copy basic fields
    foreach ($Field in $BasicFields) {
        if ($Field.InternalName -ne $ImageField) {
            $TargetValues[$Field.InternalName] = $SourceItem.FieldValues[$Field.InternalName]
        }
    }

    # Copy lookup fields
    foreach ($Field in $LookupFields) {
        $Values = @()
        $SourceItem.FieldValues[$Field.InternalName] | ForEach-Object { $Values += $_.LookupId }
        $ValuesStr = $Values -join ","
        if ($ValuesStr -ne "") {
            $TargetValues[$Field.InternalName] = $ValuesStr
        }
    }

    # Copy user fields
    foreach ($Field in $UserFields) {
        $Values = @()
        $SourceItem.FieldValues[$Field.InternalName] | ForEach-Object { $Values += $_.Email }
        if ($Values.Length -eq 1) {
            $TargetValues[$Field.InternalName] = $Values[0]
        } elseif ($Values.Length -gt 1) {
            $TargetValues[$Field.InternalName] = $Values
        }
    }

    # Copy taxonomy fields
    foreach ($Field in $TaxonomyFields) {
        $Values = @()
        $SourceItem.FieldValues[$Field.InternalName] | ForEach-Object { $Values += $_.TermGuid }
        if ($Values.Length -eq 1) {
            $TargetValues[$Field.InternalName] = $Values[0]
        } elseif ($Values.Length -gt 1) {
            $TargetValues[$Field.InternalName] = $Values
        }
    }

    # Add the item to the target list
    $TargetItem = Add-PnPListItem -List $TargetList -Values $TargetValues

    # Handle image field
    if ($SourceItem.FieldValues[$ImageField]) {
        $ImageData = $SourceItem.FieldValues[$ImageField]

        try {
            # Parse JSON directly assuming it is well-formed
            $ImageDataObj = $ImageData | ConvertFrom-Json -ErrorAction Stop

            # Extract URL and file name
            $ServerRelativeUrl = $ImageDataObj.serverRelativeUrl
            $FileName = $ImageDataObj.fileName

            # Construct the full image URL
            $ImageUrl = [System.Uri]::new($SiteURL.TrimEnd('/') + $ServerRelativeUrl)

            # Define local path
            $LocalImagePath = Join-Path -Path $DownloadFolderPath -ChildPath $FileName

            # Download the image if it does not exist
            if (-not (Test-Path -Path $LocalImagePath)) {
                Write-Host "Downloading image from: $ImageUrl"
                Get-PnPFile -Url $ServerRelativeUrl -Path $DownloadFolderPath -FileName $FileName -AsFile
                Write-Host "Image downloaded successfully: $LocalImagePath"
            } else {
                Write-Host "Image already exists: $LocalImagePath"
            }

            # Upload the image to the target list
            Set-PnPImageListItemColumn -List $TargetListId -Identity $TargetItem.Id -Field $ImageField -Path $LocalImagePath

            Write-Host "Uploaded and set image for item $($TargetItem.Id) from path: $LocalImagePath"
        }
        catch {
            Write-Host "Error processing image for item $($SourceItem.Id): $_"
        }
    } else {
        Write-Host "No image data found for item $($SourceItem.Id)"
    }
    
    Write-Host "Copied item with ID $($SourceItem.Id) to target list with ID $($TargetItem.Id)"
}

Write-Host "Copy process completed."

# Disconnect from SharePoint Online
Disconnect-PnPOnline
