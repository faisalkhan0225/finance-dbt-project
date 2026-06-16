-- models/staging/stg_accounts.sql

SELECT
    account_id,
    account_name,
    account_type,
    credit_limit,
    relationship_manager,
    updated_at
FROM {{ source('raw', 'accounts') }}