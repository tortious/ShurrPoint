
sharepointdiary.com

# How to Connect to SharePoint Online from PowerShell?

I know I’ve said it several times, but I’ll say it again: I Love PowerShell! PowerShell is a Microsoft administrative task automation and configuration management framework that allows you to administer Microsoft products, including SharePoint Online. Connecting to SharePoint Online from PowerShell makes repetitive tasks easier and our lives smarter, and helps automate complex tasks and reduces the risk of human errors.

Managing SharePoint Online through the graphical user interface can be slow and cumbersome when you need to make many changes or handle repetitive administration tasks. That’s why Microsoft provides the incredibly helpful SharePoint Online Management Shell – to give admins access to a rich toolset of PowerShell cmdlets for streamlining management. In this post, we’ll learn how to connect to your SharePoint Online environment from PowerShell.
Table of contents

1.    Connect to SharePoint Online using Connect-SPOService in PowerShell

        Step 1: Install the SharePoint Online Management Shell or SharePoint Online PowerShell Module
  
        Step 2: Connect to SharePoint Online PowerShell using the Connect-SPOService cmdlet
  
        Step 3: Start using SharePoint Online PowerShell cmdlets!
  
    SharePoint Online PowerShell Examples
        SharePoint Online PowerShell to Create Site Collection
        Create a group in SharePoint Online with PowerShell ISE
        Get Tenant Settings using PowerShell
    Connect to SharePoint Online using Saved Credentials
    Connect SharePoint Online PowerShell with MFA (Multifactor Authentication)
    PowerShell commands for SharePoint Online – Index of SharePoint Online PowerShell cmdlets:
    Most Common PowerShell Cmdlets to Manage SharePoint Online
    Wrapping up

Why should we use PowerShell to Manage SharePoint Online? If you’re a SharePoint administrator, you know that PowerShell is your best friend. With PowerShell, you can automate many tasks that would otherwise take a long time to complete. Not just that, There are several reasons why we use PowerShell:

    Perform bulk operations to speed up the process – e.g., Applying settings to all sites, document libraries, etc.
    Generate reports – E.g., Export all user permissions from a site
    Certain operations and configurations can only be done and are available only through PowerShell
    Automate common repetitive tasks with the help of the Windows Task Scheduler.
    Query and Filter the data
    Configure services, manipulate objects, Monitoring, etc.

In this post, I will show you how to connect to SharePoint Online using PowerShell as a beginner. So, to start with, follow these steps to connect to SharePoint Online via PowerShell:
Step 1: Install the SharePoint Online Management Shell or SharePoint Online PowerShell Module

Make sure you have installed the PowerShell and SharePoint Online PowerShell Module. To download Windows Management Framework 3, which includes PowerShell 3.0: https://www.microsoft.com/en-us/download/details.aspx?id=34595

# Download and Install SharePoint Online Management Shell
To get started with SharePoint Online PowerShell, You have to download and install SharePoint Online Management Shell. Download PowerShell for the SharePoint Online module at https://www.microsoft.com/en-us/download/details.aspx?id=35588, and run the installer in administrative mode.
install powershell for sharepoint online

This lets you automate common tasks and perform bulk operations on your SharePoint Online environment.

Update: Instead of downloading and installing the MSI file, you can also install the PowerShell module for SharePoint Online from PowerShell Gallery, if you are running with an operating system like Windows 10, that supports PowerShell version 5 or newer: Install-Module -Name Microsoft.Online.SharePoint.PowerShell, Refer here for more info: Install SharePoint Online Management Shell Module via PowerShell

How to check the SharePoint Online Management Shell version? Use the Control Panel >> Add/Remove programs to find the installed version of SharePoint Online Management Shell! You can also use Control Panel – Add/Remove programs to uninstall the SharePoint Online management shell.
Step 2: Connect to SharePoint Online PowerShell using the Connect-SPOService cmdlet

Before you can connect to SharePoint Online using the Connect-SPOService cmdlet, you’ll need to ensure that a few prerequisites are met. Here’s what you need:
Prerequisites to Connect to SharePoint Online with the Connect-SPOService cmdlet

    SharePoint Admin Role and Credentials in Microsoft 365 (Office 365)
    Network Access – Ensure that your network and firewall settings allow outbound connections to SharePoint Online.
    Required Permissions for Sites – You need permission for site collection and admin rights to specific sites (Even though you already have SharePoint administrator or global admin rights!).
    Tenant URL – You need to specify the correct SharePoint Online Admin Center URL for your tenant. The URL typically looks like this: https://yourtenant-admin.sharepoint.com

Connect to SharePoint Online from PowerShell

