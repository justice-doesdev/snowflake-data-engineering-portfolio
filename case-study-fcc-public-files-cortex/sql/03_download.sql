-- =============================================================================
-- 03_download.sql — Retrieve cataloged PDFs to the stage, logged + checksummed
-- Retrieval uses only the FCC's official file host. Idempotent: files already
-- downloaded (matching SHA-256 present) are skipped, not re-fetched.
-- =============================================================================

CREATE OR REPLACE PROCEDURE FCC_FILINGS.RAW.SP_DOWNLOAD_BATCH(p_limit INTEGER)
RETURNS VARCHAR
LANGUAGE PYTHON
RUNTIME_VERSION = '3.11'
PACKAGES = ('requests', 'snowflake-snowpark-python')
HANDLER = 'run'
EXTERNAL_ACCESS_INTEGRATIONS = (FCC_PUBLIC_FILES_ACCESS)
AS
$$
import hashlib, io, requests

def run(session, p_limit):
    todo = session.sql(f"""
        SELECT c.file_id, c.station, c.source_url
        FROM FCC_FILINGS.RAW.FILING_CATALOG c
        LEFT JOIN FCC_FILINGS.RAW.DOWNLOAD_LOG d
          ON d.file_id = c.file_id AND d.outcome = 'SUCCESS'
        WHERE d.file_id IS NULL
        LIMIT {int(p_limit)}
    """).collect()

    ok = failed = 0
    for row in todo:
        fid, station, url = row["FILE_ID"], row["STATION"], row["SOURCE_URL"]
        try:
            r = requests.get(url, timeout=60, allow_redirects=True)
            body = r.content
            is_pdf = body[:5] == b"%PDF-"
            if r.status_code == 200 and is_pdf:
                sha = hashlib.sha256(body).hexdigest()
                path = f"{station}/{fid}.pdf"
                session.file.put_stream(
                    io.BytesIO(body), f"@FCC_FILINGS.RAW.PDF_STAGE/{path}",
                    auto_compress=False, overwrite=True,
                )
                session.sql("""
                    INSERT INTO FCC_FILINGS.RAW.DOWNLOAD_LOG
                      (file_id, station, source_url, http_status, bytes, sha256, stage_path, outcome)
                    VALUES (?,?,?,?,?,?,?, 'SUCCESS')
                """, params=[fid, station, url, r.status_code, len(body), sha, path]).collect()
                ok += 1
            else:
                raise ValueError(f"status={r.status_code} pdf={is_pdf}")
        except Exception as e:
            session.sql("""
                INSERT INTO FCC_FILINGS.RAW.DOWNLOAD_LOG
                  (file_id, station, source_url, outcome, error_detail)
                VALUES (?,?,?, 'FAILED', ?)
            """, params=[fid, station, url, str(e)[:500]]).collect()
            failed += 1

    session.sql("ALTER STAGE FCC_FILINGS.RAW.PDF_STAGE REFRESH").collect()
    return f"downloaded={ok} failed={failed}"
$$;
