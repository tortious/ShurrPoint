use calculated field to create a link
="<a href='"&%URL_Field_Name%&"'> "&[%field_name%]&"</a>"

In Excel you will need columns:

Desc = hyperlink text
URL = URL link
HTML = formula to create an HTML hyperlink anchor
A	B	C
1	Desc	URL	HTML
2	MyLink	https://link.to/blah	=concatenate("<a href=""",A2,""">",B2,"")
In your SharePoint List, you will need a column set as:

Multiple lines of text
Use enhanced rich text (Rich text with pictures, tables, and hyperlinks)
You can then copy/paste from Excel the HTML column into your SharePoint list column while in grid view (allowing adding dozens of rows at a time).

Calculated field for sortable date
=CONCATENATE(TEXT([Some Date Column],"MM")," : ",TEXT([Some Date Column],"MMM"))

Create a pull down list for a SharePoint list filter
<script src="http://code.jquery.com/jquery-1.12.2.min.js" type="text/javascript"></script>
<script type="text/javascript">
$(function(){
	var siteURL="/Lists/MyList/AllItems.aspx?";
	var queryString="";
	$("#ListFilter").click(function(){
		if($("#Column1").val()!=""){
			queryString+="FilterField1=Column1&FilterValue1="+$("#Column1").val();
		}
		if($("#Column2").val()!=""){
			queryString+="&FilterField2=Column2&FilterValue2="+$("#Column2").val();
		}
		window.location.href=siteURL+queryString;
	});
});
</script>
<div> 
Column1:
<select id="Column1">
<option value=""></option>
<option value="Test1">Test1</option>
<option value="Test2">Test2</option>
<option value="Test3">Test3</option>
</select>
&nbsp;Column2:
<select id="Column2">
<option value=""></option>
<option value="Choice1">Choice1</option>
<option value="Choice2">Choice2</option>
<option value="Choice3">Choice3</option>
</select>
&nbsp;<input id="ListFilter" type="button" value="Filter">
</div>

Fixed Header

<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js" type="text/javascript"></script>
<script type="text/javascript">
jQuery(document).ready(function(){
stickyHeaders()
})
function stickyHeaders(){
if( jQuery.inArray( "spgantt.js", g_spPreFetchKeys ) > -1){
SP.SOD.executeOrDelayUntilScriptLoaded(function () {
findListsOnPage();
}, "spgantt.js");
} else {
findListsOnPage();
}
$(window).bind('hashchange', findListsOnPage);
}
function findListsOnPage() {
var lists          = $('.ms-listviewtable')
var quickEditLists = [];
var listViews      = [];
$(lists).each(function(i){
if($(this).find('div[id^="spgridcontainer"]').length > 0 ){
quickEditLists.push($(this))
} else if( $(this).hasClass("ms-listviewgrid") == false ) {
listViews.push($(this))
}
})
if(quickEditLists.length > 0) {
SP.GanttControl.WaitForGanttCreation(function (ganttChart) {
initializeStickyHeaders(quickEditLists, "qe");
});
}
if(listViews.length > 0) {
initializeStickyHeaders(listViews, "lv");
}
}
function initializeStickyHeaders (lists, type) {
var top_old        = [], top_new        = [],
bottom_old     = [], bottom_new     = [],
stickies       = [], headers        = [],
indexOffset    = 0 ;
var style = "position:fixed;" +
"top:65px;" +
"z-index:1;" +
"background-color:beige;" +
"box-shadow:3px 3px 5px #DDDDDD;" +
"display:none"
$(window).unbind('resize.' + type);
$(window).bind  ('resize.' + type, updatestickies );
$('#s4-workspace').unbind('scroll.' + type);
$('#s4-workspace').bind  ('scroll.' + type, updatestickies );
$(lists).each(function(){
headers.push($(this).find($('.ms-viewheadertr:visible')))
});
$(headers).each(function (i) {
var table = $(this).closest("table");
if(table.find("tbody > tr").length > 1) {
table.parent().find(".sticky-anchor").remove()
table.parent().find(".sticky").remove()
var anchor = table.before('<div class="sticky-anchor"></div>')
stickies.push($(this).clone(true,true).addClass("sticky").attr('style', style).insertAfter(anchor))
var tbodies = $(this).parent("thead").siblings("tbody")
if(tbodies.length > 1) {
tbodies.bind("DOMAttrModified", function(){
setTimeout(function(){
$('#s4-workspace').trigger("scroll", true)
}, 250)
})
}
} else {
headers.splice(i-indexOffset,1)
indexOffset++;
}
})
//Do it once even without beeing triggered by an event
updatestickies();
function updatestickies (event, DOMchangeEvent) {
$(headers).each(function (i) {
if(DOMchangeEvent) {
width();
return false;
}
function width() {
stickies[i].width(headers[i].width()).find('th').each(function (j) {
$(this).width(headers[i].find('th:nth-child(' + (j+1) + ')').width())
})
}
top_old[i]    = top_new[i]
top_new[i]    = Math.round($(this).offset().top – 45)
bottom_old[i] = bottom_new[i]
bottom_new[i] = Math.round(top_new[i] – 30 + $(this).closest('table').height())
stickies[i].offset({
left: Math.round(headers[i].closest("div[id^=WebPartWPQ]").offset().left)
});
if(top_old[i] >= 0 && top_new[i] <= 0 ||
bottom_old[i] <= 0 && bottom_new[i] >= 0 ||
top_old[i] === undefined && bottom_old[i] === undefined && top_new[i] < 0 && bottom_new[i] > 0 ) {
width();
stickies[i].fadeIn();
} else if (top_old[i] <= 0 && top_new[i] >= 0 || bottom_old[i] >= 0 && bottom_new[i] <= 0 ) {
stickies[i].fadeOut();
}
})
}
}
</script>

