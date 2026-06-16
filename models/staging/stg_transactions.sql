-- models/staging/stg_transactions.sql

SELECT
    transaction_id,
    account_id,
    UPPER(transaction_type)     AS transaction_type,
    amount,
    UPPER(currency)             AS currency,
    UPPER(status)               AS status,
    transaction_date,
    created_at
FROM {{ source('raw', 'transactions') }}
WHERE amount > 0               -- filter invalid records