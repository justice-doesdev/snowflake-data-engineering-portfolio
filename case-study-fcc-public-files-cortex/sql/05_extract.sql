-- =============================================================================
-- 05_extract.sql — Classify documents, then extract orders + spot line items
-- Classification first: agreement forms carry no rates BY DESIGN, so a missing
-- rate on one is expected, while a missing rate on a media order is a defect.
-- =============================================================================

-- Document classification from layout signals + Cortex completion
CREATE OR REPLACE TABLE FCC_FILINGS.PARSED.DOCUMENT_CLASS AS
SELECT
  file_id,
  station,
  SNOWFLAKE.CORTEX.AI_CLASSIFY(
    layout:content::VARCHAR,
    ['AGREEMENT_FORM', 'MEDIA_ORDER', 'INVOICE']
  ):labels[0]::VARCHAR AS doc_type
FROM FCC_FILINGS.PARSED.DOCUMENT_PARSE
WHERE parse_error IS NULL;

-- Order-level extraction via structured completion
CREATE TABLE IF NOT EXISTS FCC_FILINGS.ANALYTICS.ORDERS (
  file_id        VARCHAR NOT NULL,
  station        VARCHAR NOT NULL,
  doc_type       VARCHAR,
  advertiser     VARCHAR,
  flight_start   DATE,
  flight_end     DATE,
  order_total    NUMBER(14,2),
  extracted_at   TIMESTAMP_TZ DEFAULT CURRENT_TIMESTAMP()
);

CREATE TABLE IF NOT EXISTS FCC_FILINGS.ANALYTICS.SPOTS (
  file_id        VARCHAR NOT NULL,
  station        VARCHAR NOT NULL,
  line_position  INTEGER,
  program        VARCHAR,
  daypart        VARCHAR,
  unit_rate      NUMBER(12,2),
  spot_count     INTEGER,
  line_total     NUMBER(14,2),
  air_start      DATE,
  air_end        DATE
);

-- Extraction prompt pattern: the layout JSON is handed to AI_COMPLETE with a
-- strict JSON-only response schema; TRY_PARSE_JSON guards the output. See
-- docs/hard-parts.md for the failure modes this has to survive (page-spanning
-- schedules, two-digit years, multi-tier rate cards).
CREATE OR REPLACE PROCEDURE FCC_FILINGS.ANALYTICS.SP_EXTRACT_BATCH(p_limit INTEGER)
RETURNS VARCHAR
LANGUAGE SQL
AS
$$
BEGIN
  -- Orders
  INSERT INTO FCC_FILINGS.ANALYTICS.ORDERS
    (file_id, station, doc_type, advertiser, flight_start, flight_end, order_total)
  SELECT
    p.file_id, p.station, c.doc_type,
    x.j:advertiser::VARCHAR,
    TRY_TO_DATE(x.j:flight_start::VARCHAR),
    TRY_TO_DATE(x.j:flight_end::VARCHAR),
    TRY_TO_NUMBER(x.j:order_total::VARCHAR, 14, 2)
  FROM FCC_FILINGS.PARSED.DOCUMENT_PARSE p
  JOIN FCC_FILINGS.PARSED.DOCUMENT_CLASS c ON c.file_id = p.file_id
  JOIN LATERAL (
    SELECT TRY_PARSE_JSON(SNOWFLAKE.CORTEX.AI_COMPLETE(
      'claude-sonnet-4-5',
      'Extract from this broadcast political filing. Respond with ONLY a JSON object: '
      || '{"advertiser": string, "flight_start": "YYYY-MM-DD", "flight_end": "YYYY-MM-DD", '
      || '"order_total": number|null, "spots": [{"line_position": int, "program": string, '
      || '"daypart": string, "unit_rate": number|null, "spot_count": int|null, '
      || '"line_total": number|null, "air_start": "YYYY-MM-DD", "air_end": "YYYY-MM-DD"}]} '
      || 'Document layout follows: ' || p.layout:content::VARCHAR
    )) AS j
  ) x
  LEFT JOIN FCC_FILINGS.ANALYTICS.ORDERS o ON o.file_id = p.file_id
  WHERE p.parse_error IS NULL AND o.file_id IS NULL
  LIMIT :p_limit;

  RETURN 'orders_extracted=' || SQLROWCOUNT;
END;
$$;
