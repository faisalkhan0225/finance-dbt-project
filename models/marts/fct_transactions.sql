-- models/marts/fct_transactions.sql

{{
    config(
        materialized         = 'incremental',
        unique_key           = 'transaction_id',
        incremental_strategy = 'merge',
        on_schema_change     = 'sync_all_columns'
    )
}}

WITH base AS (
    SELECT
        transaction_id,
        account_id,
        account_name,
        account_type,
        relationship_manager,
        transaction_type,
        amount,
        currency,
        status,

        -- categorize transaction size
        CASE
            WHEN amount >= 1000000  THEN 'Large'
            WHEN amount >= 500000   THEN 'Medium'
            ELSE                         'Small'
        END                             AS transaction_size,

        -- flag completed transactions only
        CASE
            WHEN status = 'COMPLETED' THEN TRUE
            ELSE FALSE
        END                             AS is_completed,

        transaction_date,
        created_at
    FROM {{ ref('int_transactions_accounts') }}
)

SELECT * FROM base

{% if is_incremental() %}

    -- only pick up new transactions since last run
    WHERE created_at > (
        SELECT MAX(created_at) FROM {{ this }}
    )

{% endif %}