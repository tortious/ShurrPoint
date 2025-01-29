# Copy one site's libraries to another, without contents of library
#Parameters
$SourceSiteURL = "https://mordinilaw.sharepoint.com/teams/Cezar2980"
$DestinationSiteURL = "https://mordinilaw.sharepoint.com/sites/Cezar-Template-Copy"
 
#Connect to the source Site
Connect-PnPOnline -URL $SourceSiteURL -Interactive
 
#Get all document libraries
$SourceLibraries =  Get-PnPList | Where {$_.BaseType -eq "DocumentLibrary" -and $_.Hidden -eq $False}
 
#Connect to the destination site
Connect-PnPOnline -URL $DestinationSiteURL -Interactive
 
#Get All Lists in the Destination
$Libraries = Get-PnPList
 
ForEach($Library in $SourceLibraries)
{
    #Check if the library already exists in target
    If(!($Libraries.Title -contains $Library.Title))
    { 
        #Create a document library
        New-PnPList -Title $Library.Title -Template DocumentLibrary
        Write-host "Document Library '$($Library.Title)' created successfully!" -f Green
    }
    else
    {
        Write-host "Document Library '$($Library.Title)' exists already!" -f Yellow
    }
}
