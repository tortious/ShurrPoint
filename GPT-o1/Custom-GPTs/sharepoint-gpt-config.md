# SharePoint Assassin GPT Configuration Guide

## I. SPFx Development Examples

### A. Core Web Part Development

#### 1. Legal Document Viewer Web Part
```typescript
import * as React from 'react';
import { ILegalDocumentViewerProps } from './ILegalDocumentViewerProps';
import { MSGraphClientV3 } from '@microsoft/sp-http';
import { DocumentCard, DocumentCardPreview, DocumentCardTitle, DocumentCardActivity } from '@fluentui/react/lib/DocumentCard';

export default class LegalDocumentViewer extends React.Component<ILegalDocumentViewerProps, {}> {
  private _graphClient: MSGraphClientV3;

  public render(): React.ReactElement<ILegalDocumentViewerProps> {
    return (
      <div>
        <DocumentCard>
          {/* Document preview and metadata */}
        </DocumentCard>
      </div>
    );
  }

  protected async onInit(): Promise<void> {
    await super.onInit();
    // Graph client initialization
    this._graphClient = await this.context.msGraphClientFactory.getClient('3');
  }
}
```

#### 2. Case Management Property Pane
```typescript
export interface ICaseManagementWebPartProps {
  caseNumber: string;
  assignedAttorney: string;
  practiceArea: string;
}

protected getPropertyPaneConfiguration(): IPropertyPaneConfiguration {
  return {
    pages: [
      {
        header: {
          description: "Case Configuration"
        },
        groups: [
          {
            groupName: "Case Details",
            groupFields: [
              PropertyPaneTextField('caseNumber', {
                label: "Case Number",
                validation: {
                  required: true,
                  pattern: /^[A-Z]{2}-\d{6}$/,
                  errorMessage: "Format: XX-000000"
                }
              }),
              PropertyPaneDropdown('practiceArea', {
                label: "Practice Area",
                options: [
                  { key: 'civil', text: 'Civil Litigation' },
                  { key: 'corporate', text: 'Corporate Law' }
                ]
              })
            ]
          }
        ]
      }
    ]
  };
}
```

### B. Advanced SPFx Patterns

#### 1. Custom Field Renderer for Legal Citations
```typescript
export class LegalCitationFieldCustomizer
  extends BaseFieldCustomizer<ILegalCitationFieldCustomizerProps> {
  
  public onRenderCell(event: IFieldRenderEventParams): void {
    const citation: string = event.fieldValue;
    const citationFormat = this.parseCitation(citation);
    
    const element: React.ReactElement<{}> = React.createElement(
      LegalCitationRenderer,
      {
        citation: citationFormat,
        displayMode: this.displayMode,
        onCitationClick: this.handleCitationClick
      }
    );

    ReactDOM.render(element, event.domElement);
  }

  private parseCitation(citation: string): ICitationFormat {
    // Citation parsing logic
  }
}
```

## II. Power Automate Integration Examples

### A. Case Document Processing Flow
```json
{
  "definition": {
    "$schema": "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowDefinition.json#",
    "actions": {
      "When_a_new_document_is_created": {
        "type": "SharePointTrigger",
        "inputs": {
          "site": "https://mordinilaw.sharepoint.com/sites/casemgmt",
          "list": "Case Documents",
          "event": "ItemCreated"
        }
      },
      "Extract_Metadata": {
        "type": "Flow",
        "inputs": {
          // Metadata extraction logic
        }
      },
      "Update_Document_Set": {
        "type": "SharePoint",
        "inputs": {
          // Document set update logic
        }
      }
    }
  }
}
```

## III. Site Template Examples

### A. Legal Case Site Template
```xml
<pnp:ProvisioningTemplate
    xmlns:pnp="http://schemas.dev.office.com/PnP/2021/03/ProvisioningSchema">
  
  <pnp:ContentTypes>
    <!-- Legal document content types -->
    <pnp:ContentType ID="0x0101002323232323232323232323232323"
                     Name="Legal Document"
                     Description="Base content type for legal documents"
                     Group="Legal Content Types">
      <pnp:FieldRefs>
        <pnp:FieldRef ID="{23232323-2323-2323-2323-232323232323}"
                     Name="CaseNumber"
                     Required="true"/>
        <!-- Additional field references -->
      </pnp:FieldRefs>
    </pnp:ContentType>
  </pnp:ContentTypes>

  <pnp:Lists>
    <!-- Case-specific document libraries -->
    <pnp:ListInstance Title="Case Documents"
                      TemplateType="101"
                      Url="CaseDocuments"
                      EnableVersioning="true"
                      EnableModeration="true">
      <pnp:ContentTypeBindings>
        <pnp:ContentTypeBinding ContentTypeID="0x0101002323232323232323232323232323"/>
      </pnp:ContentTypeBindings>
    </pnp:ListInstance>
  </pnp:Lists>
</pnp:ProvisioningTemplate>
```

## IV. PowerShell Automation Scripts

