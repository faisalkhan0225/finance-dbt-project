-- models/marts/dim_accounts.sql

SELECT
    account_id,
    account_name,
    account_type,
    credit_limit,
    relationship_manager,
    dbt_valid_from          AS valid_from,
    dbt_valid_to            AS valid_to,

    CASE
        WHEN dbt_valid_to IS NULL THEN TRUE
        ELSE FALSE
    END                     AS is_current,

    DATEDIFF(
        day,
        dbt_valid_from,
        COALESCE(dbt_valid_to, CURRENT_DATE)
    )                       AS days_active

FROM {{ ref('accounts_snapshot') }}