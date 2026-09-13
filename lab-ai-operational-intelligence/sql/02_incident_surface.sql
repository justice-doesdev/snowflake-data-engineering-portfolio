-- Governed incident surface for AI-assisted investigation.
-- The goal is a narrow, reviewable contract rather than arbitrary metadata access.

create or replace view OI_LAB.V_INCIDENT_CONTEXT as
with failures as (
    select
        run_id,
        task_name,
        domain_name,
        started_at,
        completed_at,
        status,
        error_code,
        error_message,
        parent_task_name,
        environment_name,
        owner_team
    from OI_LAB.TASK_RUN_SIGNAL
    where status = 'FAILED'
),
nearby_schema_changes as (
    select
        f.run_id,
        s.change_id,
        s.object_name,
        s.changed_at,
        s.change_type,
        s.column_name,
        datediff('minute', s.changed_at, f.started_at) as minutes_before_failure
    from failures f
    join OI_LAB.SCHEMA_CHANGE_SIGNAL s
      on s.environment_name = f.environment_name
     and s.changed_at between dateadd('hour', -4, f.started_at) and f.started_at
),
downstream_impact as (
    select
        parent_task_name as failed_or_skipped_parent,
        count_if(status = 'SKIPPED') as skipped_downstream_runs
    from OI_LAB.TASK_RUN_SIGNAL
    group by 1
)
select
    f.run_id,
    f.task_name,
    f.domain_name,
    f.started_at as failure_started_at,
    f.completed_at as failure_completed_at,
    f.error_code,
    f.error_message,
    f.parent_task_name,
    f.environment_name,
    f.owner_team,
    s.change_id as nearby_change_id,
    s.object_name as nearby_changed_object,
    s.changed_at as nearby_changed_at,
    s.change_type as nearby_change_type,
    s.column_name as nearby_changed_column,
    s.minutes_before_failure,
    coalesce(d.skipped_downstream_runs, 0) as skipped_downstream_runs
from failures f
left join nearby_schema_changes s
    on s.run_id = f.run_id
left join downstream_impact d
    on d.failed_or_skipped_parent = f.task_name;

-- Example read-only question the AI layer can answer from this contract:
-- Which failed production task had a nearby schema change, and how many
-- downstream runs were skipped?

select *
from OI_LAB.V_INCIDENT_CONTEXT
order by failure_started_at desc;