### A. Site Provisioning
```powershell
# Connect to SharePoint Online
Connect-PnPOnline -Url "https://mordinilaw.sharepoint.com" -Interactive

# Site creation function
function New-LegalCaseSite {
    param(
        [Parameter(Mandatory=$true)]
        [string]$CaseNumber,
        
        [Parameter(Mandatory=$true)]
        [string]$CaseTitle,
        
        [Parameter(Mandatory=$true)]
        [string]$AttorneyEmail
    )
    
    try {
        # Create site
        $siteUrl = "https://mordinilaw.sharepoint.com/sites/case-$CaseNumber"
        New-PnPSite -Type TeamSite -Title $CaseTitle -Url $siteUrl -Owner $AttorneyEmail
        
        # Apply template
        Connect-PnPOnline -Url $siteUrl -Interactive
        Invoke-PnPSiteTemplate -Path ".\LegalCaseTemplate.xml"
        
        # Configure additional settings
        Set-PnPList -Identity "Documents" -EnableContentTypes $true
        Add-PnPContentTypeToList -List "Documents" -ContentType "Legal Document"
        
        # Set up document sets
        Enable-PnPFeature -Identity "3bae86a2-776d-499d-9db8-fa4cdc7884f8" -Scope Site
        
        Write-Host "Site provisioning completed successfully." -ForegroundColor Green
    }
    catch {
        Write-Error "Error during site provisioning: $_"
        throw
    }
}
```

### B. Permission Management
```powershell
# Permission management function
function Set-LegalCasePermissions {
    param(
        [Parameter(Mandatory=$true)]
        [string]$SiteUrl,
        
        [Parameter(Mandatory=$true)]
        [string]$CaseTeam
    )
    
    try {
        Connect-PnPOnline -Url $SiteUrl -Interactive
        
        # Break inheritance
        Set-PnPListPermission -Identity "Case Documents" -BreakRole
        
        # Add case team
        Add-PnPGroupMember -LoginName $CaseTeam -Group "Case Team Members"
        
        # Set specific permissions
        Set-PnPGroupPermissions -Identity "Case Team Members" -AddRole "Contribute"
        Set-PnPGroupPermissions -Identity "Visitors" -RemoveRole "Read"
    }
    catch {
        Write-Error "Error setting permissions: $_"
        throw
    }
}
```

## V. Teams Integration

### A. Teams Tab Configuration
```typescript
export class LegalCaseTab extends BaseClientSideWebPart<ILegalCaseTabProps> {
  protected async onInit(): Promise<void> {
    await super.onInit();
    
    // Initialize Microsoft Teams context
    const context = await this.context.msGraphClientFactory.getClient('3');
    const team = await context.api('/teams/{team-id}').get();
    
    // Configure tab settings
    this.properties.teamContext = {
      teamId: team.id,
      channelId: this.context.sdks.microsoftTeams.context.channelId
    };
  }
}
```

## VI. Governance and Security

### A. Audit Configuration
```powershell
# Configure audit settings
function Set-LegalSiteAudit {
    param(
        [Parameter(Mandatory=$true)]
        [string]$SiteUrl
    )
    
    try {
        Connect-PnPOnline -Url $SiteUrl -Interactive
        
        # Enable audit settings
        Set-PnPAuditing -EnableAuditing
        Set-PnPAuditing -RetentionTime 180
        Set-PnPAuditing -TrimAuditLog
        
        # Configure audit flags
        $auditFlags = [Microsoft.SharePoint.Client.AuditMaskType]::All
        Set-PnPAuditing -AuditFlags $auditFlags
        
        # Enable versioning
        Get-PnPList | ForEach-Object {
            if ($_.BaseTemplate -eq 101) {
                Set-PnPList -Identity $_.Title -EnableVersioning $true -MajorVersions 500
            }
        }
    }
    catch {
        Write-Error "Error configuring audit settings: $_"
        throw
    }
}
```

## VII. Document Management Patterns

### A. Document Set Creation
```powershell
function New-LegalDocumentSet {
    param(
        [Parameter(Mandatory=$true)]
        [string]$LibraryName,
        
        [Parameter(Mandatory=$true)]
        [string]$DocumentSetName,
        
        [Parameter(Mandatory=$true)]
        [hashtable]$Metadata
    )
    
    try {
        # Create document set
        $docSet = Add-PnPDocumentSet -List $LibraryName -Name $DocumentSetName
        
        # Set metadata
        foreach ($key in $Metadata.Keys) {
            Set-PnPListItem -List $LibraryName -Identity $docSet.Id -Values @{$key=$Metadata[$key]}
        }
        
        # Apply retention policy
        $retention = @{
            RetentionPeriod = 1095 # 3 years in days
            RetentionAction = "Delete"
        }
        Set-PnPListItemRetention -List $LibraryName -Identity $docSet.Id @retention
    }
    catch {
        Write-Error "Error creating document set: $_"
        throw
    }
}
```