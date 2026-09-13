-- Operational Intelligence AI System
-- Synthetic reference schema. No employer data or object names.

create schema if not exists OI_LAB;

create or replace table OI_LAB.TASK_RUN_SIGNAL (
    run_id              varchar,
    task_name           varchar,
    domain_name         varchar,
    started_at          timestamp_ntz,
    completed_at        timestamp_ntz,
    status              varchar,
    error_code          varchar,
    error_message       varchar,
    parent_task_name    varchar,
    environment_name    varchar,
    owner_team          varchar
);

create or replace table OI_LAB.SCHEMA_CHANGE_SIGNAL (
    change_id           varchar,
    object_name         varchar,
    changed_at          timestamp_ntz,
    change_type         varchar,
    column_name         varchar,
    old_definition      varchar,
    new_definition      varchar,
    environment_name    varchar,
    owner_team          varchar
);

create or replace table OI_LAB.DATA_QUALITY_SIGNAL (
    check_id            varchar,
    data_product        varchar,
    checked_at          timestamp_ntz,
    rule_name           varchar,
    observed_value      number(18,4),
    threshold_value     number(18,4),
    status              varchar,
    environment_name    varchar,
    owner_team          varchar
);

-- Minimal synthetic scenario for review.
insert overwrite into OI_LAB.TASK_RUN_SIGNAL values
    ('RUN-1001','TASK_LOAD_REVENUE','REVENUE','2026-09-13 06:12:00','2026-09-13 06:14:00','FAILED','100183','Invalid identifier in transform','TASK_INGEST_REVENUE','PROD','DATA_PLATFORM'),
    ('RUN-1002','TASK_BUILD_REVENUE_MART','REVENUE','2026-09-13 06:15:00','2026-09-13 06:15:01','SKIPPED',null,'Upstream dependency failed','TASK_LOAD_REVENUE','PROD','ANALYTICS'),
    ('RUN-1003','TASK_REFRESH_REVENUE_DASHBOARD','REVENUE','2026-09-13 06:16:00','2026-09-13 06:16:01','SKIPPED',null,'Upstream dependency failed','TASK_BUILD_REVENUE_MART','PROD','ANALYTICS');

insert overwrite into OI_LAB.SCHEMA_CHANGE_SIGNAL values
    ('CHG-2001','SRC_REVENUE','2026-09-13 05:52:00','ADD_COLUMN','IS_RETARGETING',null,'BOOLEAN','PROD','SOURCE_INTEGRATIONS');

insert overwrite into OI_LAB.DATA_QUALITY_SIGNAL values
    ('DQ-3001','REVENUE_SOURCE','2026-09-13 06:05:00','ROW_COUNT_DELTA',0.8,10.0,'PASS','PROD','DATA_PLATFORM'),
    ('DQ-3002','REVENUE_MART','2026-09-13 06:20:00','FRESHNESS_MINUTES',95,30,'FAIL','PROD','ANALYTICS');
