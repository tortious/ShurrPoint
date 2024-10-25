Document sets don’t have their own term store, but they do have unique metadata capabilities that you can configure specifically for each document set. Here’s how this works:

Document Set Metadata

	1.	Custom Columns Specific to Document Sets:
	•	When you create a document set content type, you can add specific columns (metadata fields) to that document set. These fields can be completely custom, capturing case-related details like case type, assigned attorney, or court number.
	•	These columns apply to every instance of that document set, acting as metadata attributes for the set as a whole.
	2.	Shared Metadata Across Documents in the Set:
	•	Document sets allow for inherited metadata—any document you add to a document set can automatically inherit the metadata of the document set. For example, if your document set has a court number or case number, all documents added to that document set can share that metadata value.
	•	This setup is helpful because you don’t have to manually tag each document with that information, ensuring consistency and saving time.
	3.	Using Managed Metadata Columns in Document Sets:
	•	You can add managed metadata fields (from the term store) to a document set. For example, you could add a managed metadata column for court numbers, allowing you to select a court number term for each document set. This combines the benefits of both managed metadata and document sets.
	•	This setup gives you flexibility: you can use the term store for standardized data across the organization while keeping other document-specific details within the document set.

Practical Example

Imagine you create a document set for each court case, with metadata fields like:

	•	Court Number (using a term store if it needs to be standardized across sites)
	•	Case Type (a custom text or choice field)
	•	Date Filed (a date field)
	•	Lead Attorney (a person or group field)

With this setup:

	•	All documents within the document set can inherit the court number and other metadata, providing structured organization.
	•	The court number field can pull directly from the term store, ensuring that you’re using standardized data across all cases.

Summary

So, while document sets don’t have their own term store, they can be configured with custom metadata fields and even managed metadata fields linked to the term store, creating a structured, standardized approach to document management within each case or group. This flexibility allows document sets to provide case-specific organization without cluttering the term store.