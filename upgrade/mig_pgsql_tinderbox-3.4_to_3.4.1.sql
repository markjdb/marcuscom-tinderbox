UPDATE port_fail_patterns SET port_fail_pattern_expr = '(error.*hostname nor servname provided|fetch:.*No address record|Member name contains .\\.\\.)' WHERE port_fail_pattern_id = '3400';
UPDATE config SET config_option_value = '3.4.1' WHERE config_option_name = '__DSVERSION__';
