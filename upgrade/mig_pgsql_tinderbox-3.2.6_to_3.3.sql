ALTER TABLE port_dependencies MODIFY dependency_type VARCHAR(16) CHECK (dependency_type IN ('UNKNOWN', 'EXTRACT_DEPENDS', 'PATCH_DEPENDS', 'FETCH_DEPENDS', 'BUILD_DEPENDS', 'LIB_DEPENDS', 'RUN_DEPENDS', 'TEST_DEPENDS')) DEFAULT 'UNKNOWN';
UPDATE config SET config_option_value = '3.3' WHERE config_option_name = '__DSVERSION__';