Once the SharePoint Online Management Shell is installed, the next step is to connect to the SharePoint Online site using PowerShell. How do I access SharePoint Online Management Shell? Launch the “SharePoint Online Management Shell” command prompt from the start menu and connect to SharePoint Online Administration Center first and run the following command to connect to SharePoint Online: (Or you can use the Windows PowerShell console / PowerShell ISE as well to run a PowerShell script)

Connect-SPOService -Url https://salaudeen-admin.sharepoint.com `
           -credential salaudeen@salaudeen.onmicrosoft.com

This cmdlet must be executed before we use any other SharePoint Online cmdlets. As soon as you hit enter, you’ll get a login prompt to enter your username and password. Make sure you connect with an account with minimum permission of the SharePoint Online administrator and use HTTPS in the admin site URL. You’ll get a prompt for the password.
Connect to SharePoint Online with PowerShell
Step 3: Start using SharePoint Online PowerShell cmdlets!

How to use SharePoint Online Management Shell? Once connected, you can start managing SharePoint Online with PowerShell cmdlets for the SharePoint Online tenant or individual sites, E.g., Get-SPOSite cmdlet. Here are some examples of how to use the SharePoint Online Management Shell. Let’s create a site collection in SharePoint Online using PowerShell.

Here are some examples of common tasks for managing SharePoint Online using PowerShell:
SharePoint Online PowerShell to Create Site Collection

Now you can access SharePoint Online from PowerShell and start managing SharePoint sites (From PowerShell console/SharePoint Online Management Shell or PowerShell ISE). Let’s create a new SharePoint site using the following cmdlet.

#Lets create a new Site collection:
New-SPOSite -Url https://salaudeen.sharepoint.com/sites/Sales `
   -Owner salaudeen@salaudeen.onmicrosoft.com -StorageQuota 1000 -Title "Sales Site" 

powershell script to connect to sharepoint online

Once you’ve finished, You can disconnect the PowerShell session with “Disconnect-SPOService”. However, it’s not mandatory. Generally, it’s a good idea to leave the connection open until and unless you work with different tenants.

Do I need Global Administrator rights to run PowerShell Cmdlets for SharePoint Online?
You need SharePoint Online administrator or Global Administrator rights in order to run these PowerShell scripts. However, to run CSOM or PnP PowerShell scripts at the site level, You just require site collection Administrator rights.
Create a group in SharePoint Online with PowerShell ISE

How to run a PowerShell script for SharePoint Online? You can use PowerShell ISE to run the PowerShell script for SharePoint Online. Let’s create a group using PowerShell for SharePoint Online with the below commands.

#Load SharePoint sharepoint online powershell module
Import-Module Microsoft.Online.SharePoint.Powershell -DisableNameChecking

#connect to sharepoint online site collection using powershell
Connect-SPOService -Url https://salaudeen-admin.sharepoint.com `
      -credential salaudeen@salaudeen.onmicrosoft.com

#create group
New-SPOSiteGroup -Site https://salaudeen.sharepoint.com/sites/Sales  `
            -Group "Sales Managers" -PermissionLevels "Full Control" 

how to run powershell on sharepoint online
Get Tenant Settings using PowerShell

Even more generic code to connect to SharePoint Online through PowerShell would be with the below cmdlets:

#Import SharePoint Online PowerShell module
Import-Module Microsoft.Online.Sharepoint.PowerShell -DisableNameChecking

#SharePoint Admin Center URL - Set it accordingly
$AdminSiteURL= "https://crescent-admin.sharepoint.com"

#Get credentials to connect
$Credential = Get-Credential

#Connect to SharePoint Online services
Connect-SPOService -url $AdminSiteURL -Credential $credential

#Get Tenant settings
Get-SPOTenant

What if you don’t want to get the credentials prompt? For example, save credentials in the script and schedule them in the Windows task scheduler. Here is how to connect to SharePoint Online from PowerShell using the user ID and password:

#Variables for processing
$AdminCenterURL = "https://crescent-admin.sharepoint.com"

#User Name Password to connect 
$AdminUserName = "Salaudeen@crescent.com"
$AdminPassword = "Password goes here"

#Prepare the Credentials
$SecurePassword = ConvertTo-SecureString $AdminPassword -AsPlainText -Force
$Credential = new-object -typename System.Management.Automation.PSCredential -argumentlist $AdminUserName, $SecurePassword
 
#Connect to SharePoint Online
Connect-SPOService -url $AdminCenterURL -Credential $Credential
 
#Get all Site colections with SharePoint PowerShell
Get-SPOSite

