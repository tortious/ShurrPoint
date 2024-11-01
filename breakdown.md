To accomplish these steps in Microsoft Power Automate, we’ll need to break down the process into four main actions. Here’s a step-by-step guide:

1. Create a New Teams Site When an Item is Added to the List “Jeff”

	1.	Start with a Trigger:
	•	Begin your flow in Power Automate with the trigger “When an item is created” for your list named “Jeff.”
	•	This will monitor the list and start the flow every time a new item is added.

2. Name the Site Using the CourtNumber Parameter from the Item

	1.	Get Item Details:
	•	Add the action “Get item” (under SharePoint actions) to retrieve the details of the newly created item in the “Jeff” list.
	•	Use the CourtNumber field from this item to reference it later.
	2.	Create a New Teams Site:
	•	Next, add the action “Send an HTTP request to SharePoint” (this action is crucial for creating Teams sites, as Power Automate doesn’t natively support Teams site creation directly).
	•	In this action, configure the HTTP POST request to create a new Teams site, using CourtNumber as part of the site name.
	•	Here’s a general configuration for the HTTP request:
	•	Method: POST
	•	URI: /_api/GroupSiteManager/CreateGroupEx
	•	Headers:
	•	Accept: application/json;odata=verbose
	•	Content-Type: application/json;odata=verbose
	•	Body: Use JSON syntax to define the site’s properties. For example:

{
  "displayName": "@{triggerOutputs()?['body/CourtNumber']}",
  "alias": "@{triggerOutputs()?['body/CourtNumber']}",
  "isPublic": true
}


	•	Replace "isPublic": true with false if you want the site to be private.

	•	This action will create a new Teams site with the name set to the CourtNumber value from the item.

3. Apply the Codjoe Site Template/Site Design and Site Scripts to the New Site

	1.	Run a Site Script:
	•	After the site is created, add the action “Send an HTTP request to SharePoint” again to apply the template.
	•	You’ll need the SiteDesignId for Codjoe Site Template (you should get this ID from your SharePoint Admin or setup guide if it’s a custom template).
	2.	Configure the Site Design HTTP Request:
	•	Set up another HTTP request to apply the site design:
	•	Method: POST
	•	URI: /_api/Microsoft.Sharepoint.Utilities.WebTemplateExtensions.SiteScriptUtility.ApplySiteDesign
	•	Headers:
	•	Accept: application/json;odata=verbose
	•	Content-Type: application/json;odata=verbose
	•	Body: Use the site URL from the previous step in this JSON syntax:

{
  "siteDesignId": "YOUR_SITE_DESIGN_ID",
  "webUrl": "@{outputs('Send_an_HTTP_request_to_SharePoint')['body']['d']['GroupId']}"
}


	•	Note: Replace "YOUR_SITE_DESIGN_ID" with the actual ID of Codjoe Site Template.

4. Update the Item Parameter URL with the New Site URL Just Created

	1.	Retrieve the Site URL:
	•	After creating the site, Power Automate will provide the URL in the output of the “Send an HTTP request to SharePoint” action.
	•	You can capture this URL by referencing outputs('Send_an_HTTP_request_to_SharePoint')['body']['d']['Url'].
	2.	Update the List Item:
	•	Use the “Update item” action to modify the original item in the “Jeff” list.
	•	In the URL field of the item, set the value to the newly created Teams site URL.

Summary of Actions in Power Automate Flow

	1.	Trigger: “When an item is created” (Jeff list)
	2.	Get Item: Retrieve item details, specifically CourtNumber
	3.	HTTP Request (POST): Create a new Teams site using CourtNumber as the name
	4.	HTTP Request (POST): Apply Codjoe Site Template to the new site
	5.	Update Item: Update the URL field in the original item with the new site’s URL

Important Notes

	•	Permissions: Ensure you have the right permissions to create sites, apply site templates, and modify list items.
	•	Site Design ID: You’ll need to know the exact SiteDesignId for Codjoe Site Template.
	•	Testing: Run a few tests with sample items to verify each step works as expected.