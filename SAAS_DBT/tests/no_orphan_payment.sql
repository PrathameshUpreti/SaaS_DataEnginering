SELECT p.PAYMENT_ID
FROM {{ ref('payment_cleaned') }} p
LEFT JOIN {{ ref('subscription_cleaned') }} s
    ON p.SUBSCRIPTION_ID = s.SUBSCRIPTION_ID
WHERE s.SUBSCRIPTION_ID IS NULL