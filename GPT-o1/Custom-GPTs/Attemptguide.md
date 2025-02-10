Below is a **step-by-step explanation** of how to set up and use **Custom GPT** instructions so that your AI assistant consistently behaves as a **SharePoint Administrator**—enabling the correct features (Document Sets, Content Approval, etc.), generating scripts for PnP PowerShell, and integrating with Power Automate. We’ll discuss:

1. **What goes into “Custom Instructions”** (also known as the “system prompt” or “role” in some frameworks).  
2. **How to frame the “user question”** to get high-quality answers.  
3. **What “actions availability” or “plugins/tools”** mean and how to use them (if applicable).  
4. **How to practically use** the GPT once configured.  

> **Note**: The terminology differs slightly depending on whether you use ChatGPT’s “Custom instructions” feature, Azure OpenAI’s “System Prompt,” or another tool. The principles remain the same.

---

## 1. Understanding the GPT Conversation Structure

In most GPT-powered interfaces, you have **multiple “layers”** of instructions that together shape how the AI responds:

1. **System Instructions (Custom Instructions / Role Message)**  
   - This is where you define the AI’s overall role and style.  
   - Example: “You are a SharePoint Administrator for `mordinilaw.sharepoint.com`. You always enable Document Sets, Content Approval, and custom content types. You generate PnP PowerShell scripts with error handling and use modern authentication.”  

2. **User Prompt (User Questions)**  
   - This is **what the end-user actually types** when they want help or want a script.  
   - Example: “Generate a PowerShell script that creates a new Legal Case site with the following libraries: CasePleadings, CaseMedia, AssignmentDocuments, Correspondence, Discovery.”  

3. **Actions or Tools** (Optional)  
   - If your environment or platform supports **“Plugins,” “Function Calling,” or “Actions,”** you can define external commands GPT can “call.” For example, a function that actually **executes** the PnP PowerShell script.  
   - If you’re only generating text or code, you might **not** need these.  
   - If you do want GPT to automatically run tasks, you must carefully define these “actions” with relevant parameters and have a mechanism to safely **approve or disapprove** the GPT’s suggestions.

---

## 2. What Goes into the Custom Instructions (System Prompt)

Think of the **custom instructions** (or “system prompt”) as the *“Guiding Constitution”* for your GPT. It dictates how the AI should:

- **Talk**: e.g., formal vs. informal tone.  
- **Behave**: e.g., always produce code with TLS 1.2 enforced, always ensure Document Sets are enabled.  
- **Format** its answers: e.g., code blocks, bullet points, disclaimers, etc.

### 2.1 Example Custom Instructions

Below is an **example** you can adapt. (If you’re using ChatGPT, you’d paste this into the “Custom instructions” under “How would you like ChatGPT to respond?” or “System Prompt.” If you’re using Azure OpenAI, you’d place this in the **system** message.)

```
You are a Custom GPT serving as the SharePoint Administrator for "mordinilaw.sharepoint.com". 
Your responsibilities include:
1. Ensuring Document Sets, Content Approval, Custom Content Types, and required Site Columns are always enabled or included in the solutions you provide.
2. Generating production-ready PnP PowerShell scripts that:
   - Enforce TLS 1.2 and Modern Authentication
   - Include error handling and cleanup
   - Use best practices from the PnP GitHub repository
3. Providing instructions for integrating with or configuring Power Automate (Flows) in SharePoint contexts, including:
   - Site provisioning flows
   - Document approval processes
   - Automated notifications or Teams channel integrations
4. Observing the following best practices:
   - Scripts must always check for existing resources or sites before creation
   - Use descriptive variable names
   - Provide short clarifications (in bullet points) for each major step
   - Do not execute or run the commands automatically; only provide instructions and code
   - When referencing tenant URLs, use "mordinilaw.sharepoint.com" or "mordinilaw-admin.sharepoint.com" as appropriate

If a user asks a question or requests a script, always:
- Return the answer as a combination of explanation and code examples in fenced code blocks 
- Ensure the code adheres to the above guidelines
- If an answer is beyond your scope, explain any limitations or assumptions.
```

**Key Points**:

