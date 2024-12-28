Json code for formatting

{
  "$schema": "https://developer.microsoft.com/json-schemas/sp/v2/calendar-formatting.schema.json",
  "additionalHoverCardProps": {
    "title": "Event Details",
    "body": {
      "text": "=[$Title] + '\n\nStart: ' + =toLocaleDateString(@currentField) + ' ' + =toLocaleTimeString(@currentField) + '\nEnd: ' + =toLocaleDateString([$EndDate]) + ' ' + =toLocaleTimeString([$EndDate])",
      "class": "ms-fontColor-neutralPrimary"
    }
  }
}




To apply JSON formatting to a SharePoint modern calendar event created as a view from a list, you need to follow these steps:

- Create a list with the columns that you want to use for your calendar events, such as Title, Start Date, End Date, Location, etc.
- Create a new calendar view for your list by going to the list settings page and clicking on Create view. Choose Calendar View as the view type and select the columns that you want to display in the calendar.
- Go to the calendar view and click on Format current view in the command bar. This will open a panel where you can enter your JSON code or use the formatting options available.
- To display the hover card with the start date time and end date time for each event, you need to use the additionalHoverCardProps property in your JSON code. This property allows you to customize the content and appearance of the hover card that appears when you hover over an event in the calendar view.
- The additionalHoverCardProps property accepts an object with the following properties: title (the title of the hover card), body (the body of the hover card), footer (the footer of the hover card), and actions (the actions that can be performed on the hover card). Each of these properties can be a string or an object with more properties such as text, icon, class, style, etc.
- To display the start date time and end date time in the body of the hover card, you need to use the @currentField placeholder to refer to the current event data. You can also use other placeholders such as [$Title], [$Location], etc., to refer to other columns in your list. You can also use expressions such as =toLocaleDateString(@currentField) or =toLocaleTimeString(@currentField) to format the date and time values according to your locale.
- Here is an example of JSON code that displays a simple hover card with the start date time and end date time for each event:

```json
{
  "$schema": "https://developer.microsoft.com/json-schemas/sp/v2/calendar-formatting.schema.json",
  "additionalHoverCardProps": {
    "title": "Event Details",
    "body": {
      "text": "=[$Title] + '\n\nStart: ' + =toLocaleDateString(@currentField) + ' ' + =toLocaleTimeString(@currentField) + '\nEnd: ' + =toLocaleDateString([$EndDate]) + ' ' + =toLocaleTimeString([$EndDate])",
      "class": "ms-fontColor-neutralPrimary"
    }
  }
}
```

- You can copy and paste this code into the Format current view panel and click on Preview to see how it looks. You can also modify it according to your preferences and needs.
- To save your changes, click on Save in the panel. To discard your changes, click on Cancel.

I hope this information helps you understand how to use JSON formatting for SharePoint modern calendar events. If you want to learn more about JSON formatting, you can check out these resources:

- [JSON Formatting documentation]
- [JSON Formatting samples]
- [JSON Formatting videos]

Source: Conversation with Bing, 10/7/2023
(1) SharePoint Modern Calendar with Form Formatting JSON - YouTube. https://www.youtube.com/watch?v=fhwAXYvgORs.
(2) Customize Modern SharePoint List Forms Tutorial | JSON Formatting, Validations. https://www.youtube.com/watch?v=H4HyWJ9Seps.
(3) Customize SharePoint List Forms using JSON Formatting (1). https://www.youtube.com/watch?v=y_bdjMRHVmY.
(4) Format calendar view to customize SharePoint | Microsoft Learn. https://learn.microsoft.com/en-us/sharepoint/dev/declarative-customization/view-calendar-formatting.
(5) JavaScript or JSON to customize SharePoint Calendar?. https://sharepoint.stackexchange.com/questions/308265/javascript-or-json-to-customize-sharepoint-calendar.
(6) undefined. https://developer.microsoft.com/json-schemas/sp/v2/calendar-formatting.schema.json.
(7) undefined. https://github.com/rdorrani/SharePoin.
(8) undefined. https://docs.microsoft.com/en-us/shar.
(9) undefined. https://pnp.github.io/sp-dev-list-for.
(10) undefined. https://twitter.com/techan_k.
(11) undefined. https://mynote365.hatenadiary.com/.

