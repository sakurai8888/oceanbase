-- =====================================================================
--  sample_oracle_dump.sql
--  Minimal Oracle scheduler dump used to smoke-test convert_jobs.py.
--  Covers the three cases that matter:
--    1. plain hourly job, no arguments
--    2. FREQ=HOURLY + BYDAY + BYHOUR  (illegal on OceanBase -> must be rewritten)
--    3. job with 6 arguments          (values absent -> must be flagged)
--
--  Expected:  python3 convert_jobs.py sample_oracle_dump.sql --report-only
--    - 3 CREATE_JOB blocks parsed
--    - 1 job with arguments (JOB_QA_RULE)
--    - JOB_WEEKLY_FRI flagged under AUTO-REWRITTEN (HOURLY -> WEEKLY)
--    - JOB_QA_RULE flagged under ACTION REQUIRED (arguments not supplied)
-- =====================================================================

BEGIN
dbms_scheduler.create_job('"JOB_HOURLY_SIMPLE"',
job_type=>'STORED_PROCEDURE', job_action=>
'DEMO_PKG.HOURLY_MAIN_SP'
, number_of_arguments=>0,
start_date=>TO_TIMESTAMP_TZ('09-DEC-2022 12.30.39.103045000 PM ASIA/HONG_KONG','DD-MON-RRRR HH.MI.SSXFF AM TZR','NLS_DATE_LANGUAGE=english'), repeat_interval=>
'freq=HOURLY;interval=1;byminute=50;bysecond=0'
, end_date=>NULL,
job_class=>'"DEFAULT_JOB_CLASS"', enabled=>FALSE, auto_drop=>TRUE,comments=>
NULL
);
sys.dbms_scheduler.set_attribute('"JOB_HOURLY_SIMPLE"','NLS_ENV','NLS_LANGUAGE=''AMERICAN'' NLS_TERRITORY=''AMERICA''');
dbms_scheduler.enable('"JOB_HOURLY_SIMPLE"');
COMMIT;
END;
/

BEGIN
dbms_scheduler.create_job('"JOB_WEEKLY_FRI"',
job_type=>'STORED_PROCEDURE', job_action=>
'DEMO_PKG.WEEKLY_FRI_SP'
, number_of_arguments=>0,
start_date=>TO_TIMESTAMP_TZ('13-AUG-2026 04.31.16.338340000 PM ASIA/SHANGHAI','DD-MON-RRRR HH.MI.SSXFF AM TZR','NLS_DATE_LANGUAGE=english'), repeat_interval=>
'FREQ=HOURLY;BYDAY=FRI;BYHOUR=14,16,18;BYMINUTE=0;BYSECOND=0'
, end_date=>NULL,
job_class=>'"DEFAULT_JOB_CLASS"', enabled=>FALSE, auto_drop=>TRUE,comments=>
'每周五14:00执行延伸服务成本周度测算'
);
sys.dbms_scheduler.set_attribute('"JOB_WEEKLY_FRI"','NLS_ENV','NLS_LANGUAGE=''AMERICAN'' NLS_TERRITORY=''AMERICA''');
dbms_scheduler.enable('"JOB_WEEKLY_FRI"');
COMMIT;
END;
/

BEGIN
dbms_scheduler.create_job('"JOB_QA_RULE"',
job_type=>'STORED_PROCEDURE', job_action=>
'DEMO_PKG.QA_RULE_MAIN_SP'
, number_of_arguments=>6,
start_date=>TO_TIMESTAMP_TZ('21-DEC-2023 03.09.11.650955000 PM ASIA/HONG_KONG','DD-MON-RRRR HH.MI.SSXFF AM TZR','NLS_DATE_LANGUAGE=english'), repeat_interval=>
'freq=daily;interval=1;byhour=15;byminute=15;bysecond=0'
, end_date=>NULL,
job_class=>'"DEFAULT_JOB_CLASS"', enabled=>FALSE, auto_drop=>TRUE,comments=>
NULL
);
sys.dbms_scheduler.set_attribute('"JOB_QA_RULE"','NLS_ENV','NLS_LANGUAGE=''AMERICAN'' NLS_TERRITORY=''AMERICA''');
COMMIT;
END;
/