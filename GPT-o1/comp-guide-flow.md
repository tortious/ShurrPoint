Below is a comprehensive, step-by-step walkthrough demonstrating how to build a Microsoft Power Automate “Flow” that—upon adding an item to a SharePoint list (named “JEFF list”)—creates a new Group-connected Team Site in SharePoint (for Microsoft Teams) under a “Case Management” hub, and then applies a PnP Provisioning Template (cleantemplate.xml) using the latest PnP PowerShell (nightly) module.

Overview of What We’ll Build
	1.	Trigger: A new item is added to a specific SharePoint list called “JEFF list.”
	2.	Action: A new SharePoint Online Team site (with an associated Microsoft 365 Group) is automatically created.
	3.	Configuration: The newly created site is joined to the Case Management hub.
	4.	Provisioning: We apply the cleantemplate.xml provisioning template to the new site using the latest PnP PowerShell commands.

Although there are many ways to integrate Power Automate (Flow) with PnP PowerShell (e.g., via Azure Automation, an Azure Function, or a custom connector), the key concepts remain consistent. Below, we will break everything down step-by-step in friendly, layman’s terms—so you can imagine you’re explaining this to a teammate who’s done it only a few times before.

Table of Contents
	1.	Prerequisites
1.1. Install/Update PnP PowerShell (Nightly)
1.2. Permissions & Access Needed
1.3. Where To Store cleantemplate.xml
	2.	High-Level Flow Diagram
	3.	Step-by-Step Guide
3.1. Create/Identify the “JEFF list” in SharePoint
3.2. Outline the Flow in Power Automate
3.3. Build the Power Automate Flow
- Trigger
- Run PnP PowerShell (Nightly) to provision site
- Apply the provisioning template
3.4. Associate the Newly Created Site with the Case Management Hub
	4.	PnP PowerShell Script Example
	5.	Validations & Final Checks
	6.	Appendix: Visual Aids & Helpful Tips

1. Prerequisites

Before you begin, confirm a few details:

1.1 Install/Update PnP PowerShell (Nightly)

You need the PnP.PowerShell module (nightly build) on whichever machine or service will run your script (for example, within an Azure Automation runbook or on a local server).
	1.	Uninstall any older PnP modules:

# If you have the older 'SharePointPnPPowerShellOnline' installed:
Uninstall-Module SharePointPnPPowerShellOnline -AllVersions -Force

# If you have the stable release of 'PnP.PowerShell':
Uninstall-Module PnP.PowerShell -AllVersions -Force


	2.	Install the nightly build:

Install-Module PnP.PowerShell -AllowPrerelease -Force

	Make sure to run PowerShell as an administrator. The -AllowPrerelease flag gets the nightly build.

1.2 Permissions & Access Needed
	•	Admin credentials with permission to create new Microsoft 365 Groups and register hub sites.
	•	Site Collection Admin rights on the Case Management Hub (to associate newly created sites).

1.3 Where to Store cleantemplate.xml
	•	The provisioning XML file (cleantemplate.xml) needs to be accessible to your script:
	•	You could store it in a SharePoint Document Library and download it during the script run.
	•	Or keep it in an Azure Storage or GitHub.
	•	Be sure your script path or URL to the template is correct in the PnP commands.

2. High-Level Flow Diagram

Below is a simple conceptual flow diagram (in ASCII-style) showing the major steps:

   +--------------------+
   | SharePoint "JEFF"  |
   | List               |
   +---------+----------+
             |
   [1] New item added
             |
             v
   +----------------------------+
   | Power Automate Flow       |
   | - Trigger on new item     |
   | - Collect site details    |
   +-------------+-------------+
                 |
   [2] Run a script (PnP PS)   |
   (Azure Automation, etc.)
                 |
                 v
   +------------------------------+
   | PnP PowerShell commands      |
   | - Create new Team site       |
   | - Apply "cleantemplate.xml"  |
   | - Associate with hub         |
   +------------------------------+

3. Step-by-Step Guide

3.1 Create/Identify the “JEFF list” in SharePoint
	1.	Go to SharePoint in your browser and navigate to the site or subsite where you want the “JEFF list” to live.
	2.	Create a new Custom List (unless you already have one) named “JEFF”.
	3.	Add relevant columns so you can store any details needed for site creation. For example:
	•	“Title” (SharePoint default)
	•	“Site Name” (single line of text)
	•	“Site Alias” (single line of text)
	•	“Requester” (person or group)

