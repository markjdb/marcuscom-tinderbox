SET FOREIGN_KEY_CHECKS=0;

ALTER TABLE users
  CHANGE User_Password User_Password varchar(41);

INSERT INTO config VALUES ('__DSVERSION__', '2.1.0', -1) ON DUPLICATE KEY UPDATE Config_Option_Value=VALUES(Config_Option_Value);

SET FOREIGN_KEY_CHECKS=1;
