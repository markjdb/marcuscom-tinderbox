ALTER TABLE user_permissions DROP CONSTRAINT user_permissions_pkey;
ALTER TABLE user_permissions ADD CONSTRAINT user_permissions_pkey PRIMARY KEY (user_id, user_permission_object_type, user_permission_object_id, user_permission);
UPDATE config SET config_option_value = '3.1' WHERE config_option_name = '__DSVERSION__';
