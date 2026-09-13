-- =============================================================================
-- 01_setup.sql — Database, stage, warehouse, and controlled outbound access
-- Run as: ACCOUNTADMIN (network rule + integration), then a project role
-- =============================================================================

CREATE DATABASE IF NOT EXISTS FCC_FILINGS;
CREATE SCHEMA IF NOT EXISTS FCC_FILINGS.RAW;
CREATE SCHEMA IF NOT EXISTS FCC_FILINGS.PARSED;
CREATE SCHEMA IF NOT EXISTS FCC_FILINGS.ANALYTICS;

-- Right-sized compute: parsing is the only heavy step, and it is per-document.
CREATE WAREHOUSE IF NOT EXISTS FCC_WH
  WAREHOUSE_SIZE = 'XSMALL'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE
  INITIALLY_SUSPENDED = TRUE;

-- Internal stage with a directory table so staged PDFs are queryable.
CREATE STAGE IF NOT EXISTS FCC_FILINGS.RAW.PDF_STAGE
  DIRECTORY = (ENABLE = TRUE)
  ENCRYPTION = (TYPE = 'SNOWFLAKE_SSE');

-- ---------------------------------------------------------------------------
-- Outbound access, least-privilege: ONLY the FCC's official public endpoints.
-- publicfiles.fcc.gov  -> metadata API (folder + file catalog)
-- files.fcc.gov        -> official document file host
-- ---------------------------------------------------------------------------
CREATE NETWORK RULE IF NOT EXISTS FCC_FILINGS.RAW.FCC_EGRESS_RULE
  MODE = EGRESS
  TYPE = HOST_PORT
  VALUE_LIST = ('publicfiles.fcc.gov:443', 'files.fcc.gov:443');

CREATE EXTERNAL ACCESS INTEGRATION IF NOT EXISTS FCC_PUBLIC_FILES_ACCESS
  ALLOWED_NETWORK_RULES = (FCC_FILINGS.RAW.FCC_EGRESS_RULE)
  ENABLED = TRUE
  COMMENT = 'Outbound HTTPS restricted to FCC official public endpoints only';

-- Download attempt log: idempotency + observability in one table.
CREATE TABLE IF NOT EXISTS FCC_FILINGS.RAW.DOWNLOAD_LOG (
  file_id        VARCHAR      NOT NULL,
  station        VARCHAR      NOT NULL,
  source_url     VARCHAR      NOT NULL,
  attempted_at   TIMESTAMP_TZ NOT NULL DEFAULT CURRENT_TIMESTAMP(),
  http_status    INTEGER,
  bytes          INTEGER,
  sha256         VARCHAR,
  stage_path     VARCHAR,
  outcome        VARCHAR      NOT NULL,  -- SUCCESS | FAILED | SKIPPED_EXISTS
  error_detail   VARCHAR
);
