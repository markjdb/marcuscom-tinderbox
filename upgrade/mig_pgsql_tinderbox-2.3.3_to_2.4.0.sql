CREATE TABLE hooks (
    Hook_Name VARCHAR(32) NOT NULL PRIMARY KEY,
    Hook_Cmd VARCHAR(255),
    Hook_Description TEXT
);

INSERT INTO hooks VALUES ('prePortsTreeUpdate', NULL, 'Hook to run prior to updating a PortsTree.\nIf this hook returns a non-zero value, the PortsTree will not be updated.\nThe following environment will be passed to the hook command:\n\tPORTSTREE : PortsTree name\n\tUPDATE_CMD : Update command\n\tPB : Tinderbox root');
INSERT INTO hooks VALUES ('postPortsTreeUpdate', NULL, 'Hook to run after a PortsTree has been updated.\nThe following environment will be passed to the hook command:\n\tPORTSTREE : PortsTree name\n\tUPDATE_CMD : Update command\n\tPB : Tinderbox root\n\tRC : Result code of the update command');
INSERT INTO hooks VALUES ('preBuildExtract', NULL, 'Hook to run prior to extracting a Build.\nIf this hook returns a non-zero value, the Build will not be extracted.\nThe following environment will be passed to the hook command:\n\tBUILD : Build name\n\tDESTDIR : Extract destination\n\tJAIL : Jail for this Build\n\tPB : Tinderbox root');
INSERT INTO hooks VALUES ('postBuildExtract', NULL, 'Hook to run after a Build has been extracted.\nThe following environment will be passed to the hook command:\n\tBUILD : Build name\n\tDESTDIR : Extract destination\n\tJAIL : Jail for this Build\n\tPB : Tinderbox root\n\tRC : Result code of the extraction');
INSERT INTO hooks VALUES ('preJailUpdate', NULL, 'Hook to run prior to updating a Jail.\nIf this hook returns a non-zero value, the Jail will not be updated.\nThe following environment will be passed to the hook command:\n\tJAIL : Jail name\n\tUPDATE_CMD : Update command\n\tPB : Tinderbox root');
INSERT INTO hooks VALUES ('postJailUpdate', NULL, 'Hook to run after a Jail has been updated.\nThe following environment will be passed to the hook command:\n\tJAIL : Jail name\n\tUPDATE_CMD : Update command\n\tPB : Tinderbox root\n\tRC : Result code of the update command');
INSERT INTO hooks VALUES ('preJailBuild', NULL, 'Hook to run before building a Jail.\nIf this hook returns a non-zero value, the Jail will not be built.\nThe following environment will be passed to the hook command:\n\tJAIL : Jail name\n\tJAIL_OBJDIR : Object directory for Jail\n\tSRCBASE : Source code location for Jail\n\tPB : Tinderbox root');
INSERT INTO hooks VALUES ('postJailBuild', NULL, 'Hook to run after building a Jail.\nThe following environment will be passed to the hook command:\n\tJAIL : Jail name\n\tJAIL_OBJDIR : Object directory for Jail\n\tSRCBASE : Source code location for Jail\n\tPB : Tinderbox root\n\tRC : Result code of the build');
INSERT INTO hooks VALUES ('prePortBuild', NULL, 'Hook to run before building a port.\nIf this command returns a non-zero value, the port will not be built.\nThe following environment will be passed to the hook command:\n\tPACKAGE_NAME : Package name of the port\n\tBUILD : Build name for this port\n\tJAIL : Jail name for this Build\n\tPORTSTREE : PortsTree name for this Build\n\tCHROOT : Location of the Build root\n\tPORTDIR : Directory origin of this port\n\tPB : Tinderbox root');
INSERT INTO hooks VALUES ('postPortBuild', NULL, 'Hook to run after building a port.\nThe following environment will be passed to the hook command:\n\tPACKAGE_NAME : Package name of the port\n\tBUILD : Build name for this port\n\tJAIL : Jail name for this Build\n\tPORTSTREE : PortsTree name for this Build\n\tCHROOT : Location of the Build root\n\tPORTDIR : Directory origin of this port\n\tPB : Tinderbox root\n\tSTATUS : Status of the port build');

INSERT INTO port_fail_reasons VALUES ('hook', 'A pre-condition hook failed to execute successfully', 'RARE');

ALTER TABLE build_ports
  ADD COLUMN Last_Failed_Dependency VARCHAR(255),
  ADD COLUMN Last_Run_Duration INTEGER,
  ADD COLUMN Currently_Building INTEGER NOT NULL DEFAULT 0,
  ALTER COLUMN Last_Status TYPE VARCHAR(16),
  ALTER COLUMN Last_Status SET DEFAULT 'UNKNOWN',
  ADD CHECK (Last_Status IN ('UNKNOWN','SUCCESS','FAIL','BROKEN','LEFTOVERS','DUD','DEPEND'));


UPDATE config SET Config_Option_Value='2.4.0' WHERE Config_Option_Name='__DSVERSION__';
