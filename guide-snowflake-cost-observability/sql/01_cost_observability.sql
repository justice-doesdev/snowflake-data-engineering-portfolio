-- Portfolio lab: synthetic names and example thresholds only.
CREATE DATABASE IF NOT EXISTS PORTFOLIO_DEMO_DB;
CREATE SCHEMA IF NOT EXISTS PORTFOLIO_DEMO_DB.OPS;

CREATE OR REPLACE TABLE PORTFOLIO_DEMO_DB.OPS.COST_REVIEW_QUEUE (
    usage_date DATE,
    warehouse_name VARCHAR,
    credits_used NUMBER(18, 3),
    trailing_14d_avg NUMBER(18, 3),
    change_ratio NUMBER(18, 3),
    review_status VARCHAR DEFAULT 'OPEN',
    review_owner VARCHAR,
    resolution_note VARCHAR,
    detected_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

INSERT INTO PORTFOLIO_DEMO_DB.OPS.COST_REVIEW_QUEUE (
    usage_date, warehouse_name, credits_used, trailing_14d_avg, change_ratio
)
WITH daily_usage AS (
    SELECT
        start_time::DATE AS usage_date,
        warehouse_name,
        SUM(credits_used) AS credits_used
    FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
    WHERE start_time >= DATEADD(day, -30, CURRENT_DATE())
      AND start_time < CURRENT_DATE()
    GROUP BY 1, 2
), scored AS (
    SELECT
        usage_date,
        warehouse_name,
        credits_used,
        AVG(credits_used) OVER (
            PARTITION BY warehouse_name
            ORDER BY usage_date
            ROWS BETWEEN 14 PRECEDING AND 1 PRECEDING
        ) AS trailing_14d_avg
    FROM daily_usage
)
SELECT
    usage_date,
    warehouse_name,
    credits_used,
    trailing_14d_avg,
    credits_used / NULLIF(trailing_14d_avg, 0) AS change_ratio
FROM scored
WHERE trailing_14d_avg IS NOT NULL
  AND credits_used / NULLIF(trailing_14d_avg, 0) >= 1.5;

