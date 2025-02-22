Below is a comprehensive, step-by-step guide to creating a “New Assignment Notification” flow using Microsoft Power Automate (formerly Microsoft Flow). The guide includes detailed reasoning behind each step and illustrative visuals (described in words). The example covers both triggers—(1) when a new item is added to the SharePoint “New Assignments” list, and (2) when a new email is received in a shared mailbox—so you can choose which one suits your process. 

---

## Overview of the Use Case

**Goal:**  
Notify relevant legal teams when a new case assignment arrives and automate downstream tasks.

**Key Triggers:**
1. **New item created** in a SharePoint list (e.g., “New Assignments” list).  
2. **New email** received in a shared mailbox (e.g., from a client).

**Actions:**  
1. Extract case details (e.g., case number, client name, jurisdiction, filing date).  
2. Send a Microsoft Teams notification to the assigned legal team with case details.  
3. Create a Planner task in the “Case Intake” plan.  
4. Send an email notification to the responsible attorneys.  
5. Log the assignment in a SharePoint list for tracking.  

---

## Prerequisites

1. **SharePoint site** and “New Assignments” list:  
   - Contains relevant fields like *Case Number*, *Client Name*, *Jurisdiction*, *Filing Date*, etc.
2. **Shared mailbox**:  
   - Access rights to configure the “When a new email arrives in a shared mailbox” trigger.
3. **Microsoft Teams**:  
   - A team or channel where you can post notifications (or the ability to send direct “chat” messages to individuals if desired).
4. **Microsoft Planner**:  
   - An existing “Case Intake” plan.
5. **Additional SharePoint list for tracking** (optional):  
   - Could be the same or a different list from the “New Assignments” list.  
6. **Power Automate license** and access to all connectors (SharePoint, Teams, Planner, Outlook).

---

## Flow Design Options

Because Power Automate currently **does not allow multiple triggers in a single flow** (an OR condition across triggers), you have two main options:

- **Option A:** Create **two separate flows**—one for the SharePoint trigger and one for the shared mailbox trigger. Both flows will then take the same subsequent actions.
- **Option B:** Create **one flow** with **one primary trigger** (e.g., new SharePoint item) and incorporate logic or “manual triggers” (e.g., a button) for email or use a scheduled flow that checks for new emails. (This is more complex and often less efficient.)

**Most organizations prefer Option A** for simplicity. Below we’ll demonstrate how to build **Flow A** (SharePoint trigger) in detail; then we’ll show how to replicate the same steps for **Flow B** (email trigger). The rest of the actions—Teams notification, Planner task, email, logging—are the same in both flows.

---

# Part 1: Creating the Flow for the SharePoint Trigger

### 1. Start with “When an item is created” Trigger

