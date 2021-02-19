# /packages/intranet-forum/www/intranet-forum/forum/new-3.tcl
#
# Copyright (C) 2003 - 2009 ]project-open[
#
# All rights reserved. Please check
# https://www.project-open.com/license/ for details.

ad_page_contract {
    Process invitation emails
    @author frank.bergmann@project-open.com
} {
    notifyee_id:multiple,optional
    object_id:integer
    survey_id:integer
    return_url
    subject
    message:allhtml
    { cancel "" }
    { process_mail_queue_now_p 1 }
    { throttle_seconds 0 }
}


# ad_return_complaint 1 "notifyee_id=$notifyee_id<br>object_id=$object_id<br>survey_id=$survey_id<br>return_url=$return_url<br>subject=$subject<br>message=$message"

# ------------------------------------------------------------------
# Security, Parameters & Default
# ------------------------------------------------------------------

set current_user_id [auth::require_login]
set system_url [im_system_url]


set object_found_p 0
db_0or1row object_info "
	select	1 as object_found_p,
		o.object_type,
		acs_object__name(o.object_id) as object_name,
		(select min(bou.url) from im_biz_object_urls bou where bou.object_type = o.object_type and url_type = 'view') as object_base_url
	from	acs_objects o
	where	object_id = :object_id
"
if {!$object_found_p} {
   ad_return_complaint 1 "Didn't find object #$object_id"
   ad_script_abort
}

if {"" != $cancel} {
    # The user pressed the "Cancel" button in the previous form
    ad_returnredirect $return_url
    ad_script_abort
}

${object_type}_permissions $current_user_id $object_id view_p read_p write_p admin_p
if {!$write_p} {
    ad_return_complaint 1 "Y don't have write permissions (project manager, object administrator, ...) on object $object_id ('$object_name')"
    ad_script_abort
}


# Determine the sender address
set sender_email [parameter::get -package_id [apm_package_id_from_key acs-kernel] -parameter "SystemOwner" -default [ad_system_owner]]
if {"CurrentUser" eq [parameter::get_from_package_key -package_key "intranet-simple-survey" -parameter "SenderMail" -default "CurrentUser"]} {
    set sender_email [db_string sender_email "select email from parties where party_id = :current_user_id" -default $sender_email]
} 

db_1row survey_info "
	select	name as survey_name,
		short_name as survey_short_name,
		description as survey_description
	from	survsimp_surveys
	where	survey_id = :survey_id
"


set found_sender_p 0
db_1row user_info "
	select	pe.person_id as sender_user_id,
		im_name_from_user_id(pe.person_id) as sender_name,
		first_names as sender_first_names,
		last_name as sender_last_name,
		email as sender_email,
		1 as found_sender_p
	from	persons pe,
		parties pa
	where	pe.person_id = pa.party_id and
		pe.person_id = :current_user_id
"
if {!$found_sender_p} {
    ad_return_complaint 1 "Didn't find sender with user_id=$current_user_id"
    ad_script_abort
}

# ---------------------------------------------------------------
# Send out messages
# ---------------------------------------------------------------

set error_list [list]
foreach id $notifyee_id {

    ns_log Notice "invite-members-2: Sending out email to user_id=$id"
    set found_p 0
    db_0or1row user_info "
	select	pe.person_id as user_id,
		im_name_from_user_id(pe.person_id) as name,
		first_names,
		last_name,
		email,
		1 as found_p
	from	persons pe,
		parties pa
	where	pe.person_id = pa.party_id and
		pa.party_id = :id
    "
    if {0 eq $found_p} { continue }
    ns_log Notice "invite-members-2: Sending out to email: '$email'"


    set auto_login [im_generate_auto_login -user_id $user_id]
    set survey_url [export_vars -base "/simple-survey/one" {survey_id {related_object_id $object_id}}]
    set object_url "$object_base_url$object_id"
    set survey_url_auto_login [export_vars -base "$system_url/intranet/auto-login" {user_id {url $survey_url} auto_login}]
    set object_url_auto_login [export_vars -base "$system_url/intranet/auto-login" {user_id {url $object_url} auto_login}]


    # Replace message %...% variables by user's variables
    set substitution_list [list \
			       system_url $system_url \
			       user_id $user_id \
			       name $name \
			       first_names $first_names \
			       last_name $last_name \
			       email $email \
			       auto_login $auto_login \
			       sender_name $sender_name \
			       sender_first_names $sender_first_names \
			       sender_last_name $sender_last_name \
			       sender_email $sender_email \
			       survey_url $survey_url \
			       survey_url_auto_login $survey_url_auto_login \
			       survey_name $survey_name \
			       survey_short_name $survey_short_name \
			       survey_description $survey_description \
			       object_url $object_url \
			       object_url_auto_login $object_url_auto_login \
			       object_name $object_name \
    ]
    set message_subst [lang::message::format $message $substitution_list]
    set message_subst [regsub -all "\r\n" $message_subst "\n"]

    #ad_return_complaint 1 "<pre>[string2hex $message_subst]</pre>"; ad_script_abort
    #ad_return_complaint 1 "<pre>subject=$subject\nbody=$message_subst\n$substitution_list</pre>"

    # Remember the date of the last email
    if {[im_column_exists persons last_email_sent]} {
	db_dml update_last_email "update persons set last_email_sent = now() where person_id = :user_id"
    }

    ns_log Notice "invite-members-2: Sending out email to $email: subject=$subject"
    ns_log Notice "invite-members-2: Sending out email to $email: message=$message_subst"

    if {[catch {
	acs_mail_lite::send \
	    -send_immediately \
	    -to_addr $email \
	    -from_addr $sender_email \
	    -subject $subject \
	    -body $message_subst

	#   -file_ids $attachment_ci_id
    } errmsg]} {
        ns_log Error "member-notify: Error sending to \"$email\": $errmsg"
	lappend error_list "<p>Error sending out mail to: $email</p><div><code>[ns_quotehtml $errmsg]</code></div>"
    }

    if {$throttle_seconds > 0} { im_exec sleep $throttle_seconds }
}


# ---------------------------------------------------------------
# Process the mail queue right now
# ---------------------------------------------------------------

if {$process_mail_queue_now_p} {
    acs_mail_process_queue
}

if {[llength $error_list] > 0} {
    ad_return_complaint 1 "<b>Errors sending out invitations</b>:<br><ul><li>[join $error_list "<li>"]</ul>"
    ad_script_abort
}


db_release_unused_handles 
ad_returnredirect $return_url

