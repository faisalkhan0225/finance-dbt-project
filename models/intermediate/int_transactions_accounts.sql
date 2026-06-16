-- models/intermediate/int_transactions_accounts.sql

WITH transactions AS (
    SELECT * FROM {{ ref('stg_transactions') }}
),

accounts AS (
    SELECT * FROM {{ ref('stg_accounts') }}
),

joined AS (
    SELECT
        t.transaction_id,
        t.transaction_type,
        t.amount,
        t.currency,
        t.status,
        t.transaction_date,
        t.created_at,
        a.account_id,
        a.account_name,
        a.account_type,
        a.relationship_manager
    FROM transactions t
    LEFT JOIN accounts a
        ON t.account_id = a.account_id
)

SELECT * FROM joined