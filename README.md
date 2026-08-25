# Justice.dev — Data & AI Engineering Portfolio

[![Projects](https://img.shields.io/badge/projects-8-2563eb)](#projects)
[![Focus](https://img.shields.io/badge/focus-Snowflake%20%7C%20Python%20%7C%20Analytics-0ea5e9)](#about-this-portfolio)
[![Safety](https://img.shields.io/badge/data-synthetic-16a34a)](docs/redaction-policy.md)

Public-safe examples of how I approach data platforms, analytics engineering, observability, and AI-assisted applications. The Snowflake labs use synthetic names and data; they demonstrate engineering patterns rather than disclose employer systems.

> Reference implementations only. Review permissions, costs, thresholds, and operational controls before using any pattern in production.

## Start Here

| If you want to see… | Start with | What it demonstrates |
|---|---|---|
| A working data + AI application | [ANI Mystique Demo](https://github.com/justice-doesdev/ani-mystique-demo) | Streamlit, Python, synthetic campaign analytics, optional LLM integration |
| Recent revenue-platform work | [Revenue Analytics Access Layer](case-study-revenue-access-layer/) | Metadata-driven view deployment, contracts, schema-drift controls |
| Recent orchestration work | [Task Orchestration Operations](case-study-task-orchestration-operations/) | Task-fleet lifecycle, run-state monitoring, failure response |
| Recent security and governance work | [Snowflake Platform Governance](case-study-snowflake-platform-governance/) | RBAC rollout, access review, network controls, auditability |
| Recent integration work | [Governed BI Integrations](case-study-governed-bi-integrations/) | Federation, controlled writeback, AI access boundaries |
| Cost visibility and ownership | [Snowflake Cost Observability](guide-snowflake-cost-observability/) | Usage attribution, anomaly flags, operational review |
| Reliable incremental pipelines | [ETL Job Hardening](guide-snowflake-etl-job-hardening/) | Streams/tasks pattern, idempotency, audit logging, recovery |
| Trustworthy analytical data | [Data Quality Reconciliation](guide-data-quality-reconciliation/) | Reconciliation checks, exception workflow, runbook design |
| Plain-language answers | [Portfolio FAQ](docs/faq.md) | Design choices, tradeoffs, safety, and how to review the work |

## Projects

### Selected Recent Work — Sanitized Case Studies

These case studies are grounded in recent Snowflake activity and rewritten with synthetic names, qualitative scale, and reusable patterns. They do not reproduce private SQL or internal architecture identifiers.

#### Revenue Analytics Access Layer

A metadata-driven approach for publishing a broad, consumer-friendly view surface over replicated revenue data, with deployment inventory and schema-contract checks to control the risk of projection-based compatibility views.

**Signals:** Snowflake SQL · metadata-driven DDL · information schema · schema evolution · release validation

[Explore the case study →](case-study-revenue-access-layer/)

#### Task Orchestration Operations

An operating model for a large Snowflake task estate, covering active-versus-suspended lifecycle, serverless and warehouse-backed execution, dependency graphs, skipped runs, failures, and auto-suspension.

**Signals:** Snowflake tasks · orchestration · reliability · failure monitoring · operational governance

[Explore the case study →](case-study-task-orchestration-operations/)

#### Snowflake Platform Governance

A practical governance rollout that treats roles, grants, user changes, network controls, and evidence exports as one observable operating process.

**Signals:** Snowflake RBAC · least privilege · network policy · access evidence · operational controls

[Explore the case study →](case-study-snowflake-platform-governance/)

#### Governed BI Integrations

A boundary-first design for cross-platform query access, controlled BI writeback, and optional AI features without turning an integration role into a general-purpose administrator.

**Signals:** federated analytics · BI writeback · AI enablement · RBAC · data contracts

[Explore the case study →](case-study-governed-bi-integrations/)

### Portfolio Labs

### ANI Mystique Demo

A sanitized Streamlit application for exploring paid-media performance and asking natural-language questions. It runs without an API key through deterministic local analysis and can optionally use Gemini.

**Signals:** Python · Streamlit · data visualization · AI integration · graceful fallback · secret hygiene

[View repository →](https://github.com/justice-doesdev/ani-mystique-demo)

### Snowflake Cost Observability

A synthetic pattern for attributing warehouse consumption, highlighting material changes, and turning findings into a repeatable review process.

**Signals:** Snowflake SQL · ACCOUNT_USAGE · FinOps · observability · operational ownership

[Explore the guide →](guide-snowflake-cost-observability/)

### Snowflake ETL Job Hardening

A defensive incremental-load pattern using a stream, scheduled task, idempotent merge, and audit table.

**Signals:** Snowflake SQL · streams and tasks · reliability · recovery · auditability

[Explore the guide →](guide-snowflake-etl-job-hardening/)

### Data Quality Reconciliation

A reconciliation framework that compares pipeline layers, records exceptions, and separates detection from response.

**Signals:** data quality · SQL · controls · incident triage · stakeholder communication

[Explore the guide →](guide-data-quality-reconciliation/)

## About This Portfolio

I build practical data and AI systems with an emphasis on clear decisions, observable operations, and maintainable handoffs. These examples are intentionally small enough to review quickly while still showing how I reason about failure modes, tradeoffs, and production readiness.

Every Snowflake guide includes:

- a problem statement and architecture diagram;
- synthetic, reviewable SQL;
- decision notes and failure modes;
- an operating runbook and FAQ;
- an explicit sanitization statement.

## Repository Map

```text
.
├── profile/README.md                       # Draft for github.com/justice-doesdev
├── docs/faq.md                             # Portfolio-wide FAQ
├── docs/redaction-policy.md                # Public-safety rules
├── case-study-revenue-access-layer/        # Recent-work case study
├── case-study-task-orchestration-operations/ # Recent-work case study
├── case-study-snowflake-platform-governance/ # Recent-work case study
├── case-study-governed-bi-integrations/    # Recent-work case study
├── guide-snowflake-cost-observability/     # Cost visibility lab
├── guide-snowflake-etl-job-hardening/      # Reliable incremental ETL lab
├── guide-data-quality-reconciliation/      # Data quality lab
└── scripts/audit_repo.sh                   # Local safety checks
```

## Using These Examples

1. Read the project README and choose the pattern that matches your use case.
2. Review the SQL before running it; placeholder objects are deliberately generic.
3. Set your own roles, warehouses, thresholds, retention, and alerting rules.
4. Test in an isolated non-production environment.
5. Add monitoring and ownership appropriate to your organization.

## Safety

No real employer or customer code, names, data, credentials, account identifiers, costs, volumes, incidents, or screenshots belong in this repository. See the [redaction policy](docs/redaction-policy.md) and run `bash scripts/audit_repo.sh` before publishing.

## FAQ

The [portfolio FAQ](docs/faq.md) explains what is synthetic, why the projects are structured as guides, how the examples should be evaluated, and what I would add for a production deployment.
