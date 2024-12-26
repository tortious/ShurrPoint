# Term Store Structure

## 1. Case Management Group
### CaseType Terms
- Personal Injury
  - Auto Accident
  - Slip and Fall
  - Medical Malpractice
  - Workplace Injury
- Insurance Claims
  - Property Damage
  - Liability
  - Coverage Disputes
- Civil Litigation
  - Contract Disputes
  - Commercial Litigation
  - Employment Law

### Jurisdiction Terms
- State Courts
  - Illinois
    - Cook County
    - DuPage County
    - Lake County
  - Federal Courts
    - Northern District of Illinois
    - Central District of Illinois
  - Administrative Courts

### Document Categories
- Pleadings
  - Complaints
  - Answers
  - Motions
  - Orders
- Discovery
  - Interrogatories
  - Requests for Production
  - Depositions
- Correspondence
  - Client Communications
  - Opposing Counsel
  - Court Filings
  - Insurance Communications

### Case Status
- Active
- Pending
- Closed
- Appeal
- Settlement
- Pre-litigation

## 2. Administrative Group
### Document Types
- Internal Forms
- Templates
- Policies
- Training Materials

### Department Tags
- Legal
- Administrative
- IT
- Finance

# Content Types

## 1. Base Content Types

### Case Document (Parent)
- ID: 0x0100...
- Columns:
  - CaseNumber (Managed Metadata)
  - CaseName (Managed Metadata)
  - ClaimNumber (Managed Metadata)
  - DateFiled (Date)
  - Status (Choice)
  - LastModified (Date)
  - ModifiedBy (Person)

### Legal Document (Inherits from Case Document)
- Additional Columns:
  - CourtInfo (Text)
  - JurisdictionInfo (Managed Metadata)
  - FilingDeadline (Date)
  - OpposingCounsel (Lookup)

### Client Document (Inherits from Case Document)
- Additional Columns:
  - ClientName (Lookup)
  - ConfidentialityLevel (Choice)
  - RetentionPeriod (Choice)

## 2. Specialized Content Types

### Pleading (Inherits from Legal Document)
- Additional Columns:
  - PleadingType (Choice)
  - eFiled (Yes/No)
  - eFileDate (Date)
  - ServiceDate (Date)

### Discovery Document (Inherits from Legal Document)
- Additional Columns:
  - DiscoveryType (Choice)
  - ResponseDueDate (Date)
  - ProducingParty (Text)
  - ReceivingParty (Text)

### Correspondence (Inherits from Case Document)
- Additional Columns:
  - Sender (Text)
  - Recipient (Text)
  - CommunicationType (Choice)
  - Priority (Choice)
  - RequiresResponse (Yes/No)

### Evidence (Inherits from Case Document)
- Additional Columns:
  - EvidenceType (Choice)
  - Source (Text)
  - DateCollected (Date)
  - Chain of Custody (Multi-line Text)

# Managed Metadata Field Usage

## Lists

### CLARK List
- CaseName (Managed Metadata - Case Management:CaseNames)
- CaseNumber (Managed Metadata - Case Management:CaseNumbers)
- ClaimNumber (Managed Metadata - Case Management:ClaimNumbers)
- CaseType (Managed Metadata - Case Management:CaseType)
- Jurisdiction (Managed Metadata - Case Management:Jurisdiction)

### Casefiles Library
- All Case Document content type fields
- DocumentCategory (Managed Metadata - Case Management:Document Categories)
- CaseStatus (Managed Metadata - Case Management:Case Status)

### Correspondence Library
- All Correspondence content type fields
- DocumentType (Managed Metadata - Case Management:Document Categories)
- CommunicationType (Managed Metadata - Administrative:Document Types)

# Implementation Notes

1. Term Set Reusability
- CaseType, Jurisdiction, and Status terms should be reusable
- Document Categories should be closed for tight control
- Administrative terms should be open for growth

2. Content Type Hub
- Deploy all content types through the Content Type Hub
- Enable content type publishing
- Set up site columns before content types

3. Metadata Navigation
- Enable metadata navigation for Case Number and Case Name
- Set up refiners for Document Category and Case Status
- Configure friendly URLs using managed metadata

4. Search Schema
- Map managed metadata to RefinableString properties
- Create managed property for full-text search of case content
- Set up crawled properties for key metadata fields
