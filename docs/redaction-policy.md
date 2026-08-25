# Public Portfolio Redaction Policy

This repository contains generalized patterns and synthetic examples only.

## Never Publish

- employer, customer, vendor, or employee names;
- Snowflake organizations, account locators, hostnames, query IDs, or request IDs;
- real databases, schemas, tables, warehouses, roles, users, stages, integrations, pipes, tasks, or streams;
- credentials, tokens, private keys, OAuth metadata, connection profiles, or cloud paths;
- production data, exports, logs, dashboards, screenshots, incidents, costs, volumes, SLAs, or contract details;
- proprietary business rules or code copied from a private environment.

## Safe Conventions

Use names such as `PORTFOLIO_DEMO_DB`, `RAW`, `CURATED`, `OPS`, `APP_WH`, `DATA_ENGINEER_ROLE`, `FACT_ORDERS`, and `JOB_AUDIT`. Use synthetic rows, example thresholds, and qualitative outcomes.

## Before Publishing

1. Run `bash scripts/audit_repo.sh`.
2. Review every flagged line manually.
3. Inspect the complete staged diff.
4. Confirm the material could be read by an employer or customer without concern.