1. **Go to Power Automate** ([https://make.powerautomate.com/](https://make.powerautomate.com/)).
2. Click **Create** > **Automated cloud flow**.
3. In the “Build an automated cloud flow” dialog, search for **SharePoint** triggers and select **“When an item is created”**.  
4. Provide a descriptive Flow name, e.g., **“New Assignment - SharePoint Trigger”**.  
5. Click **Create**.

> **Reasoning:** This trigger starts the flow whenever a new item is added to the “New Assignments” SharePoint list, ensuring real-time capture of new case assignments.

**Visual Aid** (Textual Representation):
```
 ________________________________________
| FLOW NAME: New Assignment - SharePoint |
|----------------------------------------|
| Trigger: When an item is created       |
|  Site Address: [Your SharePoint Site]  |
|  List Name:   New Assignments          |
|________________________________________|
```

---

### 2. Initialize / Extract Case Details

After adding the trigger, you’ll see a section labeled **“When an item is created”** with dropdowns for your **Site Address** and **List Name**. Once you select your list, the dynamic content from the list will be available to you.

1. Select your **Site Address** and **List Name** from the dropdown.  
2. (Optional) If you want to store specific fields in variables for clarity or future manipulations, you can add **Initialize variable** actions. For example, store *Case Number* in a variable called `varCaseNumber`.

> **Reasoning:** Storing the SharePoint columns (Case Number, Client Name, etc.) in variables can make your flow more readable and easier to maintain. It’s optional if you plan to use them directly from dynamic content.

**Visual Aid** (Textual Representation):
```
+----------------------------------------+
| When an item is created                |
|                                        |
| Site Address:  [Your SharePoint Site]  |
| List Name:     New Assignments         |
+----------------------------------------+
      |
      v
+----------------------------------------+
| Initialize variable: varCaseNumber     |
| Value = [Case Number from dynamic content]
+----------------------------------------+
```

---

### 3. Send a Microsoft Teams Notification

Use Power Automate’s Teams connector to notify the legal team in a channel or to send a chat message directly.

1. Click **+ New step** and search for **Microsoft Teams**.  
2. Select **“Post a message (V3)”** in a channel (or “Post a message in a chat with flow bot” if you prefer direct messages).  
3. Configure the action:
   - **Team**: Choose the Team containing your channel.  
   - **Channel**: Choose the channel where you want to post the notification.  
   - **Message**: Construct a meaningful message with case details. You can insert dynamic content (like `Case Number`, `Client Name`, etc.) from the earlier step.

> **Reasoning:** A channel notification ensures immediate visibility to everyone on the legal team. Alternatively, direct chat ensures confidentiality if needed.

**Visual Aid** (Textual Representation):
```
+----------------------------------------+
| Post a message (V3) to Teams           |
| Team:  Legal Team                      |
| Channel:  New Case Notifications       |
| Message:                               |
|   "New case assigned!"                 |
|   "Case Number: @{varCaseNumber}"      |
|   "Client Name:  @{ClientName}"        |
|   ...                                  |
+----------------------------------------+
```

---

### 4. Create a Planner Task in the “Case Intake” Plan

Next, create a task in Microsoft Planner to track intake tasks and set reminders or due dates.

1. Click **+ New step**, search for **Planner**, select **“Create a task”**.  
2. Select the **Group Id** (the Microsoft 365 Group associated with the Planner).  
3. Select the **Plan Id**, in this case, the “Case Intake” plan.  
4. Provide a **Title** for the task (e.g., “Case Intake - [Case Number]”).  
5. (Optional) Set the **Due date** to the extracted *Filing Date*, if that is relevant to your workflow.  
6. (Optional) Assign the task to a specific user or group of users if known.

> **Reasoning:** Automatically generating a Planner task streamlines intake processes and ensures the assignment is visible in your standard task management system.

**Visual Aid** (Textual Representation):
```
+----------------------------------------+
| Create a task (Planner)               |
| Group Id:   Legal Team Group          |
| Plan Id:    Case Intake               |
| Title:      "Case Intake - @{varCaseNumber}"
| Due Date:   @{FilingDate} (optional)
| Assign To:  [Attorney/Group] (optional)
+----------------------------------------+
```

---

### 5. Send an Email Notification to Responsible Attorneys

1. Click **+ New step**, search for **Outlook** (or “Send an email (V2)”).  
2. Select **“Send an email (V2)”**.  
3. In **To** field, enter the distribution list or individuals representing the responsible attorneys.  
4. In **Subject** and **Body**, include the relevant case details from dynamic content.

> **Reasoning:** Email remains a staple for official notifications and record-keeping. This step ensures attorneys see the new assignment even if they’re not monitoring Teams or Planner.

**Visual Aid** (Textual Representation):
```
+----------------------------------------+
| Send an email (V2)                    |
| To: ResponsibleAttorneys@lawfirm.com   |
| Subject: "New Case Assigned: @{varCaseNumber}"
| Body:                                  |
|   "You have a new case assignment..."  |
|   "Case Number: @{varCaseNumber}"      |
|   "Client Name:  @{ClientName}"        |
|   ...                                  |
+----------------------------------------+
```

---

### 6. Log the Assignment in a SharePoint List

If you want to keep a second list (or the same list with additional columns) for tracking the progress of each new assignment, you can create an item in that list:

1. Click **+ New step**, select **SharePoint** connector, choose **“Create item”**.  
2. Select your **Site Address** and your **Tracking List** (could be a “Case Assignments Log”).  
3. Map fields (e.g., *Case Number*, *Date Assigned*, *Assigned To*, etc.) using the dynamic content.

> **Reasoning:** This step ensures there is a persistent record of all new assignments. Very helpful for dashboards, reporting, and auditing.

**Visual Aid** (Textual Representation):
```
+----------------------------------------+
| Create item (SharePoint)              |
| Site Address: [Your SharePoint Site]  |
| List Name:    Case Assignments Log    |
| Title:        @{varCaseNumber}        |
| Assigned To:  ResponsibleAttorneys    |
| Log Date:     @{utcNow()}             |
| ...                                    |
+----------------------------------------+
```

---

## Part 2: Creating the Flow for the Shared Mailbox Trigger

For **Flow B**, repeat the same steps from **Part 1**—the difference is solely in the trigger.

### 1. “When a new email arrives in a shared mailbox” Trigger

1. Go to **Power Automate** and create a **new Automated cloud flow**.  
2. In the trigger selection, pick **“When a new email arrives in a shared mailbox (V2)”**.  
3. Configure the **Mailbox Address** (the shared mailbox) and any filters (e.g., subject filters, importance, etc.) if needed.

> **Reasoning:** This ensures the flow runs whenever an email is dropped into that shared mailbox, typically from a client or another external source.  

### 2. Extract Case Details from the Email

- If the email body includes structured data (e.g., “Case number: 12345”), you can use **Power Automate expressions**, **HTML to text** conversions, or AI Builder models (if structured forms are used) to parse and store the relevant data in variables.  

> **Reasoning:** Parsing the email ensures you capture the details (case number, client name) automatically without manual intervention.

### 3. Repeat Steps 3 to 6 from Part 1

Once you have the case details, the subsequent actions—**Teams notification**, **Planner task**, **Email to attorneys**, and **logging in SharePoint**—are exactly the same. Just substitute the data you parsed from the email instead of data from the SharePoint list.

---

## Final Flow Diagram (Conceptual)

Below is a conceptual textual “diagram” showing the entire Flow A. Flow B is identical except for the first trigger step.

```
Flow: "New Assignment Notification" - SharePoint
┌─────────────────────────────────────────────────────────────────────────┐
│ STEP 1: When an item is created [SharePoint]                           │
│   - Site Address: ...                                                  │
│   - List Name: New Assignments                                         │
└─────────────────────────────────────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────────────────────┐
│ STEP 2: Extract/Initialize Variables                                   │
│   - varCaseNumber = [Case Number from dynamic content]                 │
│   - varClientName = [Client Name] ...                                  │
└─────────────────────────────────────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────────────────────┐
│ STEP 3: Post a message (V3) to Microsoft Teams                         │
│   - Team: Legal Team                                                   │
│   - Channel: New Case Notifications                                    │
│   - Message: "New case assigned! Number: ... Client: ..."              │
└─────────────────────────────────────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────────────────────┐
│ STEP 4: Create a task (Planner)                                        │
│   - Group Id:   Legal Team Group                                       │
│   - Plan Id:    Case Intake                                            │
│   - Title:      "Case Intake - varCaseNumber"                          │
│   - Due Date:   FilingDate (optional)                                  │
└─────────────────────────────────────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────────────────────┐
│ STEP 5: Send an email (V2) to responsible attorneys                    │
│   - Subject: "New Case Assignment: varCaseNumber"                      │
│   - Body: Provide details, e.g., Client Name, Filing Date, etc.        │
└─────────────────────────────────────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────────────────────┐
│ STEP 6: Create item [SharePoint] for logging                           │
│   - Site Address: ...                                                  │
│   - List Name: Case Assignments Log                                    │
│   - Fields: Case Number, Assigned To, etc.                             │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Tips and Best Practices

1. **Error Handling / Retry Policies**:  
   - Consider adding “Try/Catch” patterns (via Scope actions and parallel branches) or adjusting the built-in **retry policy** for robust reliability.

2. **Data Validation**:  
   - Use conditions to check if mandatory fields (Case Number, Client Name) are present. If not, the flow could send a notification about missing info.

3. **Dynamic Assignment of Planners / Teams**:  
   - If different legal teams handle different jurisdictions, you can add condition blocks or switch statements to direct the message to the correct channel or create tasks in different Planner plans.

4. **Security**:  
   - Ensure that only the correct persons have access to the SharePoint lists and shared mailbox.  
   - Be mindful of what data is posted in Teams channels if confidentiality is a concern.

5. **Testing**:  
   - Always test with a sample new SharePoint item or a sample email to ensure the flow is triggered and the data is parsed properly.

---

## Conclusion

By following the steps above, you’ll have one (or two) robust Power Automate flows that:

1. **Listens** for new case assignments (via SharePoint or shared mailbox).  
2. **Extracts** relevant case details (case number, client, etc.).  
3. **Notifies** the legal team in Teams, creates a structured **Planner task**.  
4. **Alerts** responsible attorneys via email.  
5. **Logs** the assignment in a SharePoint list for tracking purposes.

This automation saves time, ensures consistent notifications, and maintains a reliable audit trail of new case assignments. Once built, you can expand or refine the flow logic to suit specific organizational requirements, such as advanced routing, more sophisticated data parsing, or additional tracking fields.  

---

**You now have a complete, end-to-end guide** for building a “New Assignment Notification Flow” in Microsoft Power Automate. Feel free to adapt this template to align with your firm’s unique workflows and compliance rules. If you need further refinements—like adding conditions, using different connectors, or handling edge cases—simply build on the concepts you’ve learned here. Happy automating!
