Below is a **step-by-step guide** to implement each of the flows described in **Flow-Goals.md** citeturn0file2. The primary tool in mind here is **Power Automate** (formerly Microsoft Flow), though you can adapt certain steps if you use a different automation engine.

---
## 1. Email-Related Flows

### 1.1. Weekday 7:30 AM Email Summary of Mark’s Calendar

**Goal**: “Mark & I are emailed every weekday at 7:30 AM outlining what events Mark has on his calendar for that day.” citeturn0file2

**Implementation Steps**:
1. **Create a Scheduled Flow**  
   - In Power Automate, go to **Create** > **Scheduled cloud flow**.  
   - Name it something like **“Daily Calendar Summary”**, set the **Start time** to 7:30 AM, and set it to **Repeat every 1 day**.  
   - Under “Advanced options,” ensure it only runs **Monday through Friday** (you may need to add condition checks or schedule it daily and then check if it’s a weekday).
2. **Retrieve Mark’s Calendar Events**  
   - After the **Recurrence** trigger, add a new step: **“Get events (V4)”** (or whichever Outlook connector is appropriate) from Mark’s mailbox.  
   - Specify the date range: start = **today at 00:00**, end = **today at 23:59**. This ensures you only get events for the current day.
3. **Compose the Email Body**  
   - Add an **HTML or Markdown** table summarizing each event. For each event in the returned array:
     - Event Subject
     - Start & End time
     - Location (if applicable)
     - Attendees
4. **Send the Summary Email**  
   - Add a **Send an email (V2)** action.  
   - **To**: Mark’s email + your email.  
   - **Subject**: “Mark’s Daily Calendar – [@{formatDateTime(utcNow(), 'M/d/yyyy')}]”  
   - **Body**: Insert the dynamic content from the previous step, e.g., the table of events.
5. **Test & Adjust**  
   - Save and test the flow, ensuring the data is correct.  
   - Adjust formatting (HTML or plain text) as desired.

> **Pro Tip**: If you want more advanced personalization (e.g., only events with certain categories), you can add a **Condition** step to filter out events.

---

### 1.2. Automatically Sort & Notify Based on “Assignment” Keyword

**Goal**: “When an email comes into Mark’s inbox with the word ‘assignment’ in it, and it is not a forwarded or replied-to email, add it to the Case-Assignments folder, and notify Terry on Teams.” citeturn0file2

**Implementation Steps**:
1. **Create an Automated Cloud Flow**  
   - Trigger: **“When a new email arrives (V3)”**.  
   - **Mailbox**: Mark’s mailbox.  
   - **Folder**: Usually “Inbox.”
2. **Check Subject or Body for Keyword**  
   - In the trigger’s advanced options, set **“Only with Attachments?”** to *No* (unless you specifically want them).  
   - Next step: **Condition** → “If Subject or Body contains ‘assignment.’”
3. **Exclude Forwards/Replies**  
   - Add another condition within the same or subsequent branch:
     - Check the **Subject**: does **Subject** contain “FW:” or “RE:” (or the locale-specific equivalents)?  
     - Or, check the **In-Reply-To** or **Reference Id** fields if available in advanced properties.  
   - If it’s a forward or reply, do nothing (branch “No” path).
4. **Move or Copy Email to Case-Assignments Folder**  
   - Use the **“Move email (V2)”** or **“Copy email (V2)”** action.  
   - Target Folder: **Case-Assignments**.
5. **Notify Terry via Teams**  
   - Add the **Microsoft Teams** connector action **“Post a message in a chat or channel”**.  
   - Choose the relevant channel or a 1:1 chat with Terry.  
   - Include a summary: “An email with the subject ‘@{Subject}’ was moved to the Case-Assignments folder.”
6. **Test**  
   - Send a test email with the word “assignment” from a different account, confirm it moves, and confirm you get the Teams notification.

---

## 2. General Flows

### 2.1. Auto-Create New Site & Apply a PnP Site Template

**Goal**: “Implement action of creating new site and applying a pnp site template onto it.” citeturn0file2

