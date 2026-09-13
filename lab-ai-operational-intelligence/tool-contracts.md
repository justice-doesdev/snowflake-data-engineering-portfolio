# Tool Contracts — Operational Intelligence AI System

## Principle

An agent should receive **purpose-built operational tools**, not a generic administrative console. Narrow contracts improve safety, explainability, and testability.

## Read-Only Tools

### `get_task_failures`

**Purpose:** return failed task runs inside an explicit time window and optional domain.

```text
inputs
  start_time
  end_time
  domain_name? 
  environment_name

returns
  run_id
  task_name
  started_at
  completed_at
  error_code
  error_message
  parent_task_name
  owner_team
```

Guardrails:

- maximum lookback window;
- production and non-production clearly labeled;
- results sourced from curated operational views;
- no arbitrary SQL parameter.

### `get_recent_schema_changes`

**Purpose:** inspect recent structural changes for one named object or a governed dependency set.

```text
inputs
  object_name
  start_time
  end_time

returns
  change_id
  changed_at
  change_type
  column_name
  old_definition
  new_definition
  owner_team
```

Guardrails:

- object must resolve through approved metadata inventory;
- no wildcard account-wide enumeration by default.

### `get_quality_exceptions`

**Purpose:** return failing quality checks for a governed data product.

```text
inputs
  data_product
  start_time
  end_time

returns
  check_id
  checked_at
  rule_name
  observed_value
  threshold_value
  owner_team
```

### `search_runbooks`

**Purpose:** retrieve current operational guidance.

```text
inputs
  query
  system_or_domain
  environment_name?

returns
  document_id
  title
  owner
  effective_date
  last_reviewed_date
  excerpt
  retrieval_score
```

The retrieval service should suppress or clearly mark documents flagged as superseded.

## Action Request Tool

### `prepare_action`

The agent may prepare a request but does not receive final execution authority.

```text
inputs
  action_type
  target_type
  target_name
  parameters
  reason
  evidence_ids

returns
  approval_id
  risk_class
  status = PENDING
  expires_at
```

The service determines risk class and approval requirements. The model does not get to label its own action low risk.

## Bounded Executor

### `execute_approved_action`

This endpoint is not callable unless a valid approval exists.

```text
inputs
  approval_id

server-side checks
  approval exists
  status = APPROVED
  approval not expired
  exact target matches
  exact parameter hash matches
  action supported by executor
  caller/executor identity authorized
  action has not already executed
```

The executor reads action details from the approval record. It should not accept replacement target or parameter values from the agent at execution time.

## Why No Generic `run_sql` Tool?

A generic SQL tool is convenient but collapses several trust boundaries:

- the model chooses both intent and implementation;
- query scope can expand unexpectedly;
- read and write behavior may share one interface;
- SQL review becomes harder to standardize;
- permissions often need to be broader than the intended use case.

For an operational copilot, a better default is a library of narrow, testable tools. Generic SQL can remain available to a human operator outside the agent path.

## Tool Result Requirements

Every tool response should include enough metadata to support audit and evidence traceability:

```text
request_id
executed_at
source_system
freshness_timestamp
result_status
evidence_ids
rows_or_items_returned
warning_flags
```

This lets the agent say not only *what it found*, but how fresh the evidence is and where it came from.
