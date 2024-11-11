# Author: Cameron Oakley (Oakley.CameronJ@gmail.com)
# Date: 2024-05-21
# Descripton: Powerhsell script to download a SharePoint 
# 	library's contents. The URL parameters are hard coded (for 
# 	now), but could be changed based on the needs of the download.
# 	This Powershell script utilizes PnP to download files from
# 	SharePoint.
# Organization: Monterey County Sheriff's Office


#* SCRIPT PARAMETERS (modifiable)

$siteDomain = "https://CHANGEME.sharepoint.com"
$spUrl = "/sites/CHANGEME"
$siteRelUrl = "/CHANGEME/CHANGEME/"
$libraryName = "/CHANGEME"
$absDownloadPath = "C:\CHANGEME"


# 4. Function to download a SharePoint site's contents *recursively*.
function downloadSharePointSiteContents([Microsoft.SharePoint.Client.Folder]$tld, $absDownloadPath) {
	
	# Isolate the servers relative URL ("/sites/Sheriff")
	$tldUrl = $tld.ServerRelativeUrl.Substring($tld.Context.Web.ServerRelativeUrl.Length)
	
	# Absolute path to download file to.
	$newSubFolderPath = $absDownloadPath + ($tldUrl -replace "/","\")

	# Create a new sub folder if one does NOT exist.
	if (!(Test-Path -Path $newSubFolderPath)) {
		New-Item -ItemType Directory -Path $newSubFolderPath | Out-Null
		Write-Host -ForegroundColor Yellow "Created a new sub folder on local file system: '$newSubFolderPath'"
	}


	#* REFERENCE AND DOWNLOAD ALL FILES

	# Get references to all files stored in the folder
	$filesRefObj = Get-PnPFolderItem -FolderSiteRelativeUrl $tldUrl -ItemType File 

	# Iterate through filesRefObj and download all files referenced
	foreach($file in $filesRefObj) {
		Get-PnPFile -ServerRelativeUrl $file.ServerRelativeUrl -Path $newSubFolderPath -FileName $file.Name -AsFile -force
		Write-Host -ForegroundColor Blue "Downloaded file: '$($file.ServerRelativeUrl)'"
	}


	#* REFERENCE AND *RECURSIVELY* DOWNLOAD ALL SUBFOLDERS

	# Get references to subfolders stored in the folder 
	$subFoldersRefObj = Get-PnPFolderItem -FolderSiteRelativeUrl $tldUrl -ItemType Folder

	# Iterate through subFoldersRefObj and download all subfolders recursively
	foreach ($subFolder in $subFoldersRefObj) { # |	where {$_.Name -ne "Forms"}
		Write-Host -ForegroundColor Green "Recursive call for: '$($subFolder.ServerRelativeUrl)$($subFolder.Name)'"
		downloadSharePointSiteContents $subFolder $absDownloadPath
	}

}


#* SCRIPT STARTS HERE

# 1. Connect to PnP Online.
Connect-PnPOnline -Url "$siteDomain$spUrl$siteRelUrl" -Interactive

# 2. Create object to store references to files.
$tld = Get-PnPFolder -Url "$libraryName" 

# 3. Call function to download entire SharePoint site's contents.
downloadSharePointSiteContents $tld $absDownloadPath


# NOTES
# 1. For those that don't program, the script begins at 1., but
#		before it reaches that point, the context of script (function)
# 	is loaded/referenced. So, this script can only invoke functions
# 	that have been loaded into context.
# 2. "| Out-Null", is equivalent to " > /dev/null" in Linux. It 
# 	redirects stdout to null, thereby not displaying it (or passing
# 	it down the pipeline). 
#		Link, https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/out-null?view=powershell-7.4
# 3. Check if an object is null: "Write-Host -ForegroundColor Red 
#		'$($tld -eq $null)'"
