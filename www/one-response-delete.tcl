ad_page_contract {

    Delete one filled-out survey.
    @param  response_id		ID of the response to show

    @creation-date   December 11, 2016
    @cvs-id $Id$
} {
    response_id:integer
    return_url
} 

set current_user_id [auth::require_login]
set admin_p [im_is_user_site_wide_or_intranet_admin $current_user_id]

if {!$admin_p} {
    ad_return_complaint 1 "You don't have the necessary permissions to delete this response"
    ad_script_abort
}

db_dml del_response "delete from survsimp_responses where response_id = :response_id"


ad_returnredirect $return_url

