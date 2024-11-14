<# 
.SYNOPSIS
        Get-CustomScriptStatus.ps1 - Loops through all sites and reports on the Custom Script settings.

.DESCRIPTION
        This script connects to SharePoint Online and retrieves information about the Custom Script settings for all sites. 
        It checks whether Custom Script is enabled or disabled on each site and generates a CSV report with the results.
        
.NOTES
        File Name: Get-CustomScriptStatus.ps1
        Author: Mike Lee
        Date: 5/23/2024
        Disclaimer: The sample scripts are provided AS IS without warranty of any kind. 
        Microsoft further disclaims all implied warranties including, without limitation, 
        any implied warranties of merchantability or of fitness for a particular purpose. 
        The entire risk arising out of the use or performance of the sample scripts and documentation 
        remains with you. In no event shall Microsoft, its authors, or anyone else involved in the creation, 
        production, or delivery of the scripts be liable for any damages whatsoever (including, without limitation, 
        damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) 
        arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has 
        been advised of the possibility of such damages.

.EXAMPLE
        Get-CustomScriptStatus.ps1 
        Connects to the SharePoint Online tenant and retrieves the Custom Script status for all sites.

#>

#Configurable Settings
$t = 'CONTOSO' # < - Your Tenant Name Here

#Connect to SPO
Connect-SPOService -Url ('https://' + $t + '-admin.sharepoint.com')

#Get All Sites
$sites = Get-SPOSite -Limit ALL

#Log files paramaters
$date = Get-Date -Format yyyy-MM-dd_HH-mm-ss
$outFilePath = "$env:TEMP\" + 'CustomScript_Status' + '_' + $date + ".csv"
$global:output = @()

Function findsites {
        foreach ($site in $sites) {

                Try {
                        #we are exporting all sites and reporting on the custom script status
                        if ($site.DenyAddAndCustomizePages -eq 'Disabled') {
                                $ExportItem = New-Object PSObject
                                $ExportItem | Add-Member -MemberType NoteProperty -name "Site" -value $site.url
                                $ExportItem | Add-Member -MemberType NoteProperty -name "Template" -value $site.Template
                                $ExportItem | Add-Member -MemberType NoteProperty -name "Custom Script Allowed" -value "Yes"                            
                                $global:output += $ExportItem
                                Write-Host ""
                                Write-Host "Custom Script is Enabled on $($site.url)"    -ForegroundColor Yellow
                        }

                        if ($site.DenyAddAndCustomizePages -eq 'Enabled') {
                                $ExportItem = New-Object PSObject
                                $ExportItem | Add-Member -MemberType NoteProperty -name "Site" -value $site.url
                                $ExportItem | Add-Member -MemberType NoteProperty -name "Template" -value $site.Template
                                $ExportItem | Add-Member -MemberType NoteProperty -name "Custom Script Allowed" -value "No"                           
                                $global:output += $ExportItem
                                Write-Host ""
                                Write-Host "Custom Script is Disabled on $($site.url)"   -ForegroundColor Green
                        } 
        
                }

                catch {
                        Write-Host "Error occurred while processing $($site.url): $_" -ForegroundColor Red
                }
        }
}
findsites
$output | Export-CSV $outFilePath -NoTypeInformation
Write-Host "Log files $outFilePath was saved"
