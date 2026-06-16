-- models/intermediate/int_transactions_accounts.sql

WITH transactions AS (
    SELECT * FROM {{ ref('stg_transactions') }}
),

accounts AS (
    SELECT * FROM {{ ref('stg_accounts') }}
)

SELECT
    t.transaction_id,
    t.amount,
    a.account_name
FROM transactions t
LEFT JOIN accounts a
    ON t.account_id = a.account_id