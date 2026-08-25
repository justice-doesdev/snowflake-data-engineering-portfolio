-- Synthetic task-fleet monitoring pattern. Use a purpose-built read-only role.
WITH current_tasks AS (
    SELECT
        task_database,
        task_schema,
        task_name,
        task_owner,
        state AS lifecycle_state,
        warehouse,
        ARRAY_SIZE(predecessors) AS predecessor_count,
        condition IS NOT NULL AS has_condition,
        error_integration IS NOT NULL AS has_error_routing,
        last_altered
    FROM SNOWFLAKE.ACCOUNT_USAGE.TASKS
    WHERE deleted IS NULL
), recent_runs AS (
    SELECT
        database_name AS task_database,
        schema_name AS task_schema,
        name AS task_name,
        state AS run_state,
        scheduled_time,
        completed_time,
        ROW_NUMBER() OVER (
            PARTITION BY database_name, schema_name, name
            ORDER BY scheduled_time DESC
        ) AS run_rank
    FROM SNOWFLAKE.ACCOUNT_USAGE.TASK_HISTORY
    WHERE scheduled_time >= DATEADD(day, -7, CURRENT_TIMESTAMP())
), latest_run AS (
    SELECT *
    FROM recent_runs
    WHERE run_rank = 1
),
scored AS (
    SELECT
        tasks.task_database,
        tasks.task_schema,
        tasks.task_name,
        tasks.task_owner,
        tasks.lifecycle_state,
        IFF(tasks.warehouse IS NULL, 'SERVERLESS', 'WAREHOUSE_BACKED') AS compute_model,
        tasks.predecessor_count,
        tasks.has_condition,
        tasks.has_error_routing,
        runs.run_state AS latest_run_state,
        runs.scheduled_time AS latest_scheduled_time,
        CASE
            WHEN tasks.lifecycle_state = 'suspended' THEN 'REVIEW_SUSPENSION'
            WHEN runs.run_state IN ('FAILED', 'FAILED_AND_AUTO_SUSPENDED') THEN 'TRIAGE_FAILURE'
            WHEN runs.run_state = 'SKIPPED' THEN 'VERIFY_SKIP_REASON'
            WHEN NOT tasks.has_error_routing THEN 'ADD_ERROR_ROUTING'
            ELSE 'HEALTHY'
        END AS review_action
    FROM current_tasks AS tasks
    LEFT JOIN latest_run AS runs
        ON tasks.task_database = runs.task_database
       AND tasks.task_schema = runs.task_schema
       AND tasks.task_name = runs.task_name
)
SELECT *
FROM scored
WHERE review_action <> 'HEALTHY'
ORDER BY review_action, task_database, task_schema, task_name;
