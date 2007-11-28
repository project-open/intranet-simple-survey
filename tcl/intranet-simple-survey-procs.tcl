# /tcl/intranet-simple-survey-procs.tcl
#
# Copyright (C) 2003-2006 Project/Open
#
# All rights reserved. Please check
# http://www.project-open.com/license/ for details.


ad_library {
    Associate Simple Surveys with ]po[ business objects 
    and allow to manage their relationship and recurrence.

    @author frank.bergmann@project-open.com
    @creation-date  January 3rd, 2006
}


# -----------------------------------------------------------
# Standard procedures
# -----------------------------------------------------------

ad_proc -public im_package_survsimp_id { } {
} {
    return [util_memoize "im_package_survsimp_id_helper"]
}

ad_proc -private im_package_survsimp_id_helper {} {
    return [db_string im_package_core_id {
        select package_id from apm_packages
        where package_key = 'intranet-simple-survey'
    } -default 0]
}


# -----------------------------------------------------------
# Component showing a) survey to fill out and b) surveys related to this object
# -----------------------------------------------------------

ad_proc im_survsimp_component { object_id } {
    Shows all associated simple surveys for a given project or company
} {
    set bgcolor(0) "class=roweven"
    set bgcolor(1) "class=rowodd"
    set survey_url "/simple-survey/one"

    set max_header_len [parameter::get_from_package_key -package_key "intranet-simple-survey" -parameter "MaxTableHeaderLen" -default 12]

    set current_user_id [ad_get_user_id]

    # Get information about object type
    db_1row object_type_info "
	select	aot.*,
		aot.pretty_name as aot_pretty_name,
		im_biz_object__type(:object_id) as object_type_id
	from	acs_object_types aot
	where	object_type = (
			select object_type 
			from acs_objects 
			where object_id = :object_id
		)
    "

    # -----------------------------------------------------------
    # Surveys to fill out

    set survsimp_sql "
	select
		som.*,
		som.name as som_name,
		som.note as som_note,
		ss.*
	from
		im_survsimp_object_map som,
		survsimp_surveys ss
	where
		som.survey_id = ss.survey_id
		and som.acs_object_type = :object_type
		and (
			som.biz_object_type_id is null
			OR som.biz_object_type_id = :object_type_id 
		    )
		and im_object_permission_p(ss.survey_id, :current_user_id, 'survsimp_take_survey') = 't'
    "

    set survsimp_html "
	<table>
	<tr class=rowtitle><td>Survey</td><td>Comment</td></tr>
    "
    set ctr 0
    db_foreach survsimp_map $survsimp_sql {
	set som_gif ""
	if {"" != $som_note} {set som_gif [im_gif help $som_note]}
	append survsimp_html "
	    <tr $bgcolor([expr $ctr % 2])>
		<td><a href=\"$survey_url?survey_id=$survey_id\">$short_name</a></td>
		<td>$som_name $som_gif</td>
	    </tr>
	"
	incr ctr
    }

    append survsimp_html "</table>\n"

    if {0 == $ctr} { 
	set survsimp_html ""
    }

    # -----------------------------------------------------------
    # Related Surveys

    set survsimp_responses_sql "
	select	s.*,
		r.response_id
	from
		survsimp_responses r,
		survsimp_surveys s
	where
		r.survey_id = s.survey_id and
		r.related_object_id = :object_id
	order by
		s.survey_id,
		r.response_id DESC
    "

    set survsimp_response_html ""
    set old_survey_id 0
    set response_ctr 0
    set colspan 0
    db_foreach survsimp_responses $survsimp_responses_sql {

	# Create new headers for new surveys
	if {$survey_id != $old_survey_id} {
	    if {0 != $old_survey_id} {
		# Close the last table
		append survsimp_response_html "</table>\n"
	    }
	
	    set questions_sql "
		select	substring(question_text for $max_header_len) as question_text
		from	survsimp_questions
		where	survey_id = :survey_id
		order by sort_key
	    "
	    append survey_header "<tr class=rowtitle>\n"
	    set colspan 0
	    db_foreach q $questions_sql {
		if {[string length $question_text] == $max_header_len} { append question_text "..." }
		append survey_header "<td class=rowtitle>$question_text</td>\n"
		incr colspan
	    }
	    append survey_header "</tr>\n"
	    append survsimp_response_html "<table><tr class=rowtitle><td class=rowtitle colspan=$colspan>$name</td></tr>"
	    append survsimp_response_html $survey_header

	    set old_survey_id $survey_id
	}

	set questions_sql "
		select
			r.*
		from
			survsimp_questions q,
			survsimp_question_responses r
		where
			q.question_id = r.question_id
			and r.response_id = :response_id
		order by sort_key
	"
	append survsimp_response_html "<tr $bgcolor([expr $response_ctr % 2])>\n"
	db_foreach q $questions_sql {
	    append survsimp_response_html "
		<td $bgcolor([expr $response_ctr % 2])>
		$choice_id $boolean_answer $clob_answer $number_answer $varchar_answer $date_answer
		</td>
	    "
	}
	append survsimp_response_html "</tr>\n"

	incr response_ctr
    }

    if {0 != $old_survey_id} {
	append survsimp_response_html "</table>\n"
    }

    # -----------------------------------------------------------
    # Return the results

    return "
	$survsimp_html
	$survsimp_response_html
    "

}

