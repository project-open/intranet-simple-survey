-- /packages/intranet-simple-survey/sql/postgres/intranet-simple-survey-create.sql
--
-- Copyright (c) 2003-2004 Project/Open
--
-- All rights reserved. Please check
-- http://www.project-open.com/license/ for details.
--
-- @author frank.bergmann@project-open.com

-- Sets up an interface to show Security Server messages

---------------------------------------------------------
-- delete potentially existing menus and plugins if this 
-- file is sourced multiple times during development...

select im_component_plugin__del_module('intranet-simple-survey');
select im_menu__del_module('intranet-simple-survey');



---------------------------------------------------------
-- Register components:
--	- at project pages
--	- An admin menu at the ]po[ admin page ('/intranet/admin/index')
--

create or replace function inline_0 ()
returns integer as ' 
declare
    v_plugin            integer;
begin
    -- Show security messages inthe Admin Home Page
    --
    v_plugin := im_component_plugin__new (
	null,					-- plugin_id
	''acs_object'',				-- object_type
	now(),					-- creation_date
	null,					-- creation_user
	null,					-- creation_ip
	null,					-- context_id
	''Project Survey Component'',		-- plugin_name
	''intranet-simple-survey'',		-- package_name
        ''right'',				-- location
	''/intranet/projects/view'',		-- page_url
        null,					-- view_name
        50,					-- sort_order
        ''im_survsimp_project_component $project_id''	-- component_tcl
    );
    return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();




-------------------------------------------------------------
-- Menus
--

-- prompt *** intranet-costs: Create Finance Menu
-- Setup the "Finance" main menu entry
--
create or replace function inline_0 ()
returns integer as '
declare
	-- Menu IDs
	v_menu			integer;
	v_admin_menu 		integer;

	-- Groups
	v_employees		integer;
	v_accounting		integer;
	v_senman		integer;
	v_customers		integer;
	v_freelancers		integer;
	v_proman		integer;
	v_admins		integer;
begin

    select group_id into v_admins from groups where group_name = ''P/O Admins'';
    select group_id into v_senman from groups where group_name = ''Senior Managers'';
    select group_id into v_accounting from groups where group_name = ''Accounting'';
    select group_id into v_customers from groups where group_name = ''Customers'';
    select group_id into v_freelancers from groups where group_name = ''Freelancers'';

    select menu_id
    into v_admin_menu
    from im_menus
    where label=''admin'';

    v_menu := im_menu__new (
	null,			   -- menu_id
	''acs_object'',		   -- object_type
	now(),			   -- creation_date
	null,			   -- creation_user
	null,			   -- creation_ip
	null,			   -- context_id
	''intranet-simple-survey'',	   -- package_name
	''admin_survsimp'',		   -- label
	''Simple Surveys'',		   -- name
	''/intranet-simple-survey/admin/index'',	   -- url
	83,			   -- sort_order
	v_admin_menu,		   -- parent_menu_id
	null			   -- visible_tcl
    );

    PERFORM acs_permission__grant_permission(v_menu, v_admins, ''read'');
    PERFORM acs_permission__grant_permission(v_menu, v_senman, ''read'');

    return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();