All these methods apply to OneDrive for Business as well, to connect from PowerShell. There is no separate PowerShell module available for OneDrive.

How do I connect to SharePoint Online with MFA enabled accounts from PowerShell? To connect with SharePoint Online, where multifactor authentication is enabled, simply remove the -Credential parameter from the “Connect-SPOService” cmdlet.

Connect-SPOService -Url https://YourTenant-admin.sharepoint.com

Hit Enter, and You’ll get a popup (which is MFA aware) to enter the credentials and the code from multifactor authentication. To learn more about connecting to SharePoint Online with MFA-enabled accounts, refer to my other post: PowerShell: Connect to SharePoint Online with MFA

For the list of available cmdlets for SharePoint Online, Refer to SharePoint Online PowerShell cmdlets at https://learn.microsoft.com/en-us/powershell/module/sharepoint-online/?view=sharepoint-ps. You can also use this cmdlet to list SharePoint Online PowerShell cmdlets:

Get-Command -Module Microsoft.Online.SharePoint.PowerShell

connect to sharepoint online using powershell

This lists all Sharepoint Online PowerShell commands that are available. You may have noticed all the cmdlets will follow the pattern: Verb-Noun. E.g., Add-SPOUser.

Limitation: Unlike SharePoint on-premises, SharePoint Online offers only the least set of PowerShell cmdlets to manage SharePoint Online. For example, There are no direct PowerShell cmdlets to activate a feature, create a subsite, create a list, add a list item, get data from SharePoint list, download files from SharePoint, etc. The solution would be utilizing the client-side object model (CSOM) components with PowerShell! How to Connect to SharePoint Online using CSOM PowerShell?

Client Side Object Model (CSOM) is a subset of SharePoint Online Management Shell!

Here are the most common PowerShell cmdlets for SharePoint Online from the SharePoint Online Management Shell:
Cmdlet	Description	Reference
Get-SPOSite	Gets one or more site collections	SharePoint Online: Get All Site Collections using PowerShell
Set-SPOSite	Updates property values on a site collection	SharePoint Online: Change the Storage Quota of a Site Collection using PowerShell

SharePoint Online: How to Lock a Site Collection using PowerShell?
New-SPOSite	Creates a new site collection	How to Create a SharePoint Online Site Collection using PowerShell?
Remove-SPOSite	Deletes a site collection	How to Delete a SharePoint Online Site using PowerShell?
Get-SPOUser	Get all users for a site collection	How to Get All Users in a SharePoint Online Site Collection using PowerShell?
Get-SPOHomeSite, Set-SPOHomeSite, Remove-SPOHomeSite	Gets/Sets a SharePoint Site as a Home Site.	Getting Started with Home Site in SharePoint Online
Add-SPOHubSiteAssociation, Get-SPOHubSite, Register-SPOHubSite, Remove-SPOHubSiteAssociation	Gets/Associates/removes a site with a hub site.	How to Create Hub Sites in SharePoint Online: Step by Step
Get-SPOOrgAssetsLibrary, Add-SPOOrgAssetsLibrary	Gets/Designates a library to be used as a central location for organization assets across the tenant.	How to Create an Organization Assets Library in SharePoint Online?
Add-SPOSiteCollectionAppCatalog	Adds a Site Collection scoped App Catalog to a site.	How to Create an App Catalog Site in SharePoint Online?
Add-SPOSiteDesign, Add-SPOSiteScript, Invoke-SPOSiteDesign	Creates a new site design and site scripts available to users when they create a new site from the SharePoint home page.	How to Create a Site Design and Site Scripts in SharePoint Online using PowerShell?
Get-SPOTheme, Add-SPOTheme	Creates a new custom theme, or overwrites an existing theme to modify its settings.	How to Create a Custom Theme in SharePoint Online using PowerShell?
Add-SPOUser	Adds an existing Office 365 user or an Office 365 security group to a SharePoint group.	How to Add user to Group in SharePoint Online using PowerShell?
Connect-SPOService	Connects a SharePoint Online administrator to SharePoint Online Administration Center.	How to Connect to SharePoint Online from PowerShell?
Enable-SPOCommSite	Enables the communication site experience on an existing classic team site.	How to Convert Classic Team Site to a Communication Site in SharePoint Online?
Export-SPOUserInfo	Export user information from site user information list.	How to Export User Information List in SharePoint Online using PowerShell?
Get-SPOBrowserIdleSignOut, Set-SPOBrowserIdleSignOut	Used to retrieve/update the value for Idle session sign-out policy.	How to Change Idle Session Timeout Settings in SharePoint Online?
Get-SPODeletedSite	Returns all deleted site collections from the Recycle Bin.	How to Get All Deleted Sites in SharePoint Online using PowerShell?
Get-SPOExternalUser	Gets all external users in the tenant.	How to Find All External Users in SharePoint Online using PowerShell?
Get-SPOHideDefaultThemes, Set-SPOHideDefaultThemes	Gets/Hides the default themes in SharePoint Online	How to Hide the Default Themes in SharePoint Online?
Get-SPOSiteGroup	Gets all the groups on the specified site collection.	How to Get All SharePoint Groups in a SharePoint Online site using PowerShell?
Get-SPOTenant, Set-SPOTenant	Gets/sets tenant settings	Get SharePoint Online Tenant Settings using PowerShell

