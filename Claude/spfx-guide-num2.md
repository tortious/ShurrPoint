# Creating an SPFx Web Part for Teams Site Provisioning

## Table of Contents
1. [Environment Setup](#environment-setup)
2. [Project Creation](#project-creation)
3. [Component Development](#component-development)
4. [Authentication & API Integration](#authentication-and-api)
5. [Site Provisioning Logic](#site-provisioning)
6. [Deployment & Testing](#deployment-and-testing)
7. [Maintenance & Troubleshooting](#maintenance)

## Environment Setup

### Prerequisites
1. Install required tools:
```bash
# Install/Update Node.js 18.x via nvm
nvm install 18
nvm use 18

# Verify Node.js version
node --version  # Should show v18.x.x

# Install Yeoman and SPFx generator globally
npm install -g yo @microsoft/generator-sharepoint

# Verify PnP PowerShell installation
Get-Module -Name "PnP.PowerShell" -ListAvailable
```

### Visual Studio Code Setup
Install these essential extensions:
- SharePoint Framework Snippets
- ESLint
- Prettier
- Debug Visualizer

## Project Creation

### Generate SPFx Solution
```bash
# Create new directory
mkdir teams-site-creator
cd teams-site-creator

# Run SPFx generator
yo @microsoft/sharepoint
```

When prompted, use these settings:
- Solution name: `teams-site-creator`
- BaseUrl: `https://yourtenant.sharepoint.com/sites/development`
- Deploy target: `SharePoint Online only`
- Type: `WebPart`
- Name: `TeamsCreatorButton`
- Description: `Creates Teams sites using PnP template`
- Framework: `React`

### Install Dependencies
```bash
npm install @pnp/sp @pnp/graph @fluentui/react @microsoft/sp-property-pane
```

## Component Development

### Button Component Structure
Create `src/webparts/teamsCreatorButton/components/TeamsCreatorButton.tsx`:

```typescript
import * as React from 'react';
import { useState } from 'react';
import { PrimaryButton, Stack, TextField, MessageBar, MessageBarType } from '@fluentui/react';
import { SPFI } from '@pnp/sp';
import "@pnp/sp/sites";
import "@pnp/sp/webs";

interface ITeamsCreatorButtonProps {
  sp: SPFI;
  context: any;
}

export const TeamsCreatorButton: React.FC<ITeamsCreatorButtonProps> = ({ sp, context }) => {
  const [siteName, setSiteName] = useState('');
  const [creating, setCreating] = useState(false);
  const [message, setMessage] = useState({ text: '', type: MessageBarType.info });

  const createSite = async () => {
    if (!siteName) {
      setMessage({ text: 'Please enter a site name', type: MessageBarType.error });
      return;
    }

    setCreating(true);
    try {
      // Site creation logic will go here
      setMessage({ text: 'Site creation started...', type: MessageBarType.info });
      
      // Call your PnP site creation method here
      
      setMessage({ text: 'Site created successfully!', type: MessageBarType.success });
    } catch (error) {
      setMessage({ 
        text: `Error creating site: ${error.message}`, 
        type: MessageBarType.error 
      });
    }
    setCreating(false);
  };

  return (
    <Stack tokens={{ childrenGap: 15 }}>
      <TextField 
        label="Site Name"
        value={siteName}
        onChange={(_, newValue) => setSiteName(newValue || '')}
      />
      <PrimaryButton 
        text="Create Teams Site"
        onClick={createSite}
        disabled={creating}
      />
      {message.text && (
        <MessageBar messageBarType={message.type}>
          {message.text}
        </MessageBar>
      )}
    </Stack>
  );
};
```

## Authentication and API

### PnP Setup
Create `src/webparts/teamsCreatorButton/pnp-setup.ts`:

```typescript
import { spfi, SPFI } from "@pnp/sp";
import { graphfi, GraphFI } from "@pnp/graph";
import { WebPartContext } from "@microsoft/sp-webpart-base";
import { SPFx as spSPFx } from "@pnp/sp/presets/all";
import { SPFx as graphSPFx } from "@pnp/graph/presets/all";

let _sp: SPFI = null;
let _graph: GraphFI = null;

export const getSP = (context?: WebPartContext): SPFI => {
  if (_sp === null && context !== null) {
    _sp = spfi().using(spSPFx(context));
  }
  return _sp;
};

export const getGraph = (context?: WebPartContext): GraphFI => {
  if (_graph === null && context !== null) {
    _graph = graphfi().using(graphSPFx(context));
  }
  return _graph;
};
```

## Site Provisioning

### Template Application Logic
Create `src/webparts/teamsCreatorButton/services/siteProvisioning.ts`:

```typescript
import { SPFI } from "@pnp/sp";
import "@pnp/sp/sites";
import "@pnp/sp/webs";

export interface ISiteCreationProps {
  siteName: string;
  template: string;
  sp: SPFI;
}

export const createTeamsSite = async ({
  siteName,
  template,
  sp
}: ISiteCreationProps): Promise<string> => {
  try {
    // First, create the site
    const siteUrl = await sp.sites.createCommunicationSite({
      title: siteName,
      url: `sites/${siteName.replace(/\s+/g, '')}`,
      lcid: 1033,
      shareByEmailEnabled: true,
      classification: "LowBusiness",
      WebTemplate: "STS#3"
    });

    // Then apply the template
    await sp.web.applyTemplate(template);

    return siteUrl;
  } catch (error) {
    console.error('Site creation failed:', error);
    throw error;
  }
};
```

## Deployment and Testing

### Build Configuration
Update `config/package-solution.json`:

```json
{
  "solution": {
    "name": "teams-site-creator",
    "id": "your-solution-guid",
    "version": "1.0.0.0",
    "includeClientSideAssets": true,
    "skipFeatureDeployment": true,
    "isDomainIsolated": false,
    "webApiPermissionRequests": [
      {
        "resource": "Microsoft Graph",
        "scope": "Sites.FullControl.All"
      }
    ]
  },
  "paths": {
    "zippedPackage": "solution/teams-site-creator.sppkg"
  }
}
```

### Deployment Steps
```bash
# Build solution
gulp build
gulp bundle --ship
gulp package-solution --ship

# Deploy to App Catalog
Connect-PnPOnline -Url "https://yourtenant.sharepoint.com/sites/appcatalog" -Interactive
Add-PnPApp -Path "./sharepoint/solution/teams-site-creator.sppkg" -Scope Tenant
```

## Maintenance

### Troubleshooting Tips
1. Check browser console for JavaScript errors
2. Verify PnP PowerShell connectivity
3. Review SharePoint API permissions
4. Monitor template application logs

### Performance Optimization
- Implement error boundaries
- Add loading states
- Cache template content
- Use batch operations where possible

### Security Best Practices
1. Use managed identities where possible
2. Implement proper error handling
3. Validate input data
4. Follow least privilege principle
5. Regular security audits

### Future Improvements
1. Add site template selection
2. Implement progress tracking
3. Add success/failure notifications
4. Include retry mechanisms
5. Add template validation

Remember to always test thoroughly in a development environment before deploying to production.
