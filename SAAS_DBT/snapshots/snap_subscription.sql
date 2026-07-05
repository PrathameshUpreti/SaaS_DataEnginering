{% snapshot snap_subscription %}

{{
config(
        target_schema='STAGING',
        unique_key='SUBSCRIPTION_ID',
        strategy='timestamp',
        updated_at='UPDATED_AT'
)
}}

SELECT SUBSCRIPTION_ID,
USER_ID,
PLAN_NAME,
PLAN_TIER,
MONTHLY_PRICE,
START_DATE, END_DATE,
STATUS,
BILLING_CYCLE,
LOADED_AT,
UPDATED_AT

FROM {{ source('staging', 'STG_SUBSCRIPTIONS') }}

{% endsnapshot %}