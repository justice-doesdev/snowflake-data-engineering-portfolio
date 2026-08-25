-- Portfolio lab: review every statement before use.
CREATE DATABASE IF NOT EXISTS PORTFOLIO_DEMO_DB;
CREATE SCHEMA IF NOT EXISTS PORTFOLIO_DEMO_DB.RAW;
CREATE SCHEMA IF NOT EXISTS PORTFOLIO_DEMO_DB.CURATED;
CREATE SCHEMA IF NOT EXISTS PORTFOLIO_DEMO_DB.OPS;

CREATE OR REPLACE TABLE PORTFOLIO_DEMO_DB.RAW.ORDER_EVENTS (
    event_id VARCHAR,
    order_id VARCHAR,
    order_status VARCHAR,
    order_amount NUMBER(18, 2),
    event_at TIMESTAMP_NTZ,
    ingested_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE PORTFOLIO_DEMO_DB.CURATED.FACT_ORDERS (
    order_id VARCHAR PRIMARY KEY,
    order_status VARCHAR,
    order_amount NUMBER(18, 2),
    source_event_at TIMESTAMP_NTZ,
    updated_at TIMESTAMP_NTZ
);

CREATE OR REPLACE TABLE PORTFOLIO_DEMO_DB.OPS.JOB_AUDIT (
    run_id VARCHAR,
    job_name VARCHAR,
    started_at TIMESTAMP_NTZ,
    finished_at TIMESTAMP_NTZ,
    run_status VARCHAR,
    rows_affected NUMBER,
    error_message VARCHAR
);

CREATE OR REPLACE STREAM PORTFOLIO_DEMO_DB.RAW.ORDER_EVENTS_STREAM
    ON TABLE PORTFOLIO_DEMO_DB.RAW.ORDER_EVENTS;

-- Deduplicate changes before merging so one source row matches each target key.
MERGE INTO PORTFOLIO_DEMO_DB.CURATED.FACT_ORDERS AS target
USING (
    SELECT order_id, order_status, order_amount, event_at
    FROM PORTFOLIO_DEMO_DB.RAW.ORDER_EVENTS_STREAM
    WHERE METADATA$ACTION = 'INSERT'
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY order_id ORDER BY event_at DESC, ingested_at DESC
    ) = 1
) AS source
ON target.order_id = source.order_id
WHEN MATCHED AND source.event_at >= target.source_event_at THEN UPDATE SET
    order_status = source.order_status,
    order_amount = source.order_amount,
    source_event_at = source.event_at,
    updated_at = CURRENT_TIMESTAMP()
WHEN NOT MATCHED THEN INSERT (
    order_id, order_status, order_amount, source_event_at, updated_at
) VALUES (
    source.order_id, source.order_status, source.order_amount,
    source.event_at, CURRENT_TIMESTAMP()
);

-- Add procedure-level error handling and create the scheduled task only after
-- manual validation in the target environment.

