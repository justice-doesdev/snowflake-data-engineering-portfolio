-- =============================================================================
-- 04_parse.sql — Cortex document AI over the staged PDFs
-- LAYOUT mode preserves table structure, which is what rate tables need.
-- Unparseable files are recorded, not silently dropped.
-- =============================================================================

CREATE TABLE IF NOT EXISTS FCC_FILINGS.PARSED.DOCUMENT_PARSE (
  file_id      VARCHAR NOT NULL,
  station      VARCHAR NOT NULL,
  stage_path   VARCHAR NOT NULL,
  parsed_at    TIMESTAMP_TZ DEFAULT CURRENT_TIMESTAMP(),
  parse_mode   VARCHAR,
  page_count   INTEGER,
  layout       VARIANT,          -- full AI_PARSE_DOCUMENT output
  parse_error  VARCHAR
);

CREATE OR REPLACE PROCEDURE FCC_FILINGS.PARSED.SP_PARSE_BATCH(p_limit INTEGER)
RETURNS VARCHAR
LANGUAGE SQL
AS
$$
DECLARE
  parsed INTEGER DEFAULT 0;
BEGIN
  INSERT INTO FCC_FILINGS.PARSED.DOCUMENT_PARSE
    (file_id, station, stage_path, parse_mode, page_count, layout, parse_error)
  SELECT
    d.file_id,
    d.station,
    d.stage_path,
    'LAYOUT',
    TRY_TO_NUMBER(parse_result:metadata:pageCount::VARCHAR),
    parse_result,
    parse_result:error::VARCHAR
  FROM (
    SELECT l.file_id, l.station, l.stage_path,
           SNOWFLAKE.CORTEX.AI_PARSE_DOCUMENT(
             TO_FILE('@FCC_FILINGS.RAW.PDF_STAGE', l.stage_path),
             {'mode': 'LAYOUT'}
           ) AS parse_result
    FROM FCC_FILINGS.RAW.DOWNLOAD_LOG l
    LEFT JOIN FCC_FILINGS.PARSED.DOCUMENT_PARSE p ON p.file_id = l.file_id
    WHERE l.outcome = 'SUCCESS' AND p.file_id IS NULL
    LIMIT :p_limit
  ) d;

  parsed := SQLROWCOUNT;
  RETURN 'parsed=' || parsed;
END;
$$;
