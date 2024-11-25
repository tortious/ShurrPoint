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

## How to Encode-Decode a URL using PowerShell?

**November 19, 2024** by Salaudeen Rajack

### Requirement

Encode or Decode a URL in SharePoint Online using PowerShell.

### What Are URL Encoding and Decoding?

- **URL Encoding**: Converts special characters in a URL to a format that can be safely transmitted over the web. For example, spaces are replaced with `%20`, and characters like `:` and `/` are converted to their encoded equivalents.
- **URL Decoding**: Converts an encoded URL back to its original, human-readable format. These processes are particularly useful when working with APIs, web requests, or any scenario where URLs must conform to specific standards.

### PowerShell to Decode URL

URL encoding is the process of converting characters in a URL into a format that can be safely transmitted over the internet. Decoding is the reverse process of converting encoded characters back into their original form. In PowerShell, encoding and decoding URLs can be performed using the `[System.Uri]` class and its methods. We need decoded URLs in various scenarios in SharePoint. Say we want to pass the file URL as a parameter to some function.

```powershell
#Parameter
$URL = "https%3A%2F%2Fcrescent.sharepoint.com%2Fsites%2Fmarketing%2F2018%2FDocuments%2FInfo%20Mgmt%20v2%2Epdf"

#Decode URL
[System.Web.HttpUtility]::UrlDecode($URL)

#Output: https://crescent.sharepoint.com/sites/marketing/2018/Documents/Info Mgmt v2.pdf
```
We can also use the UnescapeDataString method from [System.URI] class.
```
$EncodedURL = "https%3A%2F%2Fcrescent.sharepoint.com%2Fpersonal%2Fsalaudeen_crescent_com%2FDocuments%2FAssets%20%26%20Inventory.xlsx"
[system.uri]::UnescapeDataString($EncodedURL)
```

# Decode SharePoint Online URL using PowerShell
We can also use the SharePoint Online method to decode a URL:
```
#Import PowerShell Module for SharePoint Online
Import-Module Microsoft.Online.SharePoint.PowerShell -DisableNameChecking

#Function to Decode URL
Function Decode-URL([string]$URL) {
    Try {
        #Decode the URL
        Return [Microsoft.SharePoint.Client.Utilities.HttpUtility]::UrlKeyValueDecode($URL)
    }
    catch {
        Return "Error Getting Decoded URL: $($_.Exception.Message)"
    }
}

#Parameter
$URL = "https%3A%2F%2Fcrescent.sharepoint.com%2Fsites%2Fmarketing%2F2018%2FShared%20Documents%2FInformation%20Management%20v2%2Epdf"

#Call the function to decode URL
Decode-URL $URL
```
Encode URL in PowerShell
In another situation, I had to calculate the length of the encoded URL in SharePoint and achieved it with the following:
```
$URL = "https://crescent.sharepoint.com/personal/salaudeen_crescent_com/Shared Documents/Assets & Inventory.xlsx"
Write-host ([URI]::EscapeUriString($URL))
```

With [System.Web] class, you can encode a URL as:

```
$URL = "https://crescent.sharepoint.com/personal/salaudeen_crescent_com/Shared Documents/Assets & Inventory.xlsx"
[System.Web.HttpUtility]::UrlPathEncode($URL)
```
To decode SharePoint URLs, you can also use online tools like:

URL Decoder
Eric Meyer’s Decoder
Conclusion
In conclusion, PowerShell makes URL encoding and decoding a breeze with its built-in .NET methods. Using the [System.Uri] class and its method EscapeDataString() can be used to encode URLs, while the UnescapeDataString() method can be used to decode URLs. Whether you’re automating API calls, working with web requests, or simply cleaning up URLs, these techniques can save you time and effort.

Related Posts:

Find the GUIDs of SharePoint Web Application, Site Collection, Site, List, View, and Columns
Recover SharePoint 2007 / 2010 / 2013 Product Key using PowerShell
Add Alternate Access Mapping in SharePoint using PowerShell