ALTER TABLE port_dependencies CHANGE dependency_type dependency_type ENUM('UNKNOWN', 'PKG_DEPENDS', 'EXTRACT_DEPENDS', 'PATCH_DEPENDS', 'FETCH_DEPENDS', 'BUILD_DEPENDS', 'LIB_DEPENDS', 'RUN_DEPENDS', 'TEST_DEPENDS') DEFAULT 'UNKNOWN';
UPDATE config SET config_option_value = '3.3.2' WHERE config_option_name = '__DSVERSION__';