- You explicitly mention **Document Sets** and **Content Approval**.  
- You specify that all scripts **must** use TLS 1.2.  
- You clarify the standard site libraries for your legal practice.  
- You require the AI to show the user how to integrate with Power Automate.

With these instructions in place, your GPT will *default* to those constraints.

---

## 3. What Goes into the “User Questions”?

The **user question** is the immediate prompt you or your colleagues type when you want the GPT to generate or explain something. For example:

- “I need a script that creates a new Teams-connected site for case #9999, with libraries (CasePleadings, CaseMedia, etc.). Please provide error handling.”  
- “Show me how to configure a Power Automate flow that sends a Teams notification whenever a new case site is created.”  

Because you’ve set robust **system instructions**, you don’t have to re-specify “enable Document Sets, use TLS 1.2” each time—GPT should automatically do it.

However, you can **reinforce** or **override** certain things in the user question, e.g.:

> “Generate the script, but this time do **not** enable content approval on the library named ‘Discovery.’”

The GPT will try to obey the **user prompt** plus the **system instructions** together, with system instructions having higher priority if there’s a direct conflict.

---

## 4. What about “Actions Availability” or “Plugins”?

### 4.1 Defining Actions or Tools

If you have a more advanced setup (like **ChatGPT Plugins** or **Azure OpenAI Function Calling**), you can define “actions” that the GPT can invoke. For instance:

- **CreatePnPSite**(siteName, url, owner, libraries, …)  
- **EnableFlow**(flowName, parameters…)

In your system prompt or your code, you’d:

1. Declare the **function** or **action** with input parameters.  
2. Instruct GPT that when it sees a user request requiring site creation, it can “call” that function with the relevant parameters.  
3. The application logic (outside GPT) will then *execute* the function.  
4. GPT can respond with a follow-up message explaining what was done.

**Example** in Azure OpenAI Function Calling style (simplified pseudo-code):

```json
{
  "name": "CreatePnPSite",
  "description": "Creates a new SharePoint Online site using PnP PowerShell",
  "parameters": {
    "type": "object",
    "properties": {
      "siteName": { "type": "string" },
      "owner": { "type": "string" },
      "libraries": { "type": "array", "items": { "type": "string" } }
    },
    "required": ["siteName", "owner"]
  }
}
```

> GPT might respond with a function call:  
> ```json
> { 
>   "name": "CreatePnPSite",
>   "arguments": {
>       "siteName": "Case 123",
>       "owner": "[email protected]",
>       "libraries": ["CasePleadings", "CaseMedia", ...]
>   }
> }
> ```

Then your code outside GPT actually does the provisioning using PnP PowerShell. This approach is **powerful** but requires custom development to handle the function calls securely.

### 4.2 Using Actions Safely

- Always have a **human-in-the-loop** or a **review step** before any destructive action (e.g., removing a site).  
- Store credentials or tokens securely in environment variables or Key Vault, never directly in prompts.

---

## 5. How to Use Your Custom GPT, Step by Step

Let’s walk through a simple scenario:

1. **Set or Update the Custom Instructions / System Prompt**  
   - In ChatGPT: Go to Settings → “Custom instructions” and paste your big prompt.  
   - In Azure OpenAI: Create your system message or your fine-tuned model with these instructions.  

2. **Open a New Chat** with GPT  
   - The GPT now “knows” it’s your SharePoint Admin.

3. **Ask a Question** (User Prompt)  
   - Example:  
     ```
     I need a production-ready PnP PowerShell script to create a new Teams-connected site 
     for case #2023-100, with the libraries: CasePleadings, CaseMedia, AssignmentDocuments. 
     Include error handling and confirm Document Sets are enabled.
     ```

4. **GPT Responds**  
   - It will generate a script similar to:
     ```powershell
     # Setting TLS 1.2
     [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

     try {
         # Connect to SharePoint tenant admin
         Connect-PnPOnline -Url "https://mordinilaw-admin.sharepoint.com" -Interactive

         # ...
     ```
   - Because of your system instructions, it should **always** enable Document Sets, handle content approval, etc.

5. **Review and Validate the Script**  
   - Check if it meets your needs. If something’s missing, ask a follow-up question:
     > “Also enable content approval for the AssignmentDocuments library and set the version limit to 10 major versions.”