**Implementation Steps**:
1. **Create an Instant Cloud Flow**  
   - Trigger: **“Manually trigger a flow”** (or from a **SharePoint list item** if you want an event to trigger new site creation).
2. **Create Site via HTTP Request**  
   - If you’re comfortable with **Azure AD** app registration or **HTTP** actions, you can call the **SharePoint Online REST API** directly to create a site. Alternatively, some connectors can do this with the **“Create site (Preview)”** action if available in your environment.  
   - The request typically goes to `/_api/SPSiteManager/create` endpoint with a JSON body specifying the site title, alias, template, etc.
3. **Apply PnP Site Template**  
   - After site creation, add an action from the **PnP Online** or **PnP PowerShell** connector (if you’re using custom connectors), or do an **HTTP** call to apply your `.pnp` file or **XML** template.  
   - Example: **Invoke-PnPSiteTemplate** in PowerShell. 
     - If using Power Automate, you might store the PnP template in a library, then reference it from the flow’s script or from an Azure Automation runbook.
4. **Verify Completion**  
   - Query the site or check status from the PnP logs to ensure the template was applied successfully. 
5. **(Optional) Notify**  
   - Send an email or Teams message: “New site created with PnP template successfully.”

---

### 2.2. Notify of New Site in Case Mgmt Hub → Add New Item to “JEFF” List

**Goal**: “Ensure that if a new site is created in case mgmt hub, then a notification should go out to me to add a new item to JEFF list.” citeturn0file2

