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
    @creation-date  January 3st, 2006
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
# Standard procedures
# -----------------------------------------------------------

ad_proc im_survsimp_project_component { project_id } {
    Shows al associated simple surveys for a given project.
} {
    set simple_surveys_l10n [lang::message::lookup "" intranet-simple-survey.Simple_Surveys "Simple Surveys"]

    set survsimp_html "adsf"

    return [im_table_with_title $simple_surveys_l10n $survsimp_html]
}
