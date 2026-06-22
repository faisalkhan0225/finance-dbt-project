

{{ config(materialized='table') }}

WITH transactions AS (
    SELECT * FROM {{ ref('stg_transactions') }}
),

daily AS (
    SELECT
        transaction_date,
        COUNT(transaction_id)               AS daily_transaction_count,
        SUM(amount)                         AS daily_total_amount,
        SUM(
            CASE WHEN status = 'COMPLETED'
            THEN amount ELSE 0 END
        )                                   AS daily_completed_amount,
        SUM(
            CASE WHEN status = 'FAILED'
            THEN 1 ELSE 0 END
        )                                   AS daily_failed_count,
        AVG(amount)                         AS daily_avg_amount
    FROM transactions
    GROUP BY transaction_date
),

with_trends AS (
    SELECT
        transaction_date,
        daily_transaction_count,
        daily_total_amount,
        daily_completed_amount,
        daily_failed_count,
        daily_avg_amount,

        -- Previous day comparison
        LAG(daily_total_amount, 1) OVER (
            ORDER BY transaction_date
        )                                   AS prev_day_amount,

        -- Day over day change
        daily_total_amount - LAG(daily_total_amount, 1) OVER (
            ORDER BY transaction_date
        )                                   AS day_over_day_change,

        -- Day over day percentage change
        ROUND(
            (daily_total_amount - LAG(daily_total_amount, 1) OVER (
                ORDER BY transaction_date
            )) * 100.0
            / NULLIF(LAG(daily_total_amount, 1) OVER (
                ORDER BY transaction_date
            ), 0), 2
        )                                   AS day_over_day_pct_change,

        -- 3 day moving average
        AVG(daily_total_amount) OVER (
            ORDER BY transaction_date
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        )                                   AS moving_avg_3_days,

        -- Trend direction
        CASE
            WHEN daily_total_amount > LAG(daily_total_amount, 1) OVER (
                ORDER BY transaction_date
            ) THEN '📈 Up'
            WHEN daily_total_amount < LAG(daily_total_amount, 1) OVER (
                ORDER BY transaction_date
            ) THEN '📉 Down'
            ELSE '➡️ Flat'
        END                                 AS trend_direction

    FROM daily
)

SELECT * FROM with_trends
ORDER BY transaction_date