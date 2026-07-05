{{ config(materialized='view') }}

SELECT p.PAYMENT_ID,
p.USER_ID, p.SUBSCRIPTION_ID,
p.AMOUNT,
p.CURRENCY,
p.PAYMENT_METHOD,
p.PAYMENT_STATUS,
p.TRANSACTION_DATE,
p.FAILURE_REASON,
u.EMAIL,
u.COUNTRY,
u.STATUS AS USER_STATUS,
s.PLAN_NAME,
s.PLAN_TIER,
s.BILLING_CYCLE

FROM {{ ref('payment_cleaned') }} p
LEFT JOIN {{ ref('user_cleaned') }} u
    ON p.USER_ID = u.USER_ID
LEFT JOIN {{ ref('subscription_cleaned') }} s
    ON p.SUBSCRIPTION_ID = s.SUBSCRIPTION_ID
