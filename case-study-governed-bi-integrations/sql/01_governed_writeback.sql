-- Synthetic writeback boundary. It does not represent a private business workflow.
CREATE DATABASE IF NOT EXISTS PORTFOLIO_INTEGRATION_DB;
CREATE SCHEMA IF NOT EXISTS PORTFOLIO_INTEGRATION_DB.APP;

CREATE OR REPLACE TABLE PORTFOLIO_INTEGRATION_DB.APP.WRITEBACK_INBOX (
    request_id VARCHAR,
    record_key VARCHAR,
    proposed_status VARCHAR,
    submitted_by VARCHAR,
    submitted_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    validation_status VARCHAR DEFAULT 'PENDING',
    validation_reason VARCHAR
);

CREATE OR REPLACE TABLE PORTFOLIO_INTEGRATION_DB.APP.APPROVED_STATUS_CHANGES (
    request_id VARCHAR PRIMARY KEY,
    record_key VARCHAR,
    approved_status VARCHAR,
    submitted_by VARCHAR,
    approved_at TIMESTAMP_NTZ
);

UPDATE PORTFOLIO_INTEGRATION_DB.APP.WRITEBACK_INBOX
SET
    validation_status = CASE
        WHEN request_id IS NULL OR record_key IS NULL THEN 'REJECTED'
        WHEN proposed_status NOT IN ('OPEN', 'REVIEWED', 'CLOSED') THEN 'REJECTED'
        ELSE 'APPROVED'
    END,
    validation_reason = CASE
        WHEN request_id IS NULL OR record_key IS NULL THEN 'MISSING_REQUIRED_FIELD'
        WHEN proposed_status NOT IN ('OPEN', 'REVIEWED', 'CLOSED') THEN 'INVALID_STATUS'
        ELSE NULL
    END
WHERE validation_status = 'PENDING';

MERGE INTO PORTFOLIO_INTEGRATION_DB.APP.APPROVED_STATUS_CHANGES AS target
USING (
    SELECT request_id, record_key, proposed_status, submitted_by
    FROM PORTFOLIO_INTEGRATION_DB.APP.WRITEBACK_INBOX
    WHERE validation_status = 'APPROVED'
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY request_id ORDER BY submitted_at DESC
    ) = 1
) AS source
ON target.request_id = source.request_id
WHEN NOT MATCHED THEN INSERT (
    request_id, record_key, approved_status, submitted_by, approved_at
) VALUES (
    source.request_id, source.record_key, source.proposed_status,
    source.submitted_by, CURRENT_TIMESTAMP()
);