6. **(Optional) Execute or Automate**  
   - If you trust the script, you can copy/paste into a PowerShell session or incorporate it into a CI/CD pipeline.  
   - If you have a more advanced setup with function calling, the script or function might be invoked automatically—but always verify your security posture.

---

## 6. Detailed Example of Putting It All Together

### 6.1 Custom Instructions Text (System Prompt)

```
You are a Custom GPT that serves as the SharePoint Administrator for mordinilaw.sharepoint.com.
Always:
- Enforce Document Sets and Content Approval
- Use PnP PowerShell with TLS 1.2
- Provide sample code in fenced code blocks
- Include error handling and prerequisite checks
- Integrate with or reference Power Automate flows where helpful
- Provide short bullet-point explanations for each step
```

### 6.2 User Question (Example)

```
We just opened Case #77. Generate a PnP PowerShell script that creates a Teams-connected site, 
enables Document Sets, and sets up 5 major versions for each library. 
The site libraries should be: CasePleadings, CaseMedia, AssignmentDocuments, Correspondence, Discovery.
We want content approval enabled only on Correspondence.
```

### 6.3 GPT Reply (Condensed Example)

```
Sure! Here is your script:

```powershell
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

try {
    # Step 1: Connect to admin center
    Connect-PnPOnline -Url "https://mordinilaw-admin.sharepoint.com" -Interactive
    
    # Step 2: Create site
    New-PnPTenantSite -Title "Case #77" -Url "https://mordinilaw.sharepoint.com/sites/Case77" ...
    
    # Step 3: Wait for provisioning
    Start-Sleep -Seconds 30

    # Step 4: Connect to the new site
    Connect-PnPOnline -Url "https://mordinilaw.sharepoint.com/sites/Case77" -Interactive
    
    # Step 5: Enable Document Sets (Feature GUID or PnP command)
    Enable-PnPFeature -Identity "c9c9515d-e4e2-400a-905c-74f980f93160" -Scope Site
    
    # Step 6: Create libraries (CasePleadings, etc.) with version limit
    $libraries = @("CasePleadings","CaseMedia","AssignmentDocuments","Correspondence","Discovery")
    foreach ($lib in $libraries) {
        Add-PnPList -Title $lib -Template DocumentLibrary
        Set-PnPList -Identity $lib -EnableVersioning $true -MajorVersions 5
        
        # Enable content approval only for Correspondence
        if ($lib -eq "Correspondence") {
            Set-PnPList -Identity $lib -EnableModeration $true
        }
    }

    Write-Host "Case #77 site provisioned successfully."
} catch {
    Write-Host "ERROR: $($_.Exception.Message)"
} finally {
    Disconnect-PnPOnline
}
```
```

**Notice** how the script includes the specifics you requested.

---

## 7. Final Tips & Best Practices

1. **Iterate** Your System Prompt  
   - If GPT forgets to do something (like always enabling content approval), add or emphasize it in the system prompt.

2. **Use Examples**  
   - The more example scripts, flows, or instructions you provide during fine-tuning or retrieval-based prompts, the better GPT’s output will match your standards.

3. **Security**  
   - Avoid storing **secrets** or **credentials** in the system prompt. Use environment variables or secure vaults.  
   - If you enable GPT to run “actions,” ensure you have a **review step** before destructive changes.

4. **Documentation**  
   - Keep a knowledge base (SharePoint site or OneNote) that documents your standard site templates, Flow guidelines, etc. You can feed that knowledge back into GPT to improve its answers.

5. **Maintenance**  
   - SharePoint changes over time (PnP commands evolve). Update your custom instructions or training data accordingly.

---

# Conclusion

To **create and use** a Custom GPT for SharePoint Administration:

- **Put your governance and best practices** (Document Sets, Content Approval, PnP usage) in the **Custom Instructions** / system prompt.  
- **Ask** user-level questions that reference your specific scenario (new case site, new flow, etc.).  
- (Optional) Use **actions** or **function calls** if you want GPT to automatically orchestrate tasks.  
- **Validate and refine** the responses, updating your system prompt as needed.  

With this approach, your GPT will reliably produce **governance-compliant** scripts and instructions for your **mordinilaw.sharepoint.com** environment, saving you time and ensuring standardization across all site provisioning and Power Automate workflows.
