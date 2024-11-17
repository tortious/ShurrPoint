# How to Create Metadata Fields in SharePoint

Metadata fields are like labels or tags that help you organize and find your documents faster. Imagine if your school backpack was filled with random papers, and you needed to find your math homework—metadata is like color-coding those papers by subject, date, or topic. Here’s a step-by-step guide to creating metadata fields in SharePoint.

---

## Step 1: Understand Metadata
Metadata is just extra information attached to a file or item. Examples of metadata fields for your case management might include:
- **Case ID:** A unique number for each case.
- **Claim Number:** The insurance claim connected to the case.
- **Client Name:** The name of the person or company you're representing.
- **Adjuster:** The person from the insurance company handling the case.
- **Jurisdiction:** The court or area where the case is being handled.

These labels make it easier to search and filter documents in SharePoint.

---

## Step 2: Set Up a Document Library
A document library in SharePoint is like a folder where your files live, but smarter.

1. Go to your **SharePoint site** (e.g., your Case Management Hub or a specific case Team Site).
2. Click the **gear icon** (top-right corner) and select **Site Contents**.
3. Choose **+ New** > **Document Library**.
   - Give it a name (e.g., "Court Documents").
   - Click **Create**.

---

## Step 3: Add Metadata Fields (Columns)

### 1. Open Library Settings
1. Navigate to your document library (e.g., "Court Documents").
2. Click the **gear icon** > **Library Settings**.

### 2. Add Columns
Columns are how you define metadata fields for your library.

1. In the **Library Settings** page, find the section labeled **Columns** and click **Create Column**.
2. Fill in the details for each column:
   - **Column Name:** Name your metadata field (e.g., "Case ID").
   - **Type of Information:** Choose the type of data this column will hold:
     - **Single Line of Text:** For simple text like names or IDs.
     - **Number:** For claim numbers or case numbers.
     - **Choice:** For a dropdown list of options (e.g., Jurisdictions).
     - **Date and Time:** For deadlines or filing dates.
     - **Person or Group:** For assigning a specific adjuster or attorney.
   - **Default Value (Optional):** You can set a default value if most files use the same entry.

### 3. Repeat for Each Metadata Field
Create separate columns for each metadata field:
- Case ID (Text or Number)
- Claim Number (Text or Number)
- Client Name (Text)
- Adjuster (Person or Group)
- Jurisdiction (Choice: Dropdown list of jurisdictions)

---

## Step 4: Customize the View
Once your metadata fields are ready, you can configure how you want them displayed.

1. **Go to the Library:**
   - Click **All Documents** > **Edit Current View**.
2. **Select Columns to Display:**
   - Add the columns you just created (e.g., Case ID, Client Name).
   - Arrange their order to make sense for your workflow.
3. Save your changes.

---

## Step 5: Add Metadata to Files
When you upload files to this library, you’ll see fields to fill out metadata.

1. Drag and drop a document into the library.
2. SharePoint will show a panel on the right to fill in the metadata.
   - Enter the **Case ID**, **Client Name**, etc.
3. Save the changes, and your document is now tagged with all the relevant information!

---

## Step 6: Use Filters and Search
Now that your documents are tagged with metadata, you can use filters and search to find what you need.

- **Filters:** On the library page, you’ll see filters on the right. Click them to narrow down files (e.g., “Show only files for Case ID 12345”).
- **Search Bar:** Use the search bar in SharePoint, and it will consider metadata when showing results.

---

## Bonus: Add Metadata Templates for Repeated Use
If you often need the same metadata for new cases:
1. Use **Document Sets**:
   - Go to **Library Settings** > **Advanced Settings** > Enable **Allow Management of Content Types**.
   - Add a **Document Set** content type and pre-fill metadata for common fields.
2. Use **Power Automate**:
   - Automate metadata tagging when uploading files or creating new libraries.

---

## Why Metadata is Better than Folders
Folders are like a locked cabinet—you have to dig through layers to find what you need. Metadata is like a database where you can filter or search for anything in seconds. No more opening folder after folder!

---

Let me know if you’d like a more hands-on example or step-by-step screenshots!
