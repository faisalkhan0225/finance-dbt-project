-- models/staging/stg_accounts.sql

SELECT
    account_id,
    INITCAP(account_name)       AS account_name,
    UPPER(account_type)         AS account_type,
    credit_limit,
    relationship_manager,
    updated_at
FROM {{ source('raw', 'accounts') }}