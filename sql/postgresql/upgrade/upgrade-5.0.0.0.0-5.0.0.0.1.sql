-- upgrade-5.0.0.0.0-5.0.0.0.1.sql

SELECT acs_log__debug('/packages/intranet-simple-survey/sql/postgresql/upgrade/upgrade-5.0.0.0.0-5.0.0.0.1.sql','');


update im_menus
set url = '/intranet-simple-survey/reporting/traffic-light-report'
where url = '/intranet-simple-survey/reporting/project-reports';



update survsimp_surveys
set name = 'Project Manager Weekly Report'
where name = 'Project Status Report';

update apm_parameter_values 
set attr_value = 'Project Manager Weekly Report'
where	attr_value = 'Project Status Report' and 
	package_id in (select package_id from apm_packages where package_key = 'intranet-simple-survey');

