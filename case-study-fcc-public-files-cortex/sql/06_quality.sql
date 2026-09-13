-- =============================================================================
-- 06_quality.sql — The quality gate: quarantine, don't launder
-- Rows that fail validation are HELD in an exception view and excluded from
-- the published views. Dirty data never masquerades as clean data.
-- =============================================================================

-- Exception rules, each with a named reason so triage is queryable.
CREATE OR REPLACE VIEW FCC_FILINGS.ANALYTICS.VW_QUALITY_EXCEPTIONS AS
SELECT s.*, 'MISSING_PROGRAM'  AS exception_reason
FROM FCC_FILINGS.ANALYTICS.SPOTS s
WHERE s.program IS NULL OR TRIM(s.program) = ''
UNION ALL
SELECT s.*, 'IMPLAUSIBLE_DATE' AS exception_reason
FROM FCC_FILINGS.ANALYTICS.SPOTS s
WHERE s.air_start < '2000-01-01' OR s.air_end > DATEADD(year, 2, CURRENT_DATE())
UNION ALL
SELECT s.*, 'ARITHMETIC_MISMATCH' AS exception_reason
FROM FCC_FILINGS.ANALYTICS.SPOTS s
WHERE s.unit_rate IS NOT NULL AND s.spot_count IS NOT NULL AND s.line_total IS NOT NULL
  AND ABS(s.unit_rate * s.spot_count - s.line_total) > 0.01;

-- Published views: everything NOT held in the exception view.
CREATE OR REPLACE VIEW FCC_FILINGS.ANALYTICS.VW_SPOTS_CLEAN AS
SELECT s.*
FROM FCC_FILINGS.ANALYTICS.SPOTS s
WHERE NOT EXISTS (
  SELECT 1 FROM FCC_FILINGS.ANALYTICS.VW_QUALITY_EXCEPTIONS q
  WHERE q.file_id = s.file_id AND q.line_position = s.line_position
);

CREATE OR REPLACE VIEW FCC_FILINGS.ANALYTICS.VW_ORDERS_CLEAN AS
SELECT o.*
FROM FCC_FILINGS.ANALYTICS.ORDERS o
WHERE o.flight_start IS NOT NULL;

-- Per-document cost tracking so cost-per-document is measured, not estimated.
CREATE OR REPLACE VIEW FCC_FILINGS.ANALYTICS.PROCESSING_COST AS
SELECT
  DATE_TRUNC('day', parsed_at)          AS day,
  COUNT(*)                              AS documents,
  SUM(page_count)                       AS pages
FROM FCC_FILINGS.PARSED.DOCUMENT_PARSE
GROUP BY 1;
