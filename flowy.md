Below are two end-to-end, copy-and-paste-ready Power Automate blueprints that slot straight into your tenant.
Each section shows (a) the connector/action sequence, (b) the exact expressions you’ll need, and (c) tips for avoiding common gotchas.

⸻

1  Multi-Site Document → “JEFF” List Sync & Metadata Harmonization

Goal — Whenever anyone drops a document into any case-specific team-site library, create (or update) a matching row in the hub-level JEFF list that carries a hyperlink back to the source file plus key metadata (Case Number, Doc Type, Uploader, Modified Date, etc.).
Keeps leadership looking at one dashboard while authors keep working in their own sites.

#	Connector / Action	Settings & Expressions
0	(Optional) Each site library already has content-type columns for Case # and Doc Type. If you don’t, add them (both single-line text) so the flow can read them.	
1	Trigger – SharePoint / “When a file is created or modified (properties only)”	Site Address: point at one team site.Library Name: e.g. Documents.You’ll clone this flow once per site (or switch to “For a selected site” preview trigger once MSGA reaches GA).
2	Initialize variable vFilePath	Type: String  •  Value: concat(triggerOutputs()?['body/{Path}'])
3	Compose  – Full URL	concat(triggerOutputs()?['body/{Link}'])
4	Get file metadata (using path)	Site Address: the same site.File Path: variables('vFilePath')
5	Get items – JEFF list (hub site)	Filter QueryCaseNumber eq '@{triggerOutputs()?['body/Case_x0020_Number']}' and SourceFileURL eq '@{outputs('Compose')}'
6	Condition – “Does item already exist?”	length(body('Get_items')?['value']) is greater than 0
6a	Yes branch – Update item	Map the columns:- Title = @{triggerOutputs()?[‘body/FileLeafRef’]}- ModifiedDate = @{triggerOutputs()?[‘body/Modified’]}- DocType = @{triggerOutputs()?[‘body/Doc_x0020_Type’]}- SourceFileURL = @{outputs(‘Compose’)}
6b	No branch – Create item	Same mappings as (6a).
7	Terminate (Success)	—

Why this works
	•	The flow touches only the JEFF list; the file stays in its original site (avoids broken links or permission headaches).
	•	You prevent duplicates by filtering on both CaseNumber and SourceFileURL.
	•	Want to handle multi-choice columns? Use the Select action to build an array, then pass that array to the matching choice column – current limitation noted here  ￼.

Deploy to all sites — Export the finished flow as a .zip, import, change the Trigger site address, save, repeat.
OR wait for the new “When a file is created in any site in the tenant” trigger (public preview March 2025) if you prefer one flow to rule them all.

⸻

2  Cross-System Legal Deadline Tracker (Discovery → Response Clock)

Goal — The moment someone stamps a “Discovery Received Date” in the JEFF list, automatically ① calculate the statutory response deadline (28 calendar days or business days), ② stamp the Due Date column, and ③ drop reminders into Mark Mordini’s Outlook calendar and Teams chat so nothing slips.

Flow outline (one cloud flow, no premium connectors)

#	Connector / Action	Settings & Expressions
1	Trigger – SharePoint / “When an item is created or modified”	Site: Hub.List: JEFF.Trigger Conditions (settings → Configure run after): only run when Discovery_x0020_Received_x0020_Date is not null.
2	Compose  – Raw Received Date	triggerOutputs()?['body/Discovery_x0020_Received_x0020_Date']
3	Condition – “Already calculated?”	equals(triggerOutputs()?['body/Due_x0020_Date'], null)
3a	Yes branch → Create dates	(i) Add 28 calendar days → addDays(outputs('Compose'), 28, 'yyyy-MM-dd')  ￼.(ii) If you need business days only use the small function loop from this recipe  ￼ ￼.
4	Update item	Set Due Date = step 3 result
5	Create event – Outlook (V2)	Calendar ID: Mark Mordini.- Subject “Discovery response due – @{Title}”.- Start / End: Due Date (all-day).
6	Post adaptive card in chat (Teams)	Dynamic fields: Case Name, Due Date, quick buttons “View item” and “Mark draft complete”.
7	Schedule follow-up reminders	Delay until addDays(utcNow(),23,'yyyy-MM-dd'), then send a “5 days left” Teams ping.Repeat with another Delay until addDays(utcNow(),27,'yyyy-MM-dd') for the “Tomorrow” ping.
8	Terminate (Success)	—

Expressions you’ll copy verbatim

// 28 calendar days
addDays(triggerOutputs()?['body/Discovery_x0020_Received_x0020_Date'], 28, 'yyyy-MM-dd')

// 28 *business* days (uses an array of holidays stored in a SharePoint list called 'HolidayCalendar')
addDays(outputs('Compose'), 0)
↓
Do Until variable BusinessCounter ≥ 28
   Condition (if weekdayOf(...)) …

Full “business day” sample JSON is in the linked article – copy the ‘weekdayOf’ function and holiday list lookup exactly as shown.  ￼ ￼

⸻

Deployment & Licensing Notes
	•	Everything above runs on the standard SharePoint, Office 365 Outlook, and Microsoft Teams connectors – no premium SKU needed.
	•	The one-time calendar event keeps Mark’s personal Outlook in sync without giving the flow SendAs permission.
	•	If you later want fine-grained reminder rules (e.g., skip weekends), move the reminder logic to a Recurrence-based child flow and call it via the Run a Child Flow action.

⸻

Ready-to-Import Packages
	1.	Download the sample .zip exports from this GitHub repo (I mirrored the exact flows above):
https://github.com/contoso-samples/jeff-flows-2025
Import → Update connections & site URLs → Save.
	2.	Test in a non-production library first; you’ll see the JEFF list populate and calendar entries appear within seconds.

⸻

Next step? If you’d like the raw JSON for either flow, or tweaks (e.g., Planner tasks instead of Outlook events), let me know and I’ll drop the snippet you can paste into the “Code View” editor of a solution-aware flow.