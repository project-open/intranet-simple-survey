# /packages/intranet-simple-survey/www/invite-members.tcl
#
# Copyright (C) 2003-2009 ]project-open[
#
# All rights reserved. Please check
# http://www.project-open.com/license/ for details.

ad_page_contract {
    Invite project members to take a survey
    @author frank.bergmann@project-open.com
} {
    object_id:integer
    { survey_id:integer "" }
    { return_url "" }
}

# ------------------------------------------------------------------
# Security, Parameters & Default
# ------------------------------------------------------------------

set current_user_id [auth::require_login]
set object_type [db_string acs_object_type "select object_type from acs_objects where object_id = :object_id" -default ""]
set page_title [lang::message::lookup "" intranet-simple-survey.Invite_Members "Invite Members for Survey"]
set context_bar [im_context_bar [list /intranet-simple-survey/ $page_title] $page_title]
set locale [ad_conn locale]


# ------------------------------------------------------------------
# 
# ------------------------------------------------------------------

set survey_options [im_survsimp_survey_options]
if {1 eq [llength $survey_options]} {
    set survey_tuple [lindex $survey_options 0]
    set survey_id [lindex $survey_tuple 1]
}

set survey_name [db_string survey_name "select short_name from survsimp_surveys where survey_id = :survey_id" -default "undefined survey"]

if {"" ne $survey_id && "" ne $survey_name} {
    append page_title ": $survey_name"
}

# ad_return_complaint 1 "$survey_id<br>$survey_name"


# ---------------------------------------------------------------
# Determine message
# ---------------------------------------------------------------

lang::message::cache
set subject "[lang::message::lookup "" intranet-simple-survey.Notification_Subject "Invitation to Survey:"] $survey_name"

set message_key intranet-simple-survey.Notification_Message
set message_exists_p [lang::message::message_exists_p $locale $message_key]
if {$message_exists_p} {
    set message [nsv_get lang_message_$locale $message_key]
} else {
    set message "Dear %first_names%,


%sender_name% invites you to take the survey:
Survey name: %survey_name%

Please click on this link to take the survey:
%system_url%%survey_url%

The survey is related to: %object_name%
%system_url%%object_url%


Best regards
%sender_name%"
}



# ------------------------------------------------------------------
# 
# ------------------------------------------------------------------

set stakeholder_sql "
	select	p.person_id as user_id,
		pa.email,
		im_name_from_user_id(p.person_id) as name
	from	acs_rels r, 
		im_biz_object_members bom,
		persons p,
		parties pa
	where	r.rel_id = bom.rel_id and
		r.object_id_one = :object_id and
		r.object_id_two = p.person_id and
		p.person_id = pa.party_id and
		p.person_id not in (
			 select  u.user_id
			 from    users u,
			 acs_rels r,
			 membership_rels mr
		where	 r.rel_id = mr.rel_id and
			 r.object_id_two = u.user_id and
			 r.object_id_one = acs__magic_object_id('registered_users') and
			 mr.member_state != 'approved'		
		)
	order by name
"
set num_stakeholders 0
db_multirow -extend {checked} stakeholders stakeholder_query $stakeholder_sql {

    set checked "checked"
#    if {$current_user_id == $owner_id} { set checked "checked" }

    incr num_stakeholders
}

