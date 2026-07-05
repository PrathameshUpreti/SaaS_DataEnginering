{{
config(
        materialized='incremental',
        unique_key='PAYMENT_ID',
        incremental_strategy='merge'
    )
}}

WITH payments AS (
SELECT * FROM {{ ref('payment_cleaned') }}
{% if is_incremental() %}
    WHERE LOADED_AT > (SELECT MAX(LOADED_AT) FROM {{ this }})
{% endif %}
)

SELECT  PAYMENT_ID,
USER_ID, SUBSCRIPTION_ID,
AMOUNT,
CURRENCY,
PAYMENT_METHOD,
PAYMENT_STATUS,
TRANSACTION_DATE,
TRANSACTION_DATE::DATE AS TRANSACTION_DATE_KEY,
FAILURE_REASON,
CASE
WHEN PAYMENT_STATUS = 'SUCCESS' THEN AMOUNT 
ELSE 0 
END AS REVENUE_AMOUNT,
LOADED_AT
FROM payments