How to Enable or Disable the “Everyone” Group in SharePoint Online?

How to Enable or Disable Comments in SharePoint Online List?
Get-SPOWebTemplate	Displays all site templates that match the given identity.	Get Site Templates in SharePoint Online using PowerShell
Invoke-SPOSiteSwap	Invokes a job to swap the location of a site with another site while archiving the original site.	How to Replace a Classic Root Site Collection with a Modern Site in SharePoint Online?
New-SPOSiteGroup	Creates a new group in a SharePoint Online site collection.	How to Create a SharePoint Group using PowerShell?
Remove-SPODeletedSite	Removes a SharePoint Online deleted site collection from the Recycle Bin.	How to Remove a Deleted SharePoint Online Site Collection from Recycle Bin using PowerShell?
Remove-SPOExternalUser	Removes external users from the tenant.	How to Remove External Users in SharePoint Online using PowerShell?
Remove-SPOSiteGroup	Removes a SharePoint Online group from a site collection.	How to Delete a SharePoint Group from SharePoint Online site using PowerShell?
Remove-SPOTheme	Removes a theme from the theme gallery.	How to Remove a Custom Theme in SharePoint Online using PowerShell?
Remove-SPOUser	Removes a user or a security group from a site collection or a group.	How to Remove a User from SharePoint Online Site Collection using PowerShell?
Remove-SPOUserProfile	Remove user profile from the tenant.	How to Delete a User Profile in SharePoint Online using PowerShell?
Request-SPOPersonalSite	Requests that one or more users be enqueued for a Personal Site to be created.	How to Create OneDrive for Business Site Collections using PowerShell?
Restore-SPODeletedSite	Restores a SharePoint Online deleted site collection from the Recycle Bin.	How to Restore a Deleted SharePoint Online Site Collection using PowerShell?
Set-SPOUser	Configures properties on an existing user.	How to Add a Site Collection Administrator in SharePoint Online using PowerShell?

How to Remove a Site Collection Administrator in SharePoint Online using PowerShell?
Set-SPOWebTheme	Sets the theme for a SharePoint site.	How to Apply a Theme in SharePoint Online using PowerShell?
Start-SPOSiteRename	Change the site collection URL, and, optionally, the site title	How to Change the Site URL in SharePoint Online?

The key cmdlets allow you to manage site collections, sites, and lists in your SharePoint Online environment. Things like getting, setting, creating, and deleting sites and lists are essential SharePoint admin tasks.
PnP PowerShell Module and cmdlets

SharePoint Patterns and Practices (PnP) is a cross-platform PowerShell module that contains a library of PowerShell cmdlets that allows you to perform complex operations in Microsoft 365 products such as SharePoint Online, Microsoft Teams, Microsoft Planner, Power Automate, etc., with one single cmdlet. To connect to SharePoint Online using the PnP PowerShell module, refer to How to Connect to SharePoint Online using PnP PowerShell?
Wrapping up

Connecting to SharePoint Online with PowerShell opens up many possibilities for efficiently managing your SharePoint environment. After going through the one-time setup of installing the SharePoint Online Management Shell and connecting to SPO, you unlock access to hundreds of PowerShell cmdlets for administration.

We walked through the essential steps of setting up SPO PowerShell. This includes installing the modules, loading your tenant admin credentials into a PSCredential object, and then connecting to the SPO service with that credential. Now that you have connected, you can run PowerShell cmdlets to manage site collections, sites, lists, libraries, users, and permissions – almost every aspect of your SharePoint Online portal. Automating tasks with PowerShell saves enormous amounts of time compared to clicking around the UI.

In summary, mastering SharePoint Online PowerShell administration unlocks simpler management, richer reporting capabilities, and automation to handle repetitive tasks. I encourage you to further explore the vast set of available cmdlets. Microsoft expands the functionality of the online service every year. Refer to the SharePoint Online PowerShell Official Documentation to leverage the latest and greatest features through PowerShell.
