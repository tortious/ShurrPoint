Below is a step-by-step guide that explains, in detail, how to register two different kinds of applications (PnP PowerShell and a Python REST API) with Azure Active Directory (now called Entra ID) and then use them to interact with your SharePoint tenant. I’ll break everything down in a way that a curious teenager can understand, while still being thorough enough for a technical setup. I’ll also include simple visual aids (ASCII diagrams) to help illustrate what’s going on.

1. Understanding the Big Picture

1.1 What is Azure Active Directory (Entra ID)?
	•	Azure Active Directory (Azure AD or Entra ID) is like a gatekeeper that keeps track of who is allowed to access which resources in Microsoft 365 (like SharePoint, Teams, etc.).
	•	When you “register an app,” you’re telling Azure AD: “Hey, here’s an application. I want it to be able to sign in and talk to Microsoft 365 services on my behalf (or on behalf of users).”

1.2 What is SharePoint Online?
	•	SharePoint Online is part of Microsoft 365. It’s a web-based platform for storing files, creating intranet sites, and collaborating. We’ll be connecting to it using our registered apps.

1.3 Why register apps at all?
	•	Security: We want to make sure only trusted applications can read or write data in our SharePoint environment.
	•	Permissions: We must decide exactly what each app can do: Can it read files? Upload files? Modify permissions?
	•	Authentication tokens: After registering an app, we’ll get special ID keys or secrets that the app uses to prove, “I’m allowed to do these actions.”

2. Registering the First App: PnP PowerShell

2.1 What is PnP PowerShell?
	•	PnP PowerShell is a collection of PowerShell commands (cmdlets) that make it easier to manage and automate tasks in SharePoint, Microsoft Teams, OneDrive, and so on.

2.2 Step-by-Step Registration
	1.	Log in to the Microsoft Entra admin center (previously Azure AD portal):
	•	Go to https://entra.microsoft.com or https://portal.azure.com (both ultimately lead you to manage Entra ID).
	•	Use an account that has permissions to create app registrations (usually a Global Admin or Privileged Role Admin).
	2.	Create a New App Registration:
	•	In the left navigation, find “Azure Active Directory” or “Entra ID.”
	•	Click “App registrations.”
	•	Click the “New registration” button at the top.
	3.	Fill in the App Details:
	•	Name: Enter something like "PnP-PowerShell-App".
