from graphviz import Digraph

# Create a Digraph
dot = Digraph(comment='New Assignment Processing Workflow')

# Define nodes
dot.node('A', '1. Email Moved to Case-Assignments\n(Outlook Rule)')
dot.node('B', '2. Save Email as PDF + Attachments\n(Manual Save or Python Script)')
dot.node('C', '3. Create New SharePoint Site\n(SharePoint Admin Center)')
dot.node('D', '4. Enable Scripting / Apply Template\n(SharePoint Admin or PnP PowerShell)')
dot.node('E', '5. Upload Files\n(SharePoint Library)')
dot.node('F', '6. Update Master List\n(SharePoint List or Python)')

# Define edges
dot.edges(['AB', 'BC', 'CD', 'DE', 'EF'])

# Render the graph to a file and display
file_path = '/mnt/data/new_assignment_workflow'
dot.render(file_path, format='png', cleanup=True)

file_path + '.png'
