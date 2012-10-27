INSERT INTO port_fail_reasons VALUES ('apache_version', 'USE_APACHE is defined and the port is not compatible with the default apache version', 'RARE');
INSERT INTO port_fail_reasons VALUES ('apache_macro', 'Illegal use of USE_APACHE macros', 'COMMON');
INSERT INTO port_fail_patterns VALUES (6900, 'apache.*and port requires apache', 'apache_version', 0);
INSERT INTO port_fail_patterns VALUES (7000, 'Illegal use of USE_APACHE', 'apache_macro', 0);
UPDATE config SET config_option_value = '3.4.2' WHERE config_option_name = '__DSVERSION__';
