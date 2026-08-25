# Recent Snowflake Work — Public Sanitization Map

This map was created before drafting the public case studies. It records categories of private information, not the private values themselves.

| Private category | Public replacement | Treatment |
|---|---|---|
| Employer and business-unit names | `EXAMPLE_COMPANY` | Omit from narrative and SQL |
| Revenue-system product or database names | `PORTFOLIO_REVENUE_DB` | Generalize to a revenue analytics domain |
| Source schemas and object names | `SOURCE`, `CURATED`, `SOURCE_OBJECT_N` | Replace every identifier |
| Exact number of deployed objects | `large view surface` | Use qualitative scale only |
| Task names, schedules, fleet size, and run counts | `large task estate`, example schedule | Preserve lifecycle patterns only |
| Exact execution dates and timings | `bounded deployment window` | Omit timestamps and durations |
| Internal roles and users | `PLATFORM_ADMIN`, `ANALYTICS_READER`, `BI_INTEGRATION_ROLE` | Preserve the access pattern only |
| Network locations and allowlists | `<APPROVED_CIDR>` | Never publish addresses or endpoints |
| BI, vendor, and federation object names | `BI_TOOL`, `EXTERNAL_PLATFORM` | Describe the integration boundary generically |
| Internal tags, policies, and audit tables | `DATA_CLASSIFICATION`, `ACCESS_EVIDENCE` | Preserve governance intent |
| Query text and generated DDL | Synthetic SQL written from scratch | Do not copy or lightly rename private code |
| Exact activity counts, costs, and volumes | `material`, `broad`, `recurring` | No production metrics |
| Account, organization, warehouse, or region | Placeholders only | Omit all connection identifiers |

## Claims Boundary

The case studies may state that recent work included broad view deployment, task orchestration, pipeline automation, grants and roles, network controls, access-evidence structures, federation, writeback, and AI-related enablement. They must not claim a specific business outcome, savings figure, SLA improvement, or incident result without separate public-safe evidence.
