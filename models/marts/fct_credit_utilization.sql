{{ config(materialized='table') }}

WITH transactions AS (
    SELECT * FROM {{ ref('stg_transactions') }}
),
accounts AS (
    SELECT * FROM {{ ref('stg_accounts') }} 
),

 currency AS (   
    select * from {{ ref('Currency_rates') }} 
),
transactions_new AS(
    SELECT a.*,a.amount * b.exchange_rate_to_inr as Amount_inr FROM transactions a
    left join currency b on a.currency=b.currency_code
),

utilization AS (
    SELECT
        a.account_id,
        a.account_name,
        a.account_type,
        a.credit_limit,
        a.relationship_manager,

        -- Total spending (DEBIT only)
        SUM(
            CASE WHEN t.transaction_type = 'DEBIT'
            AND t.status = 'COMPLETED'
            THEN t.Amount_inr ELSE 0 END
        )                                   AS total_debit_amount,

        -- Credit utilization percentage
        ROUND(
            SUM(
                CASE WHEN t.transaction_type = 'DEBIT'
                AND t.status = 'COMPLETED'
                THEN t.Amount_inr ELSE 0 END
            ) * 100.0
            / NULLIF(a.credit_limit, 0), 2
        )                                   AS utilization_pct,

        -- Remaining credit
        a.credit_limit - SUM(
            CASE WHEN t.transaction_type = 'DEBIT'
            AND t.status = 'COMPLETED'
            THEN t.Amount_inr ELSE 0 END
        )                                   AS remaining_credit,

        -- Risk classification
        CASE
            WHEN utilization_pct >= 90 THEN '🔴 Critical'
            WHEN utilization_pct >= 75 THEN '🟠 High'
            WHEN utilization_pct >= 50 THEN '🟡 Medium'
            ELSE                            '🟢 Low'
        END                                 AS risk_level

    FROM accounts a
    LEFT JOIN transactions_new t
        ON a.account_id = t.account_id
    GROUP BY
        a.account_id,
        a.account_name,
        a.account_type,
        a.credit_limit,
        a.relationship_manager
)

SELECT * FROM utilization
ORDER BY utilization_pct DESC