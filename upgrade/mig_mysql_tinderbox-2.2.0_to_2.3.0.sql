SET FOREIGN_KEY_CHECKS=0;

ALTER TABLE builds
  ADD Build_Last_Updated datetime;

UPDATE config SET Config_Option_Value='2.3.0' WHERE Config_Option_Name='__DSVERSION__';

SET FOREIGN_KEY_CHECKS=1;
