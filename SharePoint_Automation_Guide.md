
# SharePoint Online Automation and PowerShell Guide

### **Step 1: SharePoint Online Management Shell Setup**

1. **Install the SharePoint Online Management Shell module:**
   ```powershell
   Install-Module -Name Microsoft.Online.SharePoint.PowerShell -Force
   ```

2. **Connect to your SharePoint Online tenant:**
   ```powershell
   Connect-SPOService -Url https://<YourDomain>-admin.sharepoint.com -Credential (Get-Credential)
   ```

---

### **Step 2: Automating SharePoint Operations**

1. **Create a Site Collection:**
   ```powershell
   New-SPOSite -Url "https://<YourDomain>.sharepoint.com/sites/AutomationSite" `
               -Owner "admin@yourdomain.com" `
               -StorageQuota 1024 `
               -Template "STS#3" `
               -Title "Automation Site"
   ```

2. **Manage User Permissions:**
   - Add a user to a site collection:
     ```powershell
     Add-SPOUser -Site "https://<YourDomain>.sharepoint.com/sites/AutomationSite" `
                 -LoginName "user@yourdomain.com" `
                 -Group "Site Members"
     ```
   - Remove a user:
     ```powershell
     Remove-SPOUser -Site "https://<YourDomain>.sharepoint.com/sites/AutomationSite" `
                    -LoginName "user@yourdomain.com"
     ```

3. **List All Sites in the Tenant:**
   ```powershell
   Get-SPOSite -Limit All
   ```

---

### **Step 3: Using PnP PowerShell for Advanced Automation**
PnP PowerShell provides more robust SharePoint management capabilities.

1. **Install PnP PowerShell:**
   ```powershell
   Install-Module -Name PnP.PowerShell
   ```

2. **Connect to SharePoint Online:**
   ```powershell
   Connect-PnPOnline -Url "https://<YourDomain>.sharepoint.com" -UseWebLogin
   ```

3. **Automate Document Library Creation:**
   ```powershell
   New-PnPList -Title "Automated Documents" -Template DocumentLibrary
   ```

4. **Upload Files to a Library:**
   ```powershell
   Add-PnPFile -Path "C:\Documents\Report.pdf" -Folder "Shared Documents"
   ```

5. **Extract and Export Permissions Report:**
   ```powershell
   Get-PnPGroupMembers -Identity "Site Members" | Export-Csv -Path "C:\PermissionsReport.csv" -NoTypeInformation
   ```

---

### **Step 4: Organizational Scripts**
You can also manage users and groups in Azure AD or automate Office 365 tasks:

1. **Get All Users in a Tenant:**
   ```powershell
   Get-MsolUser | Select-Object DisplayName, UserPrincipalName
   ```

2. **Add a User to a Group:**
   ```powershell
   Add-MsolGroupMember -GroupObjectId "<GroupID>" -GroupMemberType User -GroupMemberObjectId "<UserID>"
   ```

3. **Automate Licenses Assignment:**
   ```powershell
   Set-MsolUserLicense -UserPrincipalName "user@yourdomain.com" -AddLicenses "<YourTenant>:ENTERPRISEPACK"
   ```

---

### **Suggestions for Next Steps**
**a.** Let me know specific SharePoint tasks you'd like to automate, such as workflows, file organization, or site structure updates.  
**b.** If you're interested in creating detailed scripts for recurring operations, share your requirements for customization!
