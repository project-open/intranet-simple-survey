<master>
<property name="doc(title)">@page_title;literal@</property>
<property name="main_navbar_label">@main_navbar_label;literal@</property>
<property name="sub_navbar">@sub_navbar;literal@</property>
<property name="left_navbar">@left_navbar_html;literal@</property>
<property name="show_context_help">@show_context_help_p;literal@</property>

@html;noquote@

<form action="/intranet-simple-survey/one-response-delete" method=POST>
<%= [export_vars -form {response_id return_url}] %>
<input type=submit value=Delete>
</form>

