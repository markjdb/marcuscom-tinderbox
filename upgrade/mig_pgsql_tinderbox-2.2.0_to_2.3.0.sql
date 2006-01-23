ALTER TABLE builds
  ADD COLUMN Build_Last_Updated TIMESTAMP;

UPDATE config SET Config_Option_Value='2.3.0' WHERE Config_Option_Name='__DSVERSION__';
