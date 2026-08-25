-- Portfolio lab: synthetic objects and example tolerances.
CREATE DATABASE IF NOT EXISTS PORTFOLIO_DEMO_DB;
CREATE SCHEMA IF NOT EXISTS PORTFOLIO_DEMO_DB.OPS;

CREATE OR REPLACE TABLE PORTFOLIO_DEMO_DB.OPS.DQ_EXCEPTIONS (
    check_date DATE,
    check_name VARCHAR,
    expected_value NUMBER(18, 2),
    actual_value NUMBER(18, 2),
    difference_value NUMBER(18, 2),
    severity VARCHAR,
    exception_status VARCHAR DEFAULT 'OPEN',
    exception_owner VARCHAR,
    resolution_note VARCHAR,
    detected_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

INSERT INTO PORTFOLIO_DEMO_DB.OPS.DQ_EXCEPTIONS (
    check_date, check_name, expected_value, actual_value,
    difference_value, severity
)
WITH source_daily AS (
    SELECT
        event_at::DATE AS check_date,
        COUNT(DISTINCT order_id) AS order_count,
        SUM(order_amount) AS order_amount
    FROM PORTFOLIO_DEMO_DB.RAW.ORDER_EVENTS
    GROUP BY 1
), target_daily AS (
    SELECT
        source_event_at::DATE AS check_date,
        COUNT(*) AS order_count,
        SUM(order_amount) AS order_amount
    FROM PORTFOLIO_DEMO_DB.CURATED.FACT_ORDERS
    GROUP BY 1
), comparisons AS (
    SELECT
        COALESCE(s.check_date, t.check_date) AS check_date,
        COALESCE(s.order_count, 0) AS source_count,
        COALESCE(t.order_count, 0) AS target_count,
        COALESCE(s.order_amount, 0) AS source_amount,
        COALESCE(t.order_amount, 0) AS target_amount
    FROM source_daily s
    FULL OUTER JOIN target_daily t USING (check_date)
)
SELECT
    check_date,
    'DAILY_ORDER_COUNT',
    source_count,
    target_count,
    target_count - source_count,
    CASE WHEN ABS(target_count - source_count) > 0 THEN 'HIGH' ELSE 'INFO' END
FROM comparisons
WHERE source_count <> target_count
UNION ALL
SELECT
    check_date,
    'DAILY_ORDER_AMOUNT',
    source_amount,
    target_amount,
    target_amount - source_amount,
    CASE WHEN ABS(target_amount - source_amount) >= 1 THEN 'HIGH' ELSE 'LOW' END
FROM comparisons
WHERE ABS(target_amount - source_amount) >= 0.01;

