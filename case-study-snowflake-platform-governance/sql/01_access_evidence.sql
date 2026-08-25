-- Synthetic access-review pattern. Run with a purpose-built read-only role.
WITH active_role_grants AS (
    SELECT
        grantee_name AS role_name,
        granted_on AS object_type,
        privilege,
        granted_to,
        grant_option,
        created_on
    FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
    WHERE deleted_on IS NULL
), review_flags AS (
    SELECT
        role_name,
        object_type,
        privilege,
        granted_to,
        grant_option,
        created_on,
        CASE
            WHEN role_name IN ('ACCOUNTADMIN', 'SECURITYADMIN') THEN 'ADMIN_ROLE'
            WHEN grant_option = 'true' THEN 'CAN_DELEGATE'
            WHEN privilege IN ('OWNERSHIP', 'ALL PRIVILEGES') THEN 'BROAD_PRIVILEGE'
            ELSE 'STANDARD'
        END AS review_reason
    FROM active_role_grants
)
SELECT *
FROM review_flags
WHERE review_reason <> 'STANDARD'
ORDER BY review_reason, role_name, object_type, privilege;

