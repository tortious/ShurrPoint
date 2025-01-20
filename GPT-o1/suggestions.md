# SharePoint Legal Practice Configuration Guide
## 1. Content Types
Content types serve as the foundation of your SharePoint tenant. Here's how to organize and create them effectively:
Case Management Content Types

### Case File: Essential columns include:

**Case # (Managed Metadata)
Client Name
Opposing Counsel
Date Opened
**

Claim: Primary columns include:

Claim # (Managed Metadata)
Policyholder Name
Insurer Name
Incident Date


Pleading: Key columns for legal filings:

Filing Date
Court Name
Status


Discovery Document: Critical tracking fields:

Discovery Phase (Term Store)
Document Type (e.g., Interrogatories, Requests for Production)
Due Date



Administrative Content Types

Invoices: Financial tracking columns:

Invoice #
Date
Case # (lookup/Managed Metadata)
Payment Status


Notes: Documentation columns:

Associated Case (Lookup)
Author
Date Created



## Organization Strategy

Implement a Content Type Hub for centralized management, publishing content types to site collections as needed. Group content types into categories like "Case Management" and "Admin" for improved organization.

# 2. Term Store, Custom Columns & Managed Metadata
## Term Store Structure
### Case Management Terms

### Clients: Client names

#### Opposing Counsel: Organized by law firms and individual attorneys

#### Discovery Phases: Initial, Interrogatories, Depositions
Courts: List of relevant courts
Case Status: Active, Closed, On Hold

Administrative Terms

Invoice Status: Paid, Unpaid, Pending
Internal Categories: HR, Billing, Operations

Integration Strategy
Custom columns should draw from the Term Store for consistent tagging. Example: "Discovery Phase" column linked to "Discovery Phases" term set. Use Managed Metadata for key fields like Case # and Claim # to ensure consistent data entry and filtering.
Setup Example

Term Store: Define hierarchical terms (e.g., Clients > Corporate > Acme Inc.)
Custom Columns: Create "Case #" as Managed Metadata field pulling from "Case Numbers" term set

# 3. Document Sets

## Case File Document Set

#### Columns:

Case # (Managed Metadata)
Client Name (Lookup)
Opposing Counsel (Managed Metadata)

#### Folder Contents:

Standardized templates for pleadings
Discovery requests
Correspondence

### Pleadings Packet Document Set
Columns:

Case # (Lookup/Managed Metadata)
Filing Date

### Folder Contents:

#### Filing template
Subfolders for drafts and final submissions

### Discovery Packet Document Set
#### Columns:

Case #
Discovery Phase
Due Date

Folder Contents:

Evidence subfolders
Responses
Objections

# 4. Teams Site Creation Automation

## PnP PowerShell Implementation
```
powershellCopyConnect-PnPOnline -Url "https://yourtenant.sharepoint.com/sites/casemanagementhub"
$template = Read-PnPProvisioningTemplate -Path "TerryTemplate.xml"
New-PnPTenantSite -Title "New Case Site" -Url "https://yourtenant.sharepoint.com/sites/NewCase" -Owner "yourname@domain.com"
Apply-PnPProvisioningTemplate -Path "TerryTemplate.xml"
Power Automate Integration
```

### Trigger: SharePoint button click
Action: HTTP request for site creation and template application

# 5. Custom SPFx Projects

Case Overview Dashboard: Visual summary of case data using rollups
Document Generator: Automated standard pleadings/discovery packet generation
Quick Links for Adjusters: One-click access to case files and evidence

# 6. Power Automate Workflows

Case Lifecycle Automation
Trigger: New case entry
Actions:

## Teams site creation
Document library/set population

## Deadline Management
Trigger: Discovery Documents due date
Actions:

7-day advance reminder
1-day advance reminder

# 7. PowerApp Solutions

Case Tracker App: Mobile-friendly case management data review
Client Contact Directory: Searchable contact database

# 8. Best Practices
Backup Protocol

Regular Term Store exports
Content Type configuration backups

Compliance Management

Automated metadata completeness checks via Power Automate
Regular compliance reporting

This configuration creates a robust, efficient SharePoint environment optimized for legal practice management.
