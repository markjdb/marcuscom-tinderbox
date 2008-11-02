ALTER TABLE user_permissions DROP PRIMARY KEY;
ALTER TABLE user_permissions ADD PRIMARY KEY (user_id, user_permission_object_type, user_permission_object_id, user_permission);
