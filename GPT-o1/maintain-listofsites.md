Below is a comprehensive, step-by-step guide on how to build and maintain a SharePoint list that automatically reflects “active sites” within a Case Management Hub (or any Hub in modern SharePoint). Because an actual conversation cannot include direct image attachments, the “visual examples” here are described in detail as if they were screenshots. You can use these descriptions to guide you in recreating similar screens in your own environment.

Overview
	1.	Goal
	•	You want to have a SharePoint list that displays active sites within your Hub.
	•	Whenever a new site is created (or becomes active) inside this Hub, a new entry is added to the list automatically.
	2.	Key Approach
	•	Use a SharePoint Custom List to store site metadata (Name, URL, Created Date, etc.).
	•	Use Power Automate (formerly Microsoft Flow) to detect when new sites are created (or run on a schedule to poll the environment) and update your list.
	3.	Main Steps
	1.	Create the “Active Sites” list in your Hub or in a top-level site.
	2.	Decide how to detect new site creation:
	•	Option A: Use a provisioning process (if you have a custom site provisioning flow).
	•	Option B: Use a scheduled flow that queries the tenant or the Hub for new sites, then updates the list.
	3.	Build a Power Automate flow to automate the list updates.
	4.	Configure security and finalize.

Part 1: Create the SharePoint List
	1.	Navigate to the Hub site where you want the list to live
	•	Let’s assume you have a modern SharePoint site acting as your “Case Management Hub.”
	•	From your site’s main page, click the Settings gear (top-right corner) and choose Site Contents.
	2.	Add a new list
	•	In Site Contents, click New and select List.
	•	Give your list a descriptive name, e.g., “Active Case Sites”.
	•	(Optional) Provide a description like “List of all active sites under the Case Management Hub.”
	3.	Configure list columns
	•	By default, a new Custom List will have a “Title” column. You can rename that to “Site Name” or keep it as “Title.”
	•	Add other columns (using Add Column):
	•	Site URL (Hyperlink)
	•	Creation Date (Date and Time)
	•	Owner / Contact (Person) – (Optional)
	•	Status – to indicate if it’s Active or Inactive (Choice or Yes/No).
	4.	(Optional) Customize views
	•	Go to All Items → Edit current view (or Create new view) to define which columns appear.
	•	You might make the “Site Name” clickable by formatting that column or rely on the separate Site URL column.

Visual Example (Creating the Custom List)

Imagine a screenshot showing:
	1.	The Site Contents page with a big “+ New” button at top-left.
	2.	A dropdown where “List” is chosen.
	3.	A creation dialog titled “Create list” with fields for Name and Description.

Part 2: Decide How You’ll Detect New Sites

Option A: Integrate Into Your Site Provisioning Process

If your organization has a custom script or flow that automatically creates new SharePoint sites (especially if they’re all attached to this Hub site), you can insert a step in that provisioning flow:
	1.	After the site is successfully created (i.e., Create site or Add-SPOSite action completes), your flow can create a new item in the “Active Case Sites” list.
	2.	This ensures real-time updates whenever a new site is spun up.

Option B: Use a Scheduled Power Automate Flow

If you do not have a custom provisioning solution—or you simply want to query existing Hub sites on a fixed interval—you can create a scheduled flow that:
	1.	Runs every X hours/days.
	2.	Queries the SharePoint Admin Center or uses the standard “List Sites” action (in Power Automate) if you have privileges.
	3.	Filters the returned sites to find those connected to your Hub (often done by matching the HubSiteId property).
	4.	Compares them with items in the “Active Case Sites” list. If a site is not present, add a new item.

Part 3: Build a Power Automate Flow to Automate the List Updates

