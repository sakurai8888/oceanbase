-- =====================================================================
--  Single-job conversion template  (Oracle -> OceanBase 4.4.2)
--  Replace <PLACEHOLDERS>. Delete optional blocks you do not need.
-- =====================================================================

-- ---------------------------------------------------------------------
-- ORACLE ORIGINAL (for reference — do not run on OceanBase)
-- ---------------------------------------------------------------------
-- BEGIN
--   dbms_scheduler.create_job('"<JOB_NAME>"',
--   job_type=>'STORED_PROCEDURE', job_action=>'<PKG>.<PROC>'
--   , number_of_arguments=>0,
--   start_date=>TO_TIMESTAMP_TZ('<DD-MON-YYYY HH.MI.SSXFF AM> <REGION>','DD-MON-RRRR HH.MI.SSXFF AM TZR','NLS_DATE_LANGUAGE=english'), repeat_interval=>
--   '<ORACLE_REPEAT_INTERVAL>'
--   , end_date=>NULL,
--   job_class=>'"DEFAULT_JOB_CLASS"', enabled=>FALSE, auto_drop=>TRUE,comments=>
--   NULL
--   );
--   sys.dbms_scheduler.set_attribute('"<JOB_NAME>"','NLS_ENV','NLS_LANGUAGE=''AMERICAN'' ...');
--   dbms_scheduler.enable('"<JOB_NAME>"');
--   COMMIT;
-- END;
-- /


-- ---------------------------------------------------------------------
-- OCEANBASE CONVERTED
-- ---------------------------------------------------------------------
BEGIN
    DBMS_SCHEDULER.CREATE_JOB(
        job_name        => '<JOB_NAME>',                 -- R1: no double quotes
        job_type        => 'STORED_PROCEDURE',           -- only type supported
        job_action      => '<PKG>.<PROC>',               -- must be VALID, IN-only params
        -- number_of_argument => <N>,                    -- R3: SINGULAR; omit if 0
        start_date      => TO_TIMESTAMP_TZ('<DD-MON-YYYY HH.MI.SSXFF AM> +08:00',
                                           'DD-MON-RRRR HH.MI.SSXFF AM TZR'),  -- R2
        repeat_interval => '<OB_REPEAT_INTERVAL>',       -- see repeat-interval.md
        end_date        => NULL,
        enabled         => FALSE,                        -- R6: enable separately
        auto_drop       => TRUE,
        job_class       => 'DEFAULT_JOB_CLASS',          -- R4: no double quotes
        comments        => NULL                          -- payload, not a comment
    );
END;
/

-- Optional: arguments (Strategy B — positional, no DEFINE_JOB_ARGUMENT)
-- BEGIN
--     DBMS_SCHEDULER.SET_JOB_ARGUMENT_VALUE('<JOB_NAME>', 1, '<v1>');
--     COMMIT;
-- END;
-- /

-- Optional: enable (only if enabled in the Oracle source)
-- BEGIN
--     DBMS_SCHEDULER.ENABLE('<JOB_NAME>');
--     COMMIT;
-- END;
-- /


-- ---------------------------------------------------------------------
-- CHECKLIST FOR THIS JOB
-- ---------------------------------------------------------------------
-- [ ] job_name        : double quotes removed
-- [ ] start_date      : region name -> numeric offset; 3rd param dropped
-- [ ] number_of_argument : SINGULAR (or omitted when 0)
-- [ ] repeat_interval : FREQ/BY pairing valid for the target version
-- [ ] job_class       : double quotes removed
-- [ ] NLS_ENV         : deleted
-- [ ] job_action      : object exists, VALID, no OUT/INOUT params
-- [ ] enabled         : matches the Oracle source state
-- [ ] arguments       : values supplied, or placeholders + collection query