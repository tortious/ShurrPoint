import * as React from 'react';
import { useState } from 'react';
import { SPHttpClient, SPHttpClientResponse } from '@microsoft/sp-http';
import { PrimaryButton } from '@fluentui/react/lib/Button';
import { MessageBar, MessageBarType } from '@fluentui/react/lib/MessageBar';

interface ICreateSiteButtonProps {
  context: any;
}

const CreateSiteButton: React.FC<ICreateSiteButtonProps> = (props) => {
  const [isCreating, setIsCreating] = useState(false);
  const [message, setMessage] = useState('');

  const createSite = async (): Promise<void> => {
    setIsCreating(true);
    setMessage('');

    try {
      // Call site creation endpoint
      const response = await props.context.spHttpClient.post(
        `${props.context.pageContext.web.absoluteUrl}/_api/SPSiteManager/create`,
        SPHttpClient.configurations.v1,
        {
          body: JSON.stringify({
            request: {
              Title: "New Case Site",
              Url: `sites/case-${Date.now()}`,
              WebTemplate: "64",
              SiteDesignId: "your-site-design-id"
            }
          })
        }
      );

      if (response.ok) {
        setMessage('Site created successfully!');
      } else {
        throw new Error(`Error: ${response.statusText}`);
      }
    } catch (error) {
      setMessage(`Error creating site: ${error.message}`);
    } finally {
      setIsCreating(false);
    }
  };

  return (
    <div className="create-site-button">
      <PrimaryButton 
        text="Create New Case Site"
        onClick={createSite}
        disabled={isCreating}
      />
      {message && (
        <MessageBar
          messageBarType={message.includes('Error') ? MessageBarType.error : MessageBarType.success}
        >
          {message}
        </MessageBar>
      )}
    </div>
  );
};

export default CreateSiteButton;