3.2 Outline the Flow in Power Automate

You will have a Flow with the following key parts:
	1.	Trigger: “When an item is created” in the JEFF list.
	2.	Actions:
	•	(Optional) Retrieve item metadata or do some checks.
	•	Call a PnP PowerShell script that:
	•	Connects to SharePoint Online.
	•	Creates a new Group-connected Team Site (for Teams).
	•	Applies the provisioning template (cleantemplate.xml).
	•	Joins the new site to the “Case Management” hub site.

Because Power Automate does not run PnP PowerShell natively, you have a couple of common approaches:
	•	Azure Automation: Easiest for simple scheduled tasks or triggered tasks.
	•	Azure Function: More advanced, but more flexible.
	•	On-Premises Gateway: If you want a local machine with PnP installed to do the heavy lifting.

Below, we’ll conceptually demonstrate the Azure Automation method.

3.3 Build the Power Automate Flow

Note: The exact steps vary depending on your environment, but here’s the general process.
	1.	Navigate to Power Automate: https://make.powerautomate.com/
	2.	Create a new Flow.
	3.	Choose a trigger: “When an item is created (SharePoint)”:
	•	Select your Site Address (where “JEFF” list lives).
	•	Select the List Name: “JEFF”.
	4.	Add an Action: “Initialize Variable” (optional but often helpful):
	•	Name: varSiteName
	•	Type: String
	•	Value: @{triggerBody()?['SiteName']} (or however you parse from your SharePoint columns)
	5.	Add another Action: “HTTP” or “Create Job in Azure Automation**” – depending on how you plan to call your PnP script:
	1.	Azure Automation approach:
	•	Action: “Create Job” (Azure Automation).
	•	Provide your Automation Account name, Resource Group, etc.
	•	In the “Parameters” field, pass the Site Name, Site Alias, or any other needed arguments for the PowerShell Runbook.
	2.	If you have a custom solution that calls PnP PowerShell, you’d do something similar in a custom action.
	6.	Add a final step (Optional) for notifications or logging:
	•	“Send an Email” or “Teams message” that states: “Site created successfully!”

Once saved, your Flow listens for new items in the JEFF list and calls your runbook or script.

3.4 Associate the Newly Created Site with the Case Management Hub

When the PnP script finishes creating the new site, it will also need to join the site to your “Case Management” hub. That is typically done using the PnP cmdlet:

Add-PnPHubSiteAssociation -Site <URL-of-new-site> -HubSiteId <GUID-of-CaseManagementHub>

We’ll show a consolidated script example next.

4. PnP PowerShell Script Example

Below is a simplified version of what your PnP PowerShell script (run by Azure Automation, or any other hosting mechanism) might look like using the PnP.PowerShell (Nightly) module. Adjust as needed for your environment:

param (
    [Parameter(Mandatory=$true)]
    [string]$SiteName,
    
    [Parameter(Mandatory=$true)]
    [string]$SiteAlias,
    
    [Parameter(Mandatory=$true)]
    [string]$HubSiteId,  # ID of the Case Management hub
    
    [Parameter(Mandatory=$true)]
    [string]$TemplateFilePath  # e.g., 'https://yoursite.sharepoint.com/sites/templates/cleantemplate.xml'
)

# 1. Connect to SharePoint (Admin Center)
Connect-PnPOnline -Url "https://<tenant>-admin.sharepoint.com" -Interactive

# 2. Create a new Group-connected Team Site
Write-Host "Creating new site: $SiteName with alias: $SiteAlias"
New-PnPSite -Type TeamSite -Title $SiteName -Alias $SiteAlias -Wait

# 3. Form the new site URL (typical pattern)
$SiteUrl = "https://<tenant>.sharepoint.com/sites/$SiteAlias"

Write-Host "Site created at $SiteUrl"

# 4. Apply the provisioning template (cleantemplate.xml)
Write-Host "Applying provisioning template from $TemplateFilePath"
Connect-PnPOnline -Url $SiteUrl -Interactive
Apply-PnPProvisioningTemplate -Path $TemplateFilePath

# 5. Associate the new site with the Case Management hub
Write-Host "Associating site with Hub ID: $HubSiteId"
Add-PnPHubSiteAssociation -Site $SiteUrl -HubSiteId $HubSiteId

