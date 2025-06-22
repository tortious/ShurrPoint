Comprehensive Guide to Building and Maintaining a SharePoint Active Sites List
This guide provides a step-by-step process for creating and maintaining a SharePoint list that automatically reflects "active sites" within a Case Management Hub (or any modern SharePoint Hub). Visual examples are described in detail to guide you in recreating similar screens in your environment.
Overview
1. Goal

Create a SharePoint list that displays active sites within your Hub.
Automatically add a new entry to the list whenever a new site is created or becomes active in the Hub.

2. Key Approach

Use a SharePoint Custom List to store site metadata (Name, URL, Created Date, etc.).
Use Power Automate to detect new site creation or run a scheduled flow to poll the environment and update the list.

3. Main Steps

Create the "Active Sites" list in your Hub or top-level site.
Decide how to detect new site creation:
Option A: Use a provisioning process (if you have a custom site provisioning flow).
Option B: Use a scheduled flow to query the tenant or Hub for new sites and update the list.


Build a Power Automate flow to automate list updates.
Configure security and finalize.

Part 1: Create the SharePoint List
1. Navigate to the Hub site where you want the list to live

Assume you have a modern SharePoint site acting as your "Case Management Hub."
From the site’s main page, click the Settings gear (top-right corner) and select Site Contents.

2. Add a new list

In Site Contents, click New and select List.
Name the list, e.g., "Active Case Sites".
(Optional) Add a description, e.g., "List of all active sites under the Case Management Hub."

3. Configure list columns

The default "Title" column can be renamed to "Site Name" or kept as "Title."
Add columns using Add Column:
Site URL (Hyperlink)
Creation Date (Date and Time)
Owner/Contact (Person, optional)
Status (Choice or Yes/No, to indicate Active/Inactive).



4. (Optional) Customize views

Go to All Items → Edit current view (or Create new view) to define displayed columns.
Make "Site Name" clickable by formatting the column or rely on the Site URL column.

Visual Example (Creating the Custom List)
Imagine a screenshot showing:

The Site Contents page with a prominent "+ New" button at the top-left.
A dropdown menu with "List" selected.
A "Create list" dialog with fields for Name and Description.

Part 2: Decide How to Detect New Sites
Option A: Integrate Into Your Site Provisioning Process
If your organization has a custom script or flow for creating SharePoint sites attached to the Hub:

After the site is created (e.g., via Create site or Add-SPOSite), add a step to create a new item in the "Active Case Sites" list.
This ensures real-time updates when a new site is created.

Option B: Use a Scheduled Power Automate Flow
If you lack a custom provisioning solution or want to query Hub sites periodically:

Create a flow that runs every X hours/days.
Query the SharePoint Admin Center or use the "List Sites" action in Power Automate (requires privileges).
Filter sites to those connected to your Hub (match the HubSiteId property).
Compare with items in the "Active Case Sites" list and add new sites as needed.

Part 3: Build a Power Automate Flow to Automate List Updates
This example uses the scheduled method (Option B). For custom provisioning, the logic is similar but triggered differently.
1. Go to Power Automate

From the Office 365 App Launcher, select Power Automate or visit flow.microsoft.com.

2. Create a new Flow

Select Create → Scheduled cloud flow.
Name the flow, e.g., "Check for New Hub Sites".
Set the schedule (e.g., every 1 day or 6 hours).

3. Add a step: 'List all sites in organization' (Admin privileges needed)

Search for "SharePoint" → List all site collections (or use Send an HTTP request to SharePoint).
This action returns all site collections in the tenant (or filter via Admin endpoints).

4. Filter the sites for your Hub

Add a Filter Array step or OData filter to include only sites with the HubSiteId matching your "Case Management Hub".
Example: @equals(item()?['HubSiteId'], '<YourHubSiteGuid>')


Optionally filter for "Active" sites based on the site status property.

5. Check if the site already exists in the SharePoint list

Use an Apply to each loop on the filtered array of sites.
Add a Get items action from the "Active Case Sites" list, filtering where Site URL equals the current site’s URL.
If 0 items are returned, the site is new and not in the list.

6. Create an item if it doesn’t exist

In a condition branch, if no item is found, add a Create item step:
Site Name: Use dynamic content from the site’s Title or Name property.
Site URL: Use the site’s URL.
Creation Date: Use the site’s Created date (if available) or the current time.
Status: Set to "Active" (or "Active in Hub").



7. (Optional) Update item if site is found but status changed

Add a branch to Update item in the list to reflect status changes (e.g., archived or closed sites).

8. Save and Test

Save the flow and run it manually or wait for the scheduled time.
Check the run history to confirm new sites are added to the "Active Case Sites" list.

Visual Example (Power Automate Designer)
Imagine a screenshot showing:

Trigger: Schedule – Recurrence, every 1 day.
Action: List all site collections (SharePoint).
Action: Filter array to narrow to the Hub’s ID.
Apply to each: Create item in SharePoint if not found.
Flow run history with a "Succeeded" status and step breakdown.

Part 4: Verify and Monitor
1. Check your "Active Case Sites" list

Navigate to Case Management Hub → Site Contents → Active Case Sites.
Confirm existing active sites appear as list items with correct details (Name, URL, etc.).

2. Create a new site to test

Create a new site connected to the Hub using your normal process.
Wait for the flow to run (or trigger manually) and verify the new entry appears.

3. Set up alerts if desired

Configure alerts or email notifications in Power Automate for new items.
Add a Send an email step when the Create item step runs to notify stakeholders.

Part 5: Security & Permissions Considerations
1. Flow Owner Permissions

The flow’s account must have SharePoint Admin privileges (or permission to list site collections).
Ensure write permissions to the "Active Case Sites" list.

2. List Permissions

Define who can view, add, or edit the "Active Case Sites" list (e.g., read for staff, add/edit for flow/site owners).

3. Hub Site Association

Ensure new sites are properly associated with the Hub, or the flow’s filter may miss them.

Part 6: Maintenance & Troubleshooting
1. Flow Fails

Check the run history in Power Automate for failure details (e.g., insufficient permissions, missing site properties).

2. Sites Not Appearing

Verify the HubSiteId is set on the site.
Check Filter Array conditions in the flow.
Ensure the list’s filter is correct if using an OData query.

3. Decommissioning Sites

Add logic to mark sites "Inactive" or remove them from the list when archived or deleted (via the flow or a separate flow).

Summary
By combining a SharePoint Custom List with Power Automate, you can maintain an up-to-date reference of active sites in a Case Management Hub. Use either a site creation process to log new sites or a scheduled flow to query and filter Hub sites. Follow the detailed steps and visual example descriptions to implement this in your tenant. Once configured, the "Active Case Sites" list will stay updated and accessible to stakeholders.
