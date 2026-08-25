# Portfolio FAQ

## Is this copied from a production environment?

No. The Snowflake examples use synthetic object names, generic fields, example thresholds, and public-safe scenarios. They preserve engineering patterns, not private implementations.

## Are the recent-work case studies based on actual Snowflake activity?

Yes, at the level of engineering patterns. Read-only account metadata was used to verify that the recent work involved a broad revenue access layer, a large task estate with multiple run outcomes, governance and security administration, federation, BI writeback, and AI-related enablement. The published narratives and SQL were then written from scratch with synthetic names. They do not expose the original SQL, systems, identities, task names, schedules, object counts, dates, or business data.

## Which project should I review first?

For working Python, begin with [ANI Mystique](https://github.com/justice-doesdev/ani-mystique-demo). For platform engineering, start with [ETL Job Hardening](../guide-snowflake-etl-job-hardening/). For operations and governance, start with [Cost Observability](../guide-snowflake-cost-observability/) or [Data Quality Reconciliation](../guide-data-quality-reconciliation/).

## Why are several projects guides instead of deployed applications?

The artifacts are designed to expose engineering judgment: architecture, SQL patterns, failure modes, controls, and runbooks. That is often more useful for reviewing data-platform work than a screenshot of a private system.

## Are the SQL files production-ready?

They are reference implementations. A production rollout still needs environment-specific RBAC, data retention, alert routing, workload sizing, cost controls, testing, and change management.

## What does “portfolio lab” mean?

It means the example is deliberately bounded, uses synthetic inputs, and is intended to demonstrate a pattern. It is not presented as a verbatim client deliverable or as evidence of a specific business result.

## How do the examples handle secrets?

No credentials are required for static review. Local secrets, connection profiles, private keys, `.env` files, and Streamlit secret files are excluded from version control and flagged by the audit script.

## What would you add before production?

At minimum: least-privilege roles, separate environments, automated tests, deployment review, monitoring, explicit owners, alert routing, retry and backfill procedures, retention policies, and documented rollback steps.

## Why include runbooks and failure modes?

A pipeline is not complete when the happy path works. Runbooks show how an operator can identify impact, stop further damage, restore service, verify recovery, and prevent recurrence.

## How should a reviewer evaluate this portfolio?

Look for clear problem framing, safe assumptions, readable SQL, intentional tradeoffs, observable state, reversible operations, and documentation that supports both implementation and handoff.

## Where is the private or employer-specific work?

It is not in this repository. Private details remain private; only generalized architecture and synthetic examples are published.