Write-Host "Done!"

Notes and Explanations
	•	Connect-PnPOnline -Interactive: Prompts an interactive sign-in. For automation, consider using an app registration or certificate-based auth instead.
	•	New-PnPSite -Type TeamSite: Creates a Microsoft 365 Group-connected Team Site (modern).
	•	Apply-PnPProvisioningTemplate: This is where your cleantemplate.xml is applied. In the nightly PnP module, you might also see this command referred to as Invoke-PnPSiteTemplate. Check the exact command name in your nightly build; if Apply-PnPProvisioningTemplate is deprecated, it will guide you to the new command.
	•	Add-PnPHubSiteAssociation: Associates the new site with an existing hub site by passing the HubSiteId.

5. Validations & Final Checks

After you have everything set up:
	1.	Create a new item in the JEFF list.
	•	Fill in the required columns (Site Name, Site Alias, etc.).
	2.	Verify the Flow runs successfully.
	•	Check Flow run history in Power Automate.
	3.	Check Azure Automation (or wherever your script is running) to ensure the job finishes without errors.
	4.	Open the new site to confirm:
	•	It is accessible via the URL (e.g., https://tenant.sharepoint.com/sites/<alias>).
	•	The cleantemplate.xml customizations appear (pages, libraries, content types, or any other structural changes).
	•	The new site is indeed joined to the Case Management hub.

6. Appendix: Visual Aids & Helpful Tips

Below are some quick text-based “mock visuals.” In a real document, you might include screenshots, but here we’ll outline what you’d typically see.

6.1 Power Automate Flow Steps (Mock Screenshot)

┌─────────────────────────────────────────────────────────┐
│      Power Automate: Edit your Flow                    │
├─────────────────────────────────────────────────────────┤
│ 1. When an item is created [SharePoint]                │
│    - Site Address: https://<tenant>.sharepoint.com/sites/contoso
│    - List Name: JEFF list
├─────────────────────────────────────────────────────────┤
│ 2. Initialize variable [String]                        │
│    - Name: varSiteAlias
│    - Value: @{triggerBody()?['SiteAlias']}
├─────────────────────────────────────────────────────────┤
│ 3. Create Job [Azure Automation]                       │
│    - AutomationAccountName: MyPnPRunbook               │
│    - ResourceGroupName: MyResourceGroup                │
│    - RunbookName: CreateAndProvisionSite               │
│    - Parameters:                                       │
│        SiteAlias: @{variables('varSiteAlias')}         │
│        TemplateFilePath: <URL to cleantemplate.xml>    │
├─────────────────────────────────────────────────────────┤
│ 4. Send an email [Outlook]                             │
│    - To: you@contoso.com                               │
│    - Subject: New site created                         │
│    - Body: "Site created with alias: @{varSiteAlias}"  │
└─────────────────────────────────────────────────────────┘

6.2 Checking the Site in SharePoint Admin Center
	1.	Go to SharePoint Admin Center → “Active Sites”.
	2.	Search for the newly created site (by alias or title).
	3.	Confirm it appears and is Hub Associated with “Case Management” hub.

6.3 Confirming cleantemplate.xml Was Applied
	1.	Browse to the new site → check if the pages, web parts, or libraries defined in cleantemplate.xml are present.
	2.	If you have any custom columns or content types, ensure they appear as expected.

Final Thoughts

By following the steps above:
	1.	You have a Flow that triggers whenever a new “JEFF list” item is created.
	2.	That Flow calls a PnP PowerShell script in an automated manner (via Azure Automation or similar).
	3.	Your script:
	•	Creates a new modern Team site with a Microsoft 365 Group.
	•	Applies the cleantemplate.xml provisioning template.
	•	Joins the newly provisioned site to the Case Management hub.

This design is modular and scalable, so you can expand it (e.g., adding new templating logic, more lists, or different site types). Always verify you’re using the correct nightly PnP PowerShell commands, as naming for “Apply-PnPProvisioningTemplate” vs. “Invoke-PnPSiteTemplate” can change in pre-release versions.

Congratulations! You now have a repeatable, automated process that handles new site creation as soon as a record is added to the “JEFF” list—applied with your custom “cleantemplate.xml” and automatically associated to the Case Management hub.

Feel free to enhance your Flow with error handling, approval steps, or additional logging as your environment grows.