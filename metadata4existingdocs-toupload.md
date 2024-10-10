Yes, you can pre-tag documents with metadata before uploading them to SharePoint using a few different methods:

1. Use SharePoint Content Types

	•	Create Content Types with Metadata Fields: In SharePoint, you can create content types that contain specific metadata fields. When you upload a document, you can then select the appropriate content type, and the document will prompt you to fill in the relevant metadata before completing the upload.

2. Use Power Automate

	•	Automate Metadata Assignment: You can create a Power Automate flow that triggers when a document is uploaded to a specific library. Based on certain criteria (e.g., file name, location), the flow can automatically assign metadata to the document.

3. Drag-and-Drop with Metadata Prompting

	•	Manual Entry Upon Upload: SharePoint can prompt you for metadata when you drag and drop files into a library that has mandatory metadata fields. You can configure your libraries so that when a user uploads a file, they are forced to input metadata.

4. Bulk Metadata Tagging

	•	Tagging Multiple Documents with Quick Edit: After uploading a batch of documents, you can use the “Quick Edit” view in the document library to add metadata to multiple files at once. This is efficient if you have several files that need similar metadata.

5. Excel for Bulk Metadata

	•	Upload Metadata via Excel: If you have a large number of files and metadata fields, you can export your document library’s metadata structure to Excel, fill it in for each document, and then import the Excel file back to update the documents with their metadata.

These methods offer flexibility depending on how you want to manage your uploads and how much automation you need. If you’re uploading a lot of files, automating metadata application can save time, while smaller uploads can be managed with prompts and manual tagging.