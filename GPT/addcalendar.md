# SharePoint Diary

Salaudeen Rajack's Experiences on SharePoint, PowerShell, Microsoft 365, and related products!

## SharePoint Server Deployment Guides

- Central Administration
- Service Applications
- SharePoint Database
- SharePoint 2016
- SharePoint 2013
- SharePoint 2010
- SharePoint 2007
- My Site
- SharePoint Online
- Communication Site
- SharePoint Admin Center
- User Profile
- Term Store

## PowerShell

- PowerShell Tutorials
- String
- Loop
- Array
- Files and Folders
- SharePoint Online Management Shell
- PnP PowerShell
- Client Side Object Model (CSOM)

## Administration

- Admin Reports
- Permission
- Permission Reports
- Site Collection Administrator
- External Sharing
- Anonymous Access
- Site Settings
- Access Request
- Recycle Bin
- Migration/Upgrade
- Backup/Restore
- SQL Server
- Troubleshooting
- Errors and Solutions
- Installation
- Customization
- SharePoint Designer
- Branding
- Tools & Utilities
- Search

## SharePoint Development

- Tips and Tricks
- Security Configuration

## Office 365

- OneDrive for Business
- Office 365 Groups
- Microsoft Teams
- Azure AD (Microsoft Entra)
- Exchange Online

## SharePoint Online

### How to Add Calendar to SharePoint Online Modern Page?

**Requirement:** Display a calendar with a Month view on SharePoint Online home page.

**Steps:**

1. Navigate to the page where you would like to add the calendar web part, such as the Home page.
2. Edit the page and add an “Embed” web part to it and click on “Add embed code”.
3. Use the following format to display the calendar on any modern SharePoint Online page. Change the URL accordingly. You can adjust the height and width parameters as well.

    ```html
    <iframe src="https://Crescent.sharepoint.com/sites/Projects/Lists/Events/calendar.aspx?isDlg=1" width="100%" height="500"></iframe>
    ```

4. Here, I have used the “isDlg=1” parameter to hide the page’s left navigation, top navigation, and other elements. After adjusting some parameters and adding a bit of style to the embed code, here is the calendar web part on the SharePoint Online page:

    ```html
    <iframe src="https://crescent.sharepoint.com/sites/Projects/Lists/Events/calendar.aspx?isDlg=1" scrolling="no" style="margin-top: -130px;" width="100%" height="100%"></iframe>
    ```

**Related Posts:**

- How to Create a Calendar in Modern SharePoint Online Site?
- Product Review: Virto SharePoint Calendar Web Part
- How to Create a Calendar Overlay in SharePoint Online?

---

**About Me:**

Salaudeen Rajack is a globally recognized IT Expert – Specialized in SharePoint, PowerShell, Office 365, and related Microsoft technologies.

---

**Recent Popular Tags:**

- PnP PowerShell – AADSTS700016: Application with identifier ‘31359c7f-bd7e-475c-86db-fdb8c937548e’ was not found in the directory
- The New Forms in SharePoint Online Lists: All You Need to Know!
- How to Create a Document Library Template in SharePoint Online?
- SharePoint Online: Remove “Everyone except external users” from All Sites
- SharePoint Online: Apps Usage Report using PowerShell

---

**Disclaimer:**

This is my personal blog. Articles written on this blog are from my experience for my own reference and to help others. Do not reproduce my content anywhere, in any form without my permission. If any article written on this blog violates copyright, please contact me! If you have a more elegant solution on any of the topics discussed – please post a comment, I’ll be happy to hear!
