<master>
<property name="doc(title)">@page_title;literal@</property>
<property name="main_navbar_label">@main_navbar_label;literal@</property>
<property name="sub_navbar">@sub_navbar;literal@</property>
<property name="left_navbar">@left_navbar_html;literal@</property>
<property name="show_context_help">@show_context_help_p;literal@</property>

<table>
<tr valign="top">
<td>
	@html;noquote@
</td>
<td>
	<h1><%= [lang::message::lookup "" intranet-simple-survey.Project_Report_Help "Project Report Help"] %></h1>
	<p>
	<%= [lang::message::lookup "" intranet-simple-survey.Project_Report_Help "
	This report shows the 'traffic light' status of project reports from the last 60 days.<br>
	Please:<br>
	<ul>
	<li>Hold your mouse over the colored dots to see the corresponding status question.
	<li>Click on one of the colored dots to see the full status report.
	</ul>
	System administrators can configure the project status report categories in the 
	Admin -&gt; Simple Survey section.
	"] %>
	</p>
</td>
</tr>
</table>

