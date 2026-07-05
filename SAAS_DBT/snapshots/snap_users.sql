{% snapshot snap_users %}

{{
config(
        target_schema='STAGING',
        unique_key='USER_ID',
        strategy='timestamp',
        updated_at='UPDATED_AT'
)
}}

SELECT USER_ID,
EMAIL,
FIRST_NAME, LAST_NAME,
PHONE,
SIGNUP_DATE,
PLAN_TYPE,
STATUS,
COUNTRY,
LOADED_AT,
UPDATED_AT
FROM {{ source('staging', 'STG_USERS') }}

{% endsnapshot %}