Below is an example approach using the scheduled method (Option B). If you have a custom provisioning approach, the logic is similar but triggered differently.
	1.	Go to Power Automate
	•	From Office 365 App Launcher, choose Power Automate or go to flow.microsoft.com.
	2.	Create a new Flow
	•	Select Create → Scheduled cloud flow.
	•	Give your flow a name, e.g., “Check for New Hub Sites”.
	•	Set the schedule (e.g., every 1 day, or every 6 hours, depending on how frequently you want to check).
	3.	Add a step: ‘List all sites in organization’ (Admin privileges needed)
	•	Under Choose an operation, search for “SharePoint” → “List all site collections” (or use “Send an HTTP request to SharePoint” if needed).
	•	This action returns all site collections in your tenant (or you can filter via the Admin endpoints).
	4.	Filter the sites for your Hub
	•	Insert a ‘Filter Array’ step (or an OData filter) so that only sites with the HubSiteId matching your “Case Management Hub” are passed forward.
	•	e.g., @equals(item()?['HubSiteId'], '<YourHubSiteGuid>')
	•	If you only want sites that are “Active,” also filter based on their Site status property if such a property is returned or known.
	5.	Check if the site already exists in the SharePoint list
	•	Use a ‘Apply to each’ loop on the filtered array of sites.
	•	Within the loop, add the action: ‘Get items’ from your “Active Case Sites” list, with a filter that checks if Site URL = this site’s URL.
	•	If it returns 0 items, that means it’s a new site not yet in the list.
	6.	Create an item if it doesn’t exist
	•	Inside a condition branch, if no item is found, add a “Create item” step:
	•	Site Name → dynamic content from the site’s Title or Name property.
	•	Site URL → site’s URL.
	•	Creation Date → site’s Created date (if the property is returned) or current time.
	•	Status → set to “Active” (or “Active in Hub”) as needed.
	7.	(Optional) Update item if site is found but status changed
	•	If you want to reflect status changes (e.g., site is archived or closed), you can add a branch to Update item in your list.
	8.	Save and Test
	•	Save the flow.
	•	Manually run or wait for the scheduled time.
	•	Inspect the run history to confirm that new sites are added to your “Active Case Sites” list.

Visual Example (Power Automate Designer)
	1.	A screenshot of the Flow editing page, showing:
	•	Trigger: “Schedule – Recurrence, every 1 day.”
	•	Action: “List all site collections” (SharePoint).
	•	Action: “Filter array” to narrow to the Hub’s ID.
	•	Apply to each: “Create item” in SharePoint if not found.
	2.	Possibly an image of the Flow run History with a “Succeeded” status and a breakdown of steps.

Part 4: Verify and Monitor
	1.	Check your “Active Case Sites” list
	•	Return to your Case Management Hub → Site Contents → “Active Case Sites.”
	•	Confirm that existing active sites appear as new list items.
	•	Each row should contain correct site information (Name, URL, etc.).
	2.	Create a new site to test
	•	Go through your normal process to spin up a new site that’s connected to the Hub.
	•	Wait for the flow to run (or run it manually), then confirm that the new entry appears.
	3.	Set up alerts if desired
	•	You can configure alerts or email notifications in Power Automate for when a new item is added to the list.
	•	For example, add a step to “Send an email” whenever the “Create item” step fires, notifying relevant stakeholders.

Part 5: Security & Permissions Considerations
	1.	Flow Owner Permissions
	•	The account running the flow must have SharePoint Admin or at least the ability to list all site collections if you’re using that approach.
	•	Ensure this account also has write permissions to the “Active Case Sites” list.
	2.	List Permissions
	•	Decide who can view, add, or edit the “Active Case Sites” list. Typically, staff in charge of case management need read permissions, while the Flow or site owners have add/edit permissions.
	3.	Hub Site Association
	•	Make sure your new site creation process associates new sites properly with the Hub. If not, your filter in the flow might not catch them.

Part 6: Maintenance & Troubleshooting
	1.	Flow Fails
	•	In Power Automate, check the run History for details on failures. Common issues include insufficient permissions or missing site property values.
	2.	Sites Not Appearing
	•	Confirm the HubSiteId is set on the site.
	•	Check the Filter Array conditions in the flow.
	•	Ensure the list’s filter is correct if you used an OData query.
	3.	Decommissioning Sites
	•	If sites should be removed from the list upon archival or deletion, add logic in the flow or a separate flow to mark them “Inactive” or remove them.

Summary

By combining a SharePoint Custom List with Power Automate, you can ensure your organization always has an up-to-date reference of active sites within a Case Management Hub. The core concept is to either inject a step into the site creation process that logs new sites in the list or to regularly query all sites in your environment, filter for those associated with the Hub, and add them if they’re missing.

Use the detailed, step-by-step flow instructions (with the corresponding “visual example” references) to recreate the exact process in your tenant. Once set up, your “Active Case Sites” list will be continually updated and ready for all stakeholders to reference.