In the context of my sharepoint tenant, mordinilaw.sharepoint.com, Provide me a thorough and exhaustive guide, complete with a table of contents, as well as visual aids and examples, on how to do the following:

I) Create a custom GPT that will act as a SharePoint Administrator 
	(i) background: ensure the following options are always enabled:
	- Document Sets
	- Content Approval
	- Custom Content Types
	- Specific Site Columns
Custom Scripts
1)  It will be able to create custom sharepoint site templates for sharepoint online. Specially, withint the context of my case management hub (hub site its /sites/Cases)
	- It will be able to create templates for pnp templates
	- it will be able to create templates 
	- Generate production-ready PnP PowerShell scripts with error handling.
	- Include prerequisite checks and cleanup operations.
	- Enforce TLS 1.2 compliance and modern authentication.
	- Utilize sample scripts and information from PnP GitHub repository.
	
	1A)	SharePoint Online expertise
		- Site provisioning and template management.
		- PnP PowerShell cmdlets and patterns.
		- SharePoint Online architecture, permissions, and security configurations.
		- Content types and list management.
		- Integration with Microsoft 365 Groups.
	
	1B) Standard Site Templates:
		- Legal Case Sites (Teams-connected with group) include the following document libraries (CasePleadings, CaseMedia, AssignmentDocuments, Correspondence, Discovery) from within Mordini Law SharePoint Tenant.
		- Client Portals (Communication sites)
		- Department Sites (Hub sites)
		- Project Sites (Teams-connected)
2 Power Automate (FLow) Expertise
	- Configure SharePoint triggers and actions.
	- Handle complex flow logic and expressions.
	- Work with HTTP connectors using SharePoint REST API.
	- Integrate PnP PowerShell with Power Automate.
	- Develop document approval and review workflows.
	- Handle list item processing and batch operations.

	2A) Flow Development Guidelines:
		- Check connection references.
		- Implement proper error handling and notifications.
		- Use environment variables for configurability.
		- Implement concurrent execution handling.
		- Document flow dependencies and follow naming conventions.
		- Include timeout handling and consider delegation limits.
		
	2B) Common Flow Integration Patterns:
		- Site provisioning notifications.
		- Document approval processes.
		- List item status updates.
		- Metadata synchronization.
		- Teams channel notifications.
		- Conditional site access.
		- Data loss prevention alerts.
		- Audit log monitoring.	
