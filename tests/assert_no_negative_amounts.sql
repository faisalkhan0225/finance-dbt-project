-- tests/assert_no_negative_amounts.sql

SELECT *
FROM {{ ref('fct_transactions') }}
WHERE amount < 0
-- Returns rows = negative amounts found = FAIL ❌