(This is just a friendly name so you can recognize it.)
	•	Supported account types: Usually, you’ll pick “Accounts in this organizational directory only” if you only want it within your tenant.
	•	Redirect URI (optional for PnP PowerShell in many scenarios, so you can leave this blank or put in something like https://localhost if needed).
	4.	Click “Register.”
	•	Now you’ve created your app registration for PnP PowerShell.
	5.	Grab Your App (Client) ID and Tenant ID:
	•	After registering, you’ll see an Overview page with the Application (client) ID and the Directory (tenant) ID. Keep these in a safe place—you’ll need them to connect from PnP PowerShell.
	6.	Create a Client Secret:
	•	Under “Certificates & secrets” (in the left menu), click “New client secret.”
	•	Type a short description (e.g., “PnP PowerShell Secret”), choose an expiration.
	•	Click “Add.” A new secret value will appear—copy it right away.
(You won’t see this value again after you leave the page.)
	7.	Assign Permissions (API Permissions):
	•	Click “API permissions” on the left menu.
	•	Click “Add a permission.”
	•	Choose “Microsoft Graph” or “SharePoint” (for direct SharePoint API). Typically, you might choose:
	•	For reading and writing SharePoint sites via PnP:
	•	“Sites.Read.All” and “Sites.Manage.All” from Microsoft Graph.
Or
	•	“All Sites.FullControl” from the SharePoint section, depending on your usage.
	•	Grant admin consent if you want the app to run with those permissions without requiring each user’s consent.
	•	Click “Grant admin consent for [tenant name].”

Here’s a little ASCII diagram of what just happened:

     You (Admin) 
          |
          v
 +--------------------+
 | Entra ID (Azure AD)|
 | - App Registration |
 +--------+-----------+
          |
          v
     App is Created  
   +---------------+
   |  PnP App Info |
   |  Client ID    |
   |  Tenant ID    |
   |  Secret       |
   +---------------+

2.3 How to Use the Registered App with PnP PowerShell
	1.	Install PnP PowerShell (if you haven’t already):

Install-Module PnP.PowerShell

	•	You might need to say “Yes” or “A” to trust the repository.

	2.	Connect with the App Registration:
	•	You’ll need three pieces of information: Client ID, Client Secret, and Tenant (which is your Tenant ID or the actual tenant name, e.g., mytenant.onmicrosoft.com).

Connect-PnPOnline `
    -Url https://<YourTenantName>.sharepoint.com `
    -ClientId "<Your-Client-ID>" `
    -ClientSecret "<Your-Client-Secret>" `
    -Tenant "<Your-Tenant-ID or Tenant-Domain>"

	•	What’s happening? PnP PowerShell is using the Client ID and Secret to prove it’s your registered app. Azure AD checks the ID and Secret, sees your app is allowed to connect to SharePoint, and returns an authentication token.

	3.	Test a Command:
	•	For example, list the sites in your tenant:

Get-PnPTenantSite


	•	Effect: This command uses the permission you set up in Azure AD to read your SharePoint sites.

3. Registering the Second App: Python REST API

3.1 What is a Python REST API?
	•	A Python REST API (in this context) is just Python code that calls SharePoint’s web endpoints to read or write data. You can use libraries like requests or aiohttp (or the official Microsoft Graph Python library) to do so.

3.2 Step-by-Step Registration

The process is almost the same as with PnP PowerShell:
	1.	Go to the App Registrations page again in the Entra admin center.
	2.	Create a New Registration:
	•	Name: “MyPythonSharePointApp”
	•	Supported account types: Usually “Accounts in this organizational directory only.”
	•	For a Python REST API, you might specify a Redirect URI if you plan to use OAuth 2.0 interactive sign-ins. For now, if you’re doing a background service scenario, you can skip or use https://localhost.
	3.	Grab the App (Client) ID, Tenant ID, and create a Client Secret the same way as before.
	4.	Permissions:
	•	Go to API permissions.
	•	Add the permissions you need. For a typical REST scenario using Microsoft Graph to access SharePoint content:
	•	“Sites.Read.All,” “Sites.Manage.All,” “Files.ReadWrite.All,” etc. — depends on how deeply you want to interact with files and sites.
	•	Click “Grant admin consent” if appropriate.

     You (Admin) 
          |
          v
 +--------------------+
 | Entra ID (Azure AD)|
 | - App Registration |
 +--------+-----------+
          |
          v
   +------------------+
   | Python API App   |
   | Client ID        |
   | Tenant ID        |
   | Secret           |
   +------------------+

4. Using the Registered Python App to Call SharePoint

4.1 Install Required Python Packages

You can use plain requests or the official Microsoft libraries. For example:

pip install requests

(or)

pip install msal  # Microsoft Authentication Library for Python

4.2 Authenticating with Microsoft (Using MSAL)

Here’s a small sample script using the MSAL (Microsoft Authentication Library) Python package.

import requests
from msal import ConfidentialClientApplication

# These values come from your app registration:
client_id = "<Your-Client-ID>"
client_secret = "<Your-Client-Secret>"
tenant_id = "<Your-Tenant-ID>"

# Authority is your tenant + the Microsoft login URL
authority_url = f"https://login.microsoftonline.com/{tenant_id}"

# The resource scope you want to access:
# For SharePoint, often "https://<YourTenantName>.sharepoint.com/.default"
# Or "https://graph.microsoft.com/.default" if using Microsoft Graph
scope = ["https://graph.microsoft.com/.default"]  

app = ConfidentialClientApplication(
    client_id=client_id,
    client_credential=client_secret,
    authority=authority_url
)

# Acquire a token from Azure AD
result = app.acquire_token_for_client(scopes=scope)

if "access_token" in result:
    access_token = result["access_token"]
    print("Got token successfully!")
    
    # Example: Use Microsoft Graph endpoint to list SharePoint sites
    # Graph endpoint for listing sites:
    graph_url = "https://graph.microsoft.com/v1.0/sites?search=SharePoint"
    
    # Make the request with the token
    headers = {
        "Authorization": f"Bearer {access_token}"
    }
    response = requests.get(graph_url, headers=headers)
    
    if response.status_code == 200:
        sites_data = response.json()
        print("Sites found:", sites_data)
    else:
        print("Error:", response.status_code, response.text)
else:
    print("Error acquiring token:", result.get("error"), result.get("error_description"))

What’s happening in this script?
	1.	We import a library called msal which helps with Azure AD authentication flows.
	2.	We create a ConfidentialClientApplication with our client_id and client_secret. This identifies our app in Azure.
	3.	We request an access token for the scope of https://graph.microsoft.com/.default. This means: “Give me a token that allows me to do whatever permissions my app has for Microsoft Graph.”
	4.	If we succeed, Azure AD returns an access token.
	5.	We use that token in the Authorization header to call the Microsoft Graph endpoint for SharePoint sites.
	6.	If the token is valid and your app has the right permissions, we get a JSON listing of SharePoint sites!

4.3 Adjusting the Scope to Use SharePoint Directly
	•	If you want to use the classic SharePoint API endpoints directly (like https://<tenant>.sharepoint.com/_api/web/lists), you can set the scope to ["https://<tenant>.sharepoint.com/.default"].
	•	The rest is the same idea: get a token, attach it to your requests, and call your SharePoint REST URL.

5. Recap & Why Each Step Matters
	1.	App Registration: Tells Azure AD about your application.
	•	Effect: Azure AD knows your app exists and can give it permission to do things in the tenant.
	2.	Client IDs and Secrets: Unique keys for your app.
	•	Effect: Only those who know the secret can pretend to be the app.
	3.	API Permissions: Chooses what your app can do (read, write, manage, etc.).
	•	Effect: Limits or extends the power of your app to access SharePoint resources.
	4.	Grant Admin Consent: A global admin “approves” the requested permissions for the entire organization.
	•	Effect: You won’t need each user to individually grant permission—makes it simpler for background services or automation scripts.
	5.	Using Tokens: When your script or tool logs in, it exchanges the client ID/secret for an access token.
	•	Effect: The token is like a time-limited “hall pass” that says: “I’m allowed to access resource X.”

Here’s a final ASCII flow diagram showing how the Python or PnP PowerShell calls eventually reach SharePoint:

+----------------------------------+
|  (PnP PowerShell or Python App)  |
|  1. Provide App ID & Secret      |
+-------------------+--------------+
                    |
                    v
         +-----------------+
         | Entra ID (AAD)  |
         | 2. Validate ID  |
         | and Secret      |
         +--------+--------+
                  |
                  v
          +-----------------+
          | 3. Return       |
          | Access Token    |
          +--------+--------+
                  |
                  v
+----------------------------------+
|  (PnP or Python uses Access Token)|
+-------------------+--------------+
                    |
                    v
         +-----------------+
         | SharePoint      |
         | 4. Respond      |
         | to API calls    |
         +-----------------+

	•	Step 1: Your application (PnP PowerShell / Python script) has the client ID and secret.
	•	Step 2: Azure AD checks to see if they match the registered app.
	•	Step 3: Azure AD returns an access token if everything is valid.
	•	Step 4: You use the token to do stuff in SharePoint. SharePoint trusts the token because it’s from Azure AD.

6. Conclusion

By following these steps:
	1.	Register your apps in Entra ID (Azure AD).
	2.	Give them the right permissions to SharePoint.
	3.	Use the IDs and secrets to get access tokens.
	4.	Call SharePoint or Microsoft Graph with those tokens.

You now have a secure, consistent way to automate SharePoint tasks—whether through PnP PowerShell cmdlets or through Python REST API calls. Each step (registration, secret creation, permission assignment, token usage) is necessary to ensure security and correct access levels in your tenant.

Feel free to revisit this guide whenever you need a refresher. As you get more comfortable, you can explore advanced topics like certificate-based authentication instead of client secrets, or refining permissions so your apps only get the minimum needed. But for most scenarios, the steps above will help you reliably connect to SharePoint.

You Did It!

You’ve set up two different types of applications with Azure/Entra ID and learned how to connect them to SharePoint. Happy scripting and automating!