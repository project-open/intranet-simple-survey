ad_library {

    Defines a new widgets that draws it's value from a number of simple surveys.
    @author Frank Bergmann frank.bergmann@project-open.com
    @creation-date 2016-06-25
    @cvs-id $Id$
}


ad_proc -public template::widget::simple_survey { element_reference tag_attributes } {
    Generic Simple Survey Widget
} {
    upvar $element_reference element
    ns_log Notice "template::widget::simple_survey: starting"
    ns_log Notice "template::widget::simple_survey: element=[array get element]"

    if { [info exists element(custom)] } {
    	set params $element(custom)
    } else {
	return "Simple Survey Widget: Error: Didn't find 'custom' parameter.<br>Please use a Parameter such as: <tt>{custom {survey_name \"Project Strategic Value\"}} </tt>"
    }

    set survey_name ""
    set survey_name_pos [lsearch $params "survey_name"]
    if { $survey_name_pos >= 0 } {
    	set survey_name [lindex $params $survey_name_pos+1]
	ns_log Notice "template::widget::simple_survey: survey_name=$survey_name"
    } else {
	return "Simple Survey Widget: Error: Didn't find 'survey_name' parameter.<br>Please use a Parameter such as: <tt>{survey_name \"Project Strategic Value\"}</tt><br>element=[array get element]"
    }

    # ---------------------------------------------------------------
    # Get the value of the surveys
    #
    set project_id [im_opt_val -limit_to integer project_id]
    set label $element(label)
    set dynfield_attribute_sql "
 	select	min(attribute_id)
	from	im_dynfield_attributes
	where	acs_attribute_id in (
			select	attribute_id
			from	acs_attributes
			where	object_type = 'im_project' and
				attribute_name = :label
		)
    "
    set dynfield_attribute_id [db_string dynfield_attribute_id $dynfield_attribute_sql -default ""]
    if {[catch {
	set response_sql "
		select	count(*)
		from	survsimp_responses sr
		where	sr.related_object_id = :project_id and
			sr.related_context_id = :dynfield_attribute_id
	"
	set response_count [db_string response_count $response_sql]
    } errmsg]} {
	return "Simple Survey Widget: Error executing SQL statment <br><pre>'$response_sql'</pre><br>
               with error:<br><pre>$errmsg</pre><br>
               elements:<br><pre>[array get element]</pre>
        "
    }

    set html ""
    set default_value ""
    if {[info exists element(value)]} { set default_value $element(value) }

    if {"edit" != $element(mode)} {
	set html "<a href=''>asdf</a> name=$element(name), default_value=$default_value, survey_name=$survey_name"
    } else {
	set html "name=$element(name), default_value=$default_value, survey_name=$survey_name"
    }

    return $html
}