From ChatGPT
{
   "$schema": "https://developer.microsoft.com/json-schemas/sp/view-formatting.schema.json",
   "additionalRowClass": "ms-borderColor-neutralLight",
   "hideSelection": true,
   "rowFormatter": {
      "elmType": "div",
      "attributes": {
         "class": {
            "operator": "?",
            "operands": [
               {
                  "operator": "==",
                  "operands": [
                     "@rowIndex",
                     "0"
                  ]
               },
               "ms-bgColor-themeLighter"
            ]
         },
         "title": "='Event: ' + @currentField.title + '\\nFrom: ' + @currentField.start.dateTime + '\\nTo: ' + @currentField.end.dateTime"
      },
      "children": [
         {
            "elmType": "span",
            "attributes": {
               "class": "ms-fontWeight-semibold"
            },
            "txtContent": "@currentField.title"
         },
         {
            "elmType": "div",
            "attributes": {
               "class": "ms-textColor-neutralSecondary"
            },
            "txtContent": {
               "operator": "+",
               "operands": [
                  "From: ",
                  {
                     "operator": "substring",
                     "operands": [
                        "@currentField.start.dateTime",
                        0,
                        19
                     ]
                  }
               ]
            }
         },
         {
            "elmType": "div",
            "attributes": {
               "class": "ms-textColor-neutralSecondary"
            },
            "txtContent": {
               "operator": "+",
               "operands": [
                  "To: ",
                  {
                     "operator": "substring",
                     "operands": [
                        "@currentField.end.dateTime",
                        0,
                        19
                     ]
                  }
               ]
            }
         }
      ]
   }
}


SharePoint JSON formatting can be used to customize the appearance and behavior of SharePoint lists and libraries. In your case, you want to format a SharePoint calendar event view to display the event title, start date/time, end date/time, and show the start and end date/times in a hover tooltip. Here's an example of JSON formatting that achieves this:
This JSON formatting applies to each event in the calendar view. It sets the background color of the first row to a lighter theme color and displays the event title, start date/time, and end date/time. When you hover over an event, it shows a tooltip with the event title, start date/time, and end date/time.

To apply this JSON formatting to your SharePoint calendar view, follow these steps:

Open the SharePoint calendar list.

Click on "Calendar" in the toolbar to open the calendar view.

Click on the "View options" dropdown (it looks like a filter icon) and select "Format current view."

In the format panel, switch to the "Advanced mode."

Replace any existing JSON with the code provided above.

Click "Save" to apply the formatting.

Your SharePoint calendar view should now display events with the specified formatting, including the hover tooltip.


Format for combining event with a lookup column

{
   "$schema": "https://developer.microsoft.com/json-schemas/sp/view-formatting.schema.json",
   "additionalRowClass": "ms-borderColor-neutralLight",
   "hideSelection": true,
   "rowFormatter": {
      "elmType": "div",
      "attributes": {
         "class": {
            "operator": "?",
            "operands": [
               {
                  "operator": "==",
                  "operands": [
                     "@rowIndex",
                     "0"
                  ]
               },
               "ms-bgColor-themeLighter"
            ]
         },
         "title": "='Event: ' + @currentField.title + '\\nPerson: ' + [$Person.title] + '\\nStart Date: ' + @currentField.start.dateTime + '\\nEnd Date: ' + @currentField.end.dateTime"
      },
      "children": [
         {
            "elmType": "span",
            "attributes": {
               "class": "ms-fontWeight-semibold"
            },
            "txtContent": "@currentField.title"
         },
         {
            "elmType": "div",
            "attributes": {
               "class": "ms-textColor-neutralSecondary"
            },
            "txtContent": {
               "operator": "+",
               "operands": [
                  "Person: ",
                  "[$Person.title]"
               ]
            }
         },
         {
            "elmType": "div",
            "attributes": {
               "class": "ms-textColor-neutralSecondary"
            },
            "txtContent": {
               "operator": "+",
               "operands": [
                  "Start Date: ",
                  {
                     "operator": "substring",
                     "operands": [
                        "@currentField.start.dateTime",
                        0,
                        19
                     ]
                  }
               ]
            }
         },
         {
            "elmType": "div",
            "attributes": {
               "class": "ms-textColor-neutralSecondary"
            },
            "txtContent": {
               "operator": "+",
               "operands": [
                  "End Date: ",
                  {
                     "operator": "substring",
                     "operands": [
                        "@currentField.end.dateTime",
                        0,
                        19
                     ]
                  }
               ]
            }
         }
      ]
   }
}
