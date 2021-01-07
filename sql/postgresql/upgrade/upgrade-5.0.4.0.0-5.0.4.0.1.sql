SELECT acs_log__debug('/packages/intranet-simple-survey/sql/postgresql/upgrade/upgrade-5.0.4.0.0-5.0.4.0.1.sql','');


update im_menus
set url = '/intranet-simple-survey/reporting/traffic-light-report'
where url = '/intranet-simple-survey/reporting/traffic-light-reports';