**Implementation Steps**:
1. **Detect New Site Creation**  
   - If you own the “Case Mgmt Hub,” you can create a **tenant-level** or **admin** flow that polls for newly created sites in a specific hub.  
   - Alternatively, if you have a known location or naming pattern for new sites (e.g., “/sites/Case###”), you can periodically call `_api/search/query` or “_api/web/webs” to check for new subwebs or site collections.
2. **Condition**  
   - Once a new site is detected, confirm it’s part of the “Case Mgmt Hub.” (e.g., check the hub association property).
3. **Add an Item to JEFF List**  
   - Use the **SharePoint** action: **“Create item”**.  
   - Site Address: Where your “JEFF” list lives.  
   - List Name: “JEFF.”  
   - **Title**: “New site created in Case Mgmt Hub.”  
   - Additional columns (e.g., Site URL, Creation Date, etc.).
4. **Notify You**  
   - Add a step: **“Send an email”** or “Post message to Teams.”  
   - Include the new site’s details and confirm the item was added to the JEFF list.

> **Alternatively**: If you want user interaction (like a button click to create the site), combine it with the above site-creation flow so that it automatically logs to JEFF once done.

---

### 2.3. Sync Mark’s Outlook Calendar with a SharePoint Calendar List

**Goal**: “Ensure that Mark’s outlook calendar is syncing with the calendar list.” citeturn0file2

**Implementation Steps**:
1. **Choose a Trigger**  
   - If you want near real-time sync, use **“When an event is added, updated or deleted (V3)”** in Outlook.  
   - If you’re okay with periodic sync, schedule a flow to run every 15 or 30 minutes to fetch the Outlook events.
2. **Get the Events**  
   - Outlook connector: **Get the event** or **List events** from Mark’s calendar.  
   - Possibly filter only “future events” or “modified since last run.”
3. **Create or Update Items in SharePoint Calendar List**  
   - For each event, check if an item with the same **Event ID** (you can store the Outlook Event ID in a custom column) already exists in the SharePoint list.  
   - If yes → **Update** item with any changes (subject, start time, etc.).  
   - If no → **Create** a new item.  
   - If an event is deleted → **Delete** from the SharePoint list or mark it canceled.
4. **Handle Recurring Events** (Optional)  
   - This can be tricky. You may want to handle only single-instance events or carefully parse recurrence rules.
5. **Test & Monitor**  
   - Check that newly created or changed events in Outlook appear in the SharePoint list, and vice versa (if you want two-way sync, you’d need additional steps in reverse).

---

## 3. Maintenance Flows

### 3.1. Weekly Site Overviews & Reports

**Goal**: “Create reports every week with an overview of each site, what sites have been created/deleted, as well as other general/useful info.” citeturn0file2

**Implementation Steps**:
1. **Schedule a Flow**  
   - Trigger: **Recurrence** every 1 week (e.g., Monday at 8 AM).
2. **Gather Site Data**  
   - Use the **SharePoint** or **Office 365 Admin** connectors, or **HTTP** calls to `_api/search/query` with a template like `contentclass=STS_Site` or `STS_Web`.  
   - Store the results in an array or variable. 
   - Also consider using **SharePoint Admin** center (via **HTTP** requests with app permissions) to see site creation/deletion logs or the **Microsoft 365 Audit Log** (requires higher permissions).
3. **Generate a Report**  
   - Use **HTML** or **Markdown** for a clear summary:
     - Site Title  
     - URL  
     - Creation Date  
     - Last Modified  
     - Possibly # of items, # of documents, etc.  
   - You could store these details in a SharePoint list or build them dynamically in the flow.
4. **Send the Summary**  
   - **Send an email** to relevant stakeholders or yourself.  
   - Or **Post a message to Teams** with the summary.
5. **(Optional) Archive**  
   - Save a copy of this weekly report in a **SharePoint Document Library** if you want a historical record.

---

## 4. Administrative Flow

### 4.1. Auto-Email Creation on eFilings Document Library Upload

**Goal**: “Once an item is added to the eFilings document library, an email prompt is automatically created with said item as an attachment. The email is addressed to invoices@firstchicagoinsurance.com and the subject says ‘Reimbursement Request re [item’s name].’” citeturn0file2

**Implementation Steps**:
1. **Trigger on New File**  
   - In Power Automate, create an **Automated flow**.  
   - Trigger: **“When a file is created (properties only)”** on the eFilings document library.
2. **Get File Content**  
   - Immediately follow with **“Get file content”** to retrieve the binary file from the library.
3. **Send Email with Attachment**  
   - Action: **“Send an email (V2)”**.  
   - **To**: invoices@firstchicagoinsurance.com.  
   - **Subject**: “Reimbursement Request re @{triggerOutputs()?['body/{FilenameWithExtension}']}.“  
   - **Attachments Name**: use the dynamic `FilenameWithExtension`; **Attachments Content**: the output of “Get file content.”
4. **(Optional) Include Additional Info**  
   - If the eFilings library has metadata (like “Case #,” “Amount,” “Invoice #”), you can add those to the subject or email body for clarity.
5. **Confirm & Test**  
   - Upload a test file, confirm you receive the email with the correct subject and attached file.

---

## Additional Tips & Best Practices

1. **Error Handling**  
   - Use **Try-Catch** patterns in Power Automate with **Parallel Branch** or **Scope + Configure run after** to handle errors gracefully.
2. **Logging**  
   - Log important Flow runs to a **SharePoint list** or **Azure Application Insights** if you need advanced tracking.
3. **Security & Permissions**  
   - When creating sites or sending emails on behalf of users, ensure the Flow’s **connection** uses the correct account with the needed privileges. 
4. **Performance**  
   - Watch out for large volumes of items or events. If you expect large data sets, consider **batching** or storing progress in a variable.

---

## Closing

By implementing these flows step by step, you’ll achieve the **automation goals** laid out in **Flow-Goals.md** citeturn0file2:

- **Daily email reminders** of Mark’s schedule.
- **Automatically filtering “assignment” emails** and notifying the right people.
- **Creating new sites** with PnP templates and linking them to the **JEFF** list.
- **Syncing Mark’s Outlook Calendar** to SharePoint.
- Generating **weekly site-overview reports**.
- **Automating eFiling email requests** with attachments.

If you run into issues or need additional help integrating these with your **SPFx** or **PnP** solutions, feel free to let me know. I’m here to help you tackle any **serious** automation or configuration hurdles you might face!
