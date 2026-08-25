# GitHub Portfolio Upgrade Plan

## Current-State Audit — 2026-08-24

- Public profile: `justice-doesdev`
- Public repositories discovered: one (`ani-mystique-demo`)
- Profile README: not present publicly
- Existing project strengths: synthetic data, secret hygiene, clear local run instructions
- Existing project gaps: repository description/topics are unset; README lacks architecture, screenshots, tests, and a recruiter-focused results/decisions section

## Reference Patterns Adopted

The `sfc-gh-miwhitaker/sfe-public` reference uses a strong public examples model: a “Start Here” decision table, a catalog of self-contained guides, plain-language companion material, quick starts, security files, and explicit no-support/validate-first language. This portfolio adopts those information-design patterns without copying its content.

## Delivery Sequence

1. Publish this repository as `snowflake-data-engineering-portfolio`.
2. Create the special profile repository `justice-doesdev/justice-doesdev` and publish `profile/README.md` as its root `README.md`.
3. Add a concise description and topics to `ani-mystique-demo`.
4. Pin the portfolio repository and ANI Mystique on the profile.
5. Replace lab assumptions with additional sanitized artifacts only after completing a private-to-public sanitization map.

## Recommended Repository Metadata

| Repository | Description | Topics |
|---|---|---|
| `snowflake-data-engineering-portfolio` | Public-safe Snowflake data engineering guides, synthetic SQL patterns, runbooks, and FAQs. | `snowflake`, `sql`, `data-engineering`, `analytics-engineering`, `data-quality`, `finops`, `portfolio` |
| `ani-mystique-demo` | Synthetic Streamlit dashboard for paid-media analytics with optional AI-assisted insights. | `python`, `streamlit`, `analytics`, `data-visualization`, `generative-ai`, `portfolio` |

## Definition of Done

- profile README appears on the GitHub overview page;
- two strongest repositories are pinned;
- every public repository has a description, topics, and a clear README;
- portfolio safety audit passes;
- no claim depends on confidential evidence;
- each new project includes architecture, quick start, decisions, failure modes, runbook, FAQ, and sanitization note.

