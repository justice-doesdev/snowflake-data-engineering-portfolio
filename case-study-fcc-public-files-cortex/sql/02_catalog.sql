-- =============================================================================
-- 02_catalog.sql — Enumerate political filings via the FCC public metadata API
-- The API is public and unauthenticated; we simply walk a station's political
-- file folders for a given cycle and record every PDF's identity + URL.
-- =============================================================================

CREATE TABLE IF NOT EXISTS FCC_FILINGS.RAW.FILING_CATALOG (
  file_id        VARCHAR NOT NULL,
  station        VARCHAR NOT NULL,
  cycle_year     INTEGER NOT NULL,
  folder_path    VARCHAR,
  file_name      VARCHAR,
  source_url     VARCHAR NOT NULL,
  cataloged_at   TIMESTAMP_TZ DEFAULT CURRENT_TIMESTAMP(),
  CONSTRAINT pk_catalog PRIMARY KEY (file_id)
);

CREATE OR REPLACE PROCEDURE FCC_FILINGS.RAW.SP_CATALOG_STATION(
  p_station VARCHAR, p_cycle_year INTEGER
)
RETURNS VARCHAR
LANGUAGE PYTHON
RUNTIME_VERSION = '3.11'
PACKAGES = ('requests', 'snowflake-snowpark-python')
HANDLER = 'run'
EXTERNAL_ACCESS_INTEGRATIONS = (FCC_PUBLIC_FILES_ACCESS)
AS
$$
import requests

API = "https://publicfiles.fcc.gov/api/manager"

def _folder_tree(entity_id, folder_path):
    """Walk a folder path via the public manager API, returning file records."""
    r = requests.get(
        f"{API}/folder/path.json",
        params={"entityId": entity_id, "sourceService": "tv", "folderPath": folder_path},
        timeout=30,
    )
    r.raise_for_status()
    return r.json()

def run(session, p_station, p_cycle_year):
    # Resolve the station entity, then walk its Political Files / <cycle> tree.
    ent = requests.get(
        f"{API}/service/tv/facility/search/{p_station}.json", timeout=30
    ).json()
    entity_id = ent["results"]["facilityList"][0]["id"]

    root = f"Political Files/{p_cycle_year}"
    to_visit, files = [root], []
    while to_visit:
        path = to_visit.pop()
        tree = _folder_tree(entity_id, path)
        for f in tree.get("folder", {}).get("subfolders", []):
            to_visit.append(f["folder_path"])
        for f in tree.get("folder", {}).get("files", []):
            files.append((
                f["file_id"], p_station, p_cycle_year, path, f["file_name"],
                f"https://publicfiles.fcc.gov/api/manager/download/{f['folder_id']}/{f['file_id']}.pdf",
            ))

    if files:
        session.create_dataframe(
            files,
            schema=["FILE_ID","STATION","CYCLE_YEAR","FOLDER_PATH","FILE_NAME","SOURCE_URL"],
        ).write.mode("append").save_as_table("FCC_FILINGS.RAW.FILING_CATALOG")
    return f"Cataloged {len(files)} filings for {p_station} / {p_cycle_year}"
$$;
