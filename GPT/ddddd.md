# Reload SharePoint Page Automatically using JavaScript

**May 15, 2016** by Salaudeen Rajack

## Requirement
Automatically reload a SharePoint page at a specific interval.

## How to Reload SharePoint Page Automatically using JavaScript?
To automatically reload a SharePoint page, you can use JavaScript. Here are the steps:

### Step 1: Edit the SharePoint Page
1. Navigate to the SharePoint page you want to reload automatically.
2. Click on the "Edit" button to edit the page.

### Step 2: Add a Content Editor Web Part
1. In the edit mode, click on "Insert" from the ribbon.
2. Select "Web Part" and then choose "Media and Content" > "Content Editor".
3. Click on "Add" to insert the Content Editor Web Part.

### Step 3: Add JavaScript Code
1. Edit the Content Editor Web Part.
2. Click on "Edit Snippet" and add the following JavaScript code:

```javascript
<script type="text/javascript">
    setTimeout(function(){
       location.reload();
    }, 300000); // 300000 milliseconds = 5 minutes
</script>
```
Click on “Insert” to add the code.
Save and publish the page.
Explanation
The setTimeout function is used to execute the location.reload() method after a specified interval (in milliseconds).
In this example, the page will reload every 5 minutes (300000 milliseconds).
Conclusion
Using JavaScript to automatically reload a SharePoint page can be useful for scenarios where you need to ensure the page content is always up-to-date without manual intervention.

Salaudeen Rajack - Information Technology Expert with two decades of hands-on experience, specializing in SharePoint, PowerShell, Microsoft 365, and related products.

Recent Popular Tags

PnP PowerShell
AADSTS700016: Application with identifier ‘31359c7f-bd7e-475c-86db-fdb8c937548e’ was not found in the directory
The New Forms in SharePoint Online Lists: All You Need to Know!
How to Create a Document Library Template in SharePoint Online?
SharePoint Online: Remove “Everyone except external users” from All Sites
SharePoint Online: Apps Usage Report using PowerShell
Disclaimer This is my personal blog. Articles written on this blog are from my experience for my own reference and to help others. Do not reproduce my content anywhere, in any form without my permission. If any article written on this blog violates copyright, please contact me! If you have a more elegant solution on any of the topics discussed – please post a comment, I’ll be happy to hear!

Frequently Asked Questions:

SharePoint Recycle Bin: A Comprehensive Guide - June 17, 2022
The Essential Guide to SharePoint Lists - December 2, 2021
SharePoint Online: Get Site Permissions Report using PowerShell - September 25, 2019
Connect to SharePoint Online using PowerShell with MFA (Multi-factor Authentication) - August 30, 2019
SharePoint Online: How to Disable Download Option for Documents? - July 15, 2019
How to Run PowerShell Scripts for SharePoint Online? - July 6, 2019
SharePoint Online: Add Site Collection Administrator using PowerShell - August 1, 2015
