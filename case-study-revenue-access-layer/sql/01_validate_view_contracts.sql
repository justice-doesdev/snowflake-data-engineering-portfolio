-- Synthetic reference pattern. Review before use.
CREATE DATABASE IF NOT EXISTS PORTFOLIO_REVENUE_DB;
CREATE SCHEMA IF NOT EXISTS PORTFOLIO_REVENUE_DB.OPS;

CREATE OR REPLACE TABLE PORTFOLIO_REVENUE_DB.OPS.EXPECTED_VIEW_CONTRACTS (
    view_schema VARCHAR,
    view_name VARCHAR,
    expected_column_count NUMBER,
    contract_owner VARCHAR,
    manifest_version VARCHAR
);

WITH actual_views AS (
    SELECT
        columns.table_schema AS view_schema,
        columns.table_name AS view_name,
        COUNT(*) AS actual_column_count
    FROM PORTFOLIO_REVENUE_DB.INFORMATION_SCHEMA.COLUMNS AS columns
    INNER JOIN PORTFOLIO_REVENUE_DB.INFORMATION_SCHEMA.VIEWS AS views
        ON columns.table_catalog = views.table_catalog
       AND columns.table_schema = views.table_schema
       AND columns.table_name = views.table_name
    WHERE columns.table_schema = 'CURATED'
    GROUP BY 1, 2
)
SELECT
    expected.view_schema,
    expected.view_name,
    expected.expected_column_count,
    actual.actual_column_count,
    CASE
        WHEN actual.view_name IS NULL THEN 'MISSING_VIEW'
        WHEN actual.actual_column_count <> expected.expected_column_count THEN 'COLUMN_COUNT_CHANGED'
        ELSE 'PASS'
    END AS contract_status,
    expected.contract_owner,
    expected.manifest_version
FROM PORTFOLIO_REVENUE_DB.OPS.EXPECTED_VIEW_CONTRACTS AS expected
LEFT JOIN actual_views AS actual
    ON expected.view_schema = actual.view_schema
   AND expected.view_name = actual.view_name
WHERE actual.view_name IS NULL
   OR actual.actual_column_count <> expected.expected_column_count;
