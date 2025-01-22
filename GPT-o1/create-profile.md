Below is a thorough, step-by-step guide on how to create a PowerShell profile without interfering with your SharePoint tenant. A PowerShell profile is simply a local script on your machine that runs each time you open PowerShell—so it won’t affect SharePoint itself. You can safely create or edit this profile to store your custom functions (like vyvanse) or other startup commands.

1. What Is a PowerShell Profile?

A PowerShell profile is a script (a .ps1 file) that automatically runs every time you start PowerShell. Common uses for a profile include:
	•	Defining custom functions and aliases (e.g., your vyvanse function).
	•	Setting environment variables.
	•	Configuring your PowerShell prompt or appearance.

Because the profile is purely local to your machine, it does not directly affect remote systems like SharePoint. It simply automates your local environment so you can work more efficiently.

2. Types of PowerShell Profiles

PowerShell supports several profile locations, but the two most common are:
	1.	Current User, Current Host Profile
	•	Path stored in the $PROFILE variable (e.g., $PROFILE.CurrentUserCurrentHost in PowerShell 7+).
	•	Typically located at:
C:\Users\<YourUserName>\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
	•	This profile affects only the current user and only the current PowerShell host (e.g., Windows PowerShell vs. PowerShell 7).
	2.	All Users, Current Host Profile
	•	Typically located at:
C:\Program Files\PowerShell\7\Microsoft.PowerShell_profile.ps1 (for PowerShell 7) or
C:\Windows\System32\WindowsPowerShell\v1.0\Microsoft.PowerShell_profile.ps1 (for Windows PowerShell 5.1).
	•	This profile would affect all users on the machine.

Recommendation: If you’re not managing a shared system, the simplest approach is to use the Current User, Current Host profile. That way, you won’t risk altering settings for other users on your machine.

3. Checking If You Already Have a Profile

You can see the path to your current user profile by typing:

$PROFILE

	•	If the file does not exist, PowerShell won’t find it automatically. You can create it with a text editor like Notepad.
	•	If it does exist, you’ll see the path. You can open it in a text editor to view or edit its contents.

4. Creating (or Editing) Your Profile File

Use the following steps to create or edit your PowerShell profile safely.

Step-by-Step Instructions (with Visual Aids)
	1.	Open PowerShell
Make sure you open the version of PowerShell you want to customize (e.g., Windows PowerShell or PowerShell 7).

Visual Aid:

+--------------------------------------+
| Start Menu (Windows)                |
|   -> Search "PowerShell"            |
|   -> Choose "Windows PowerShell"    |
|       or "PowerShell 7"            |
+--------------------------------------+


	2.	Check if a Profile Exists
In the console, type:

Test-Path $PROFILE

	•	If it returns True, a profile file already exists.
	•	If it returns False, the file doesn’t exist yet.

Visual Aid:

PS C:\Users\YourUserName> Test-Path $PROFILE
False

(Example showing it doesn’t exist)

	3.	Create or Open the Profile File in Notepad

notepad $PROFILE

	•	If the file doesn’t exist, you’ll see a prompt asking if you want to create a new file. Choose Yes.
	•	If the file does exist, Notepad will open the file’s current contents.

Visual Aid:

+------------------------------------------+
| Notepad Prompt:                         |
| "Cannot find the Microsoft.PowerShell_  |
| profile.ps1 file. Do you want to create |
| a new file?"                            |
|  [Yes]   [No]    [Cancel]               |
+------------------------------------------+


	4.	Add Your Desired Configuration
For example, if you want to create your custom vyvanse function or any other aliases/functions, paste them into this file. Here’s an example snippet:

function vyvanse {
    param (
        [Parameter(Mandatory=$false)]
        [ValidateSet("Regular", "Admin")]
        [string]$ConnectionType = "Regular",  # Default to Regular connection

        [Parameter(Mandatory=$false)]
        [string]$Url = ""
    )

    switch ($ConnectionType) {
        "Admin" {
            if (-not $Url) {
                $Url = "https://yourtenant-admin.sharepoint.com"
            }
            break
        }
        "Regular" {
            if (-not $Url) {
                $Url = "https://yourtenant.sharepoint.com/sites/YourSite"
            }
            break
        }
    }

    try {
        Write-Host "Connecting to PnP PowerShell ($ConnectionType)..." -ForegroundColor Cyan
        Connect-PnPOnline -Url $Url -Interactive
        Write-Host "Successfully connected to $ConnectionType SharePoint at $Url." -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to connect to PnP PowerShell. $_"
    }
}

Tip: Replace placeholders like yourtenant and YourSite with your actual tenant and site names.

	5.	Save Your Profile
	•	In Notepad, go to File > Save (or press Ctrl + S).
	•	Close Notepad once you’re done.
	6.	Reload the Profile
To have changes take effect immediately in your current session, type:

. $PROFILE

This “dot sources” the profile, meaning it reads and executes all the commands in that .ps1 file in the current session.

Visual Aid:

PS C:\Users\YourUserName> . $PROFILE

(No errors = good to go)

	7.	Verify Your Changes
	•	You can now test by typing your new function name (e.g., vyvanse) in the console.
	•	If everything is set up correctly, it should run without error.

5. Confirming That SharePoint Isn’t Affected

Because your PowerShell profile is a local file on your machine:
	•	It does not alter anything in your SharePoint tenant by default.
	•	It merely contains configuration details that run before you connect to SharePoint.
	•	You only interact with SharePoint (or any other remote service) once you manually run commands that establish a connection (e.g., Connect-PnPOnline).

In other words, your tenant remains untouched until you actively run a command to interact with it.

6. Examples of a Complete Workflow

Here’s a quick visual of the process from start to finish:

PS C:\Users\YourUserName> Test-Path $PROFILE
False

PS C:\Users\YourUserName> notepad $PROFILE
 -- Notepad opens, you click "Yes" to create a new file --

(You paste your script into Notepad, then save)

PS C:\Users\YourUserName> . $PROFILE
 -- No news is good news; no error means the profile is loaded --

PS C:\Users\YourUserName> vyvanse -ConnectionType Admin
Connecting to PnP PowerShell (Admin)...
 -- A dialog appears for interactive login if you haven't logged in recently --
Successfully connected to Admin SharePoint at https://yourtenant-admin.sharepoint.com.

7. Troubleshooting Profile Issues
	1.	File Permissions: If you run into permission issues, ensure you have the rights to write to your Documents folder or the profile file location.
	2.	Profile Path Confusion: Remember there can be multiple profiles (for Windows PowerShell, for PowerShell 7, for the current user, for all users). Double-check you’re editing the correct one by looking at $PROFILE.
	3.	Execution Policy: If your PowerShell execution policy is set to Restricted, you may not be able to load scripts. You can temporarily bypass it by using:

Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

(Requires running PowerShell as an Administrator. Choose a policy appropriate for your security needs.)

8. Key Takeaways
	1.	Local-Only Impact: Your PowerShell profile is a local script that does not affect SharePoint or any remote service unless you specifically run commands to connect.
	2.	Easy to Create and Edit: You can create or edit it using a simple command:

notepad $PROFILE


	3.	Persistence Across Sessions: Anything in the profile will automatically load each time you start PowerShell, making your workflow more efficient.

You Are All Set!

By creating and customizing your PowerShell profile, you can streamline your work—especially logging into SharePoint or performing PnP operations—without worrying about breaking anything in your tenant. It’s a safe and standard practice for PowerShell users of all levels.

If you have any further questions or need more guidance on profiles, environment configuration, or PnP usage, don’t hesitate to let me know!