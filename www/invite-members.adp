<master>
<property name="doc(title)">@page_title;literal@</property>
<property name="context">@context_bar;literal@</property>
<property name="main_navbar_label"></property>
<h1>@page_title@</h1>


<script type="text/javascript" <if @::__csp_nonce@ not nil>nonce="@::__csp_nonce;literal@"</if>>
window.addEventListener('load', function() { 
     document.getElementById('list_check_all_survsimp').addEventListener('click', function() { acs_ListCheckAll('alerts', this.checked) });
});
</script>


<if "" eq @survey_id@>

<!-- ------------------------------------------------------------------- -->
<!-- Just show a table to select the survey                              -->
<!-- ------------------------------------------------------------------- -->

<form name=alerts method=GET action=invite-members>
<%= [export_vars -form {object_id return_url}] %>

	<table class="list">
	  <tr class="list-header">
	    <th class="list-narrow" colspan=2><%= [lang::message::lookup "" intranet-simple-survey.Select_Survey "Select Survey"] %></th>
	  </tr>
	
	  <tr class="list-odd">
	    <td>#intranet-simple-survey.Survey#</td>
	    <td class="list-narrow">
	        <%= [im_select -translate_p 0 -ad_form_option_list_style_p 1 survey_id $survey_options $survey_id] %>
	    </td>
	  </tr>
	
	  <tr class="list-even">
	    <td>&nbsp;</td>
	    <td class="list-narrow">
	      <input type="submit" value="<%= [lang::message::lookup "" intranet-simple-survey.Select_Survey "Select Survey"] %>">
	    </td>
	  </tr>
	</table>
</form>



</if>
<else>


<!-- ------------------------------------------------------------------- -->
<!-- Allow the user to fine-tune the email and select receipients        -->
<!-- ------------------------------------------------------------------- -->

<form name=alerts method=post action=invite-members-2>
<%= [export_vars -form {object_id survey_id return_url}] %>
	<table class="list">
	  <tr class="list-header">
	    <th class="list-narrow" colspan=2><%= [lang::message::lookup "" intranet-simple-survey.Survey_Invitation "Survey Invitation"] %></th>
	  </tr>
	
	  <tr class="list-even">
	    <td>#intranet-forum.Subject#</td>
	    <td class="list-narrow">
	        <input type=text name=subject value='@subject@' size=60>
	    </td>
	  </tr>
	
	  <tr class="list-odd">
	    <td>#intranet-core.Message#</td>
	    <td class="list-narrow">
	        <textarea name=message rows=15 cols=80>@message;noquote@</textarea>
	    </td>
	  </tr>
	</table>
	<br>


	<table class="list">
	
	  <tr class="list-header">
	    <th class="list-narrow">
		<input id=list_check_all_survsimp type="checkbox" name="_dummy" title="<%= [lang::message::lookup "" intranet-simple-survey.Check_Uncheck_all_rows "Check/Uncheck all rows"] %>" checked>
	    </th>
	    <th class="list-narrow"><%= [lang::message::lookup "" intranet-simple-survey.Email "Email"] %></th>
	    <th class="list-narrow"><%= [lang::message::lookup "" intranet-simple-survey.Name "Name"] %></th>
	  </tr>
	
	  <multiple name=stakeholders>
	  <if @stakeholders.rownum@ odd>
	    <tr class="list-odd">
	  </if> <else>
	    <tr class="list-even">
	  </else>
	
	    <td class="list-narrow">
	        <input type="checkbox" name="notifyee_id" value="@stakeholders.user_id@" id="alerts,@user_id@" @stakeholders.checked@>
	    </td>
	    <td class="list-narrow">
	        @stakeholders.email@
	    </td>
	    <td class="list-narrow">
	        <a href="/intranet/users/view?user_id=@stakeholders.user_id@">@stakeholders.name@</a>
	    </td>
	  </tr>
	  </multiple>
	
	  <tr>
	    <td colspan="3" align="right">
	      <input type="submit" value="<%= [lang::message::lookup "" intranet-simple-survey.Send_Email "Send Email"] %>">
	      <input type="submit" value="<%= [lang::message::lookup "" intranet-simple-survey.Cancel "Cancel"] %>" name="cancel">
	    </td>
	  </tr>
	</table>

</form>
</else>





