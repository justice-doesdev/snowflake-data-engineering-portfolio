-- Audit and approval contracts for bounded AI-assisted operations.
-- Synthetic reference only; production implementations should use organization-specific
-- identity, policy, retention, and executor controls.

create or replace table OI_LAB.AGENT_INTERACTION_AUDIT (
    interaction_id      varchar,
    occurred_at         timestamp_ntz default current_timestamp(),
    user_identity       varchar,
    question_text       varchar,
    evidence_ids        variant,
    tool_calls          variant,
    recommendation      varchar,
    confidence_label    varchar,
    action_requested    boolean default false,
    approval_id         varchar,
    outcome             varchar
);

create or replace table OI_LAB.ACTION_APPROVAL (
    approval_id         varchar,
    requested_by        varchar,
    requested_at        timestamp_ntz default current_timestamp(),
    action_type         varchar,
    target_type         varchar,
    target_name         varchar,
    parameter_hash      varchar,
    reason              varchar,
    evidence_ids        variant,
    risk_class          varchar,
    status              varchar default 'PENDING',
    approved_by         varchar,
    approved_at         timestamp_ntz,
    expires_at          timestamp_ntz,
    executed_at         timestamp_ntz,
    execution_result    varchar
);

-- The executor should validate approval server-side rather than trusting a model-supplied flag.
create or replace view OI_LAB.V_EXECUTABLE_APPROVALS as
select
    approval_id,
    action_type,
    target_type,
    target_name,
    parameter_hash,
    approved_by,
    approved_at,
    expires_at
from OI_LAB.ACTION_APPROVAL
where status = 'APPROVED'
  and approved_at is not null
  and expires_at > current_timestamp()
  and executed_at is null;

-- Example review query: reconstruct AI-assisted actions and their disposition.
select
    i.interaction_id,
    i.occurred_at,
    i.user_identity,
    i.recommendation,
    i.confidence_label,
    i.action_requested,
    a.action_type,
    a.target_name,
    a.status as approval_status,
    a.approved_by,
    a.executed_at,
    a.execution_result
from OI_LAB.AGENT_INTERACTION_AUDIT i
left join OI_LAB.ACTION_APPROVAL a
    on a.approval_id = i.approval_id
order by i.occurred_at desc;
