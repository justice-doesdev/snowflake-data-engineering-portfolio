# Interview Walkthrough — Operational Intelligence AI System

This note is intentionally concise: it is the version of the project story I would use in an architecture or senior engineering interview.

## 30-Second Summary

I designed a Snowflake-centered operational-intelligence pattern that combines structured platform telemetry, semantic analysis, runbook retrieval, and agent orchestration. The important design choice is that the AI can investigate and recommend broadly, but state-changing actions go through narrow tools and explicit approval, so reasoning capability does not automatically become administrative authority.

## The Problem I Was Solving

Data platforms generate plenty of operational telemetry, but diagnosis is usually fragmented across task history, schema metadata, data-quality checks, ownership, and runbooks. The goal was to reduce time-to-diagnosis while preserving governance and auditability.

## Architecture Decisions I Would Highlight

### Separate structured and unstructured retrieval

Use a governed semantic layer for factual operational questions and a search layer for runbooks and incident knowledge. An agent orchestrates both instead of pretending one retrieval pattern handles every question equally well.

### Curate the evidence surface

The AI does not need unrestricted access to every metadata object. A smaller operational contract improves permissions, semantics, testing, and reliability.

### Separate reasoning from authority

The agent can generate a recommendation or prepare an action request. A deterministic authority layer decides whether a state-changing operation can execute.

### Bind approvals to exact actions

An approval should be tied to one action, one target, one parameter set, and an expiration window. The executor re-reads those approved details rather than accepting replacement values from the model.

### Evaluate system behavior, not prose quality

The evaluation set measures first-failure accuracy, evidence retrieval, root-cause ranking, tool choice, unsupported claims, authorization correctness, and time-to-useful-diagnosis.

## Scenario to Walk Through

A revenue refresh fails shortly after a source schema change.

I would explain the flow as:

1. identify the first failing task;
2. inspect recent structural changes;
3. measure downstream impact;
4. retrieve the current schema-drift runbook;
5. distinguish observed evidence from inferred root cause;
6. recommend remediation;
7. require approval before resuming or altering a production task;
8. log the recommendation, evidence, approval, execution, and outcome.

## Tradeoffs

This architecture adds more control-plane work than simply giving an agent a powerful SQL/admin tool. I consider that worthwhile because generic privileged tools are difficult to constrain, evaluate, and audit.

The architecture can also operate in stages: start with read-only investigation, prove diagnosis quality, then add a small number of reversible approval-gated actions later.

## Questions I Would Expect

**Why not just give the agent SQL access?**  
Because SQL execution couples reasoning and authority, expands the blast radius, and makes authorization harder to reason about. Purpose-built tools give tighter contracts.

**Why use both Analyst and Search?**  
Because task states and metrics are structured facts while runbooks are unstructured context. Each should use the retrieval mode that preserves its semantics.

**How do you prevent hallucinated root causes?**  
Require evidence-first responses, track evidence IDs, evaluate unsupported-claim rate, and allow the system to return insufficient evidence rather than forcing a diagnosis.

**How would you productionize it?**  
Version semantic models and retrieval corpora, add identity propagation, policy enforcement outside the model, regression evaluation, tool rate limits, approval dashboards, and clear break-glass procedures.

## What This Project Is Intended to Demonstrate

This lab is less about a flashy chatbot and more about the architecture around an AI system: semantics, retrieval, tool contracts, governance, observability, evaluation, failure modes, and operational ownership.