# json to hide Add New button

1. Navigate to the list or document library >> Click on the View dropdown and choose “Format current view” >> Click on “Advanced Mode”
2, Paste the JSON below to hide the New button from the toolbar.


Read more: https://www.sharepointdiary.com/2022/03/hide-button-in-sharepoint-online-list-or-document-library.html#ixzz7zwE38WxO

{
  "commandBarProps" : {
    "commands": [
      {
        "key": "new",
        "hide": true
      }   
    ]
  }
}


#Read more: https://www.sharepointdiary.com/2022/03/hide-button-in-sharepoint-online-list-or-document-library.html#ixzz7zwDrRW9v

# sticky header resources
https://sharepoint.stackexchange.com/questions/154313/how-to-make-a-custom-list-have-sticky-floating-headers
http://www.sharepointsheriff.com/sharepoint-2013-sticky-headers/
https://www.enjoysharepoint.com/sharepoint-jslink-examples/#:~:text=JSLink%20is%20a%20new%20concept,in%20your%20custom%20JSLink%20file
# create a random number
https://answers.microsoft.com/en-us/msoffice/forum/all/random-number/be3e3855-52c1-478e-847b-e92d1806dfe3
https://answers.microsoft.com/en-us/msoffice/forum/all/random-number/be3e3855-52c1-478e-847b-e92d1806dfe3
# permissions
https://support.microsoft.com/en-us/office/customize-permissions-for-a-sharepoint-list-or-library-02d770f3-59eb-4910-a608-5f84cc297782
# create a survey
https://support.microsoft.com/en-us/office/create-a-survey-ea52a787-822e-4f7e-b5ed-77bb14df3aba
# set documents to download when clicked
# connect views to ms_access
https://mycompanyname.sharepoint.com/sites/mysite/_layouts/viewlsts.aspx

# embed Excel
https://www.iwmentor.com/pages/blog?p=create-a-sharepoint-dashboard-file-and-media-web-part
# workflow
https://sharepointmaven.com/4-ways-to-create-workflows-in-sharepoint-online-out-of-the-box/
