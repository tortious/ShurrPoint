# SharePoint Case Management Foundation Setup Guide

## 1. Site Structure

### Site Hierarchy
```
Case Management
├── Home
├── Cases
│   ├── Active Cases
│   ├── Closed Cases
│   └── Case Archives
├── Knowledge Base
│   ├── Procedures
│   └── Templates
├── Reports
└── Admin
```

## 2. SharePoint Lists Configuration

### 2.1 Cases List
```
List Name: Cases
Template: Custom List
Version History: Enabled
Content Approval: Optional

Columns:
- Title (Single line of text) [Required]
- CaseID (Single line - Calculated) [Required]
  - Format: CASE-{yyyy}-{0000}
- Status (Choice) [Required]
  - New
  - In Progress
  - On Hold
  - Resolved
  - Closed
- Priority (Choice) [Required]
  - Critical
  - High
  - Medium
  - Low
- Category (Choice) [Required]
  - Technical
  - Billing
  - Service
  - General
- AssignedTo (Person or Group) [Required]
- RequestedBy (Person or Group) [Required]
- Description (Multiple lines of text) [Required]
- DateCreated (Date and Time) [System]
- DateModified (Date and Time) [System]
- DueDate (Date and Time)
- SLADueDate (Date and Time)
- Resolution (Multiple lines of text)
- ResolutionDate (Date and Time)
- RelatedCases (Lookup)
- Department (Choice)
- Tags (Enterprise Keywords)
```

### 2.2 Case Activities List
```
List Name: CaseActivities
Template: Custom List
Version History: Enabled

Columns:
- Title (Single line of text) [Required]
- CaseID (Lookup to Cases) [Required]
- ActivityType (Choice) [Required]
  - Note
  - Status Change
  - Assignment Change
  - Customer Contact
  - Internal Update
- ActivityDate (Date and Time) [Required]
- PerformedBy (Person or Group) [Required]
- Description (Multiple lines of text) [Required]
- TimeSpent (Number)
- NextAction (Multiple lines of text)
```

### 2.3 SLA Configuration List
```
List Name: SLAConfigurations
Template: Custom List

Columns:
- Title (Single line of text) [Required]
- Category (Choice) [Required]
- Priority (Choice) [Required]
- ResponseTime (Number) [Required]
- ResolutionTime (Number) [Required]
- EscalationTime (Number)
- NotificationTemplate (Multiple lines of text)
- Active (Yes/No)
```

## 3. Document Libraries Setup

### 3.1 Case Documents Library
```
Library Name: CaseDocuments
Version History: Enabled
Check Out Required: Yes

Content Types:
- Case Attachment
- Customer Communication
- Internal Document
- Resolution Document

Columns:
- DocumentType (Choice) [Required]
  - Email
  - Screenshot
  - Contract
  - Report
  - Other
- CaseID (Lookup to Cases) [Required]
- Confidential (Yes/No)
- ExpirationDate (Date and Time)
- Department (Choice)
- ReviewStatus (Choice)
```

### 3.2 Templates Library
```
Library Name: Templates
Version History: Enabled

Content Types:
- Email Template
- Report Template
- Form Template

Columns:
- TemplateType (Choice) [Required]
- Category (Choice)
- Language (Choice)
- LastReviewDate (Date and Time)
- NextReviewDate (Date and Time)
- Status (Choice)
  - Active
  - Draft
  - Archived
```

## 4. Site Navigation Configuration

### 4.1 Top Navigation
```json
{
  "navigation": [
    {
      "title": "Home",
      "url": "/sites/casemanagement/home",
      "icon": "Home"
    },
    {
      "title": "Cases",
      "url": "/sites/casemanagement/cases",
      "icon": "ClipboardList",
      "children": [
        {
          "title": "Active Cases",
          "url": "/sites/casemanagement/cases/active"
        },
        {
          "title": "Closed Cases",
          "url": "/sites/casemanagement/cases/closed"
        }
      ]
    },
    {
      "title": "Knowledge Base",
      "url": "/sites/casemanagement/kb",
      "icon": "Book"
    },
    {
      "title": "Reports",
      "url": "/sites/casemanagement/reports",
      "icon": "BarChart"
    }
  ]
}
```

## 5. Permission Levels

### 5.1 Custom Permission Levels
```
Case Manager
- View Items
- Add Items
- Edit Items
- Delete Items
- View Versions
- Create Alerts
- View Application Pages

Case Viewer
- View Items
- View Versions
- Create Alerts
- View Application Pages

Case Administrator
- Full Control
```

### 5.2 SharePoint Groups
```
Groups:
- Case Management Administrators
- Case Managers
- Case Viewers
- Department Leaders
- External Users
```

## 6. Views Configuration

### 6.1 Cases List Views
```
All Active Cases
- Filter: Status != "Closed"
- Sort: Priority DESC, Created DESC
- Columns:
  - CaseID
  - Title
  - Status
  - Priority
  - AssignedTo
  - DueDate
  - Category

My Cases
- Filter: AssignedTo = [Me]
- Sort: DueDate ASC
- Columns:
  - CaseID
  - Title
  - Status
  - Priority
  - DueDate
  - SLADueDate

Critical Cases
- Filter: Priority = "Critical"
- Sort: Created DESC
- Columns:
  - CaseID
  - Title
  - Status
  - AssignedTo
  - DueDate
  - Department
```

## 7. Implementation Steps

1. Site Collection Creation
   - Create new site collection using Communication Site template
   - Configure regional settings and language options
   - Enable required site features

2. Lists and Libraries Creation
   - Create all required lists with specified columns
   - Set up views and indexes for optimal performance
   - Configure versioning and content approval settings

3. Permission Setup
   - Create custom permission levels
   - Set up SharePoint groups
   - Configure inheritance breaking where needed
   - Implement item-level permissions

4. Navigation Configuration
   - Set up global navigation
   - Configure quick launch
   - Create hub site navigation if applicable

5. Content Types
   - Create site columns
   - Create content types
   - Associate content types with lists/libraries

6. Views and Forms
   - Create custom views
   - Customize forms using Power Apps if required
   - Set default views for different user groups

7. Site Settings
   - Configure site features
   - Set up search settings
   - Configure site sharing and sync settings

## 8. Post-Implementation Tasks

1. Validation Steps
   - Test all list forms and views
   - Verify permission assignments
   - Test document upload and metadata
   - Validate navigation links

2. Documentation
   - Update site documentation
   - Create user guides
   - Document custom configurations

3. Training
   - Prepare training materials
   - Schedule user training sessions
   - Create quick reference guides

4. Maintenance Plan
   - Schedule regular backups
   - Plan for content archival
   - Set up usage monitoring
   - Define cleanup procedures
