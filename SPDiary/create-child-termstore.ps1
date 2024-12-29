#Load SharePoint CSOM Assemblies
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Taxonomy.dll"
 
#Parameters
$TenantURL = "https://crescent.sharepoint.com"
$TermGroupName = "Classification"
$TermSetName = "Tags"
$ParentTermName = "Continent"
 
#Function to Add Child Term (or Sub-term)
Function Add-ChildTerm
{
    param (
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$TermName,
    [parameter(ValueFromPipelineByPropertyName = $true)][int]$Language = 1033,
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Taxonomy.Term]$ParentTerm,
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$Context
    )
    Try {
        $ChildTerm = $ParentTerm.CreateTerm($TermName, $Language, [System.Guid]::NewGuid().toString())
        $ParentTerm.TermStore.CommitAll()
        $Context.ExecuteQuery()
        Write-host "New Term '$TermName' Added Successfully!" -ForegroundColor Green
    }
    Catch {
        write-host -f Red "Error Adding Term:" $_.Exception.Message
    }
}
 
Try {
    #Get Credentials to connect
    $Cred = Get-Credential
  
    #Setup the context
    $Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($TenantURL)
    $Ctx.Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Cred.Username, $Cred.Password)
  
    #Get the term store
    $TaxonomySession=[Microsoft.SharePoint.Client.Taxonomy.TaxonomySession]::GetTaxonomySession($Ctx) 
    $TermStore =$TaxonomySession.GetDefaultSiteCollectionTermStore()
    $Ctx.Load($TaxonomySession)
    $Ctx.Load($TermStore)
    $Ctx.ExecuteQuery()
  
    #Get the Term Group    
    $TermGroup = $TermStore.Groups.GetByName($TermGroupName)
    $Ctx.Load($TermGroup)
  
    #Get the Term Set
    $TermSet = $TermGroup.TermSets.GetByName($TermSetName)
    $Ctx.Load($TermSet)
  
    #Get the Parent term
    $Term = $TermSet.Terms.GetByName($ParentTermName)
    $Ctx.Load($Term)
    $Ctx.ExecuteQuery()
      
    #Call the function to Create a Child Term
    Add-ChildTerm -TermName "America" -ParentTerm $Term -Context $Ctx
}
Catch {
    write-host -f Red "Error:" $_.Exception.Message
}
