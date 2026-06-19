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

        -- flag completed transactions only
        CASE
            WHEN status = 'COMPLETED' THEN TRUE
            ELSE FALSE
        END                             AS is_completed,

        transaction_date,
        created_at
    FROM {{ ref('int_transactions_accounts') }}
),
currency as (
    Select * from {{ ref('Currency_rates') }}
)

select bc.*,
-- categorize transaction size
        CASE
            WHEN bc.AMOUNT_INR >= 1000000  THEN 'Large'
            WHEN bc.AMOUNT_INR >= 500000   THEN 'Medium'
            ELSE                         'Small'
        END                             AS transaction_size
 from (
SELECT 
b.*,
b.amount * c.exchange_rate_to_inr as AMOUNT_INR,
c.currency_name 
FROM base b
left join currency c 
     on b.currency = c.currency_code ) bc

{% if is_incremental() %}

    -- only pick up new transactions since last run
    WHERE created_at > (
        SELECT MAX(created_at) FROM {{ this }}
    )

{% endif %}