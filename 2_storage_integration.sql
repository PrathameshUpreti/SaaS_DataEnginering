USE ROLE ACCOUNTADMIN;

CREATE STORAGE INTEGRATION IF NOT EXISTS S3_SAAS_INTEGRATION
    TYPE = EXTERNAL_STAGE
    STORAGE_PROVIDER = 'S3'
    ENABLED = TRUE
    STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::396541281648:role/saas-datalakes'
    STORAGE_ALLOWED_LOCATIONS = (
        's3://saas-data-lakes/raw/users/',
        's3://saas-data-lakes/raw/subscriptions/',
        's3://saas-data-lakes/raw/payments/',
        's3://saas-data-lakes/raw/support_tickets/'
    );

DESC INTEGRATION S3_SAAS_INTEGRATION;


USE DATABASE SAAS_PROD;
USE SCHEMA RAW;


-- CREATING FILE FORMATS

CREATE FILE FORMAT IF NOT EXISTS CSV_STANDARD
    TYPE = 'CSV'
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    NULL_IF = ('', 'NULL', 'null', '\\N')
    EMPTY_FIELD_AS_NULL = TRUE
    TRIM_SPACE = TRUE
    ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
    COMMENT = 'Standard CSV with header row, double-quote enclosure';

CREATE FILE FORMAT IF NOT EXISTS CSV_NO_HEADER
    TYPE = 'CSV'
    FIELD_DELIMITER = ','
    SKIP_HEADER = 0
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    NULL_IF = ('', 'NULL', 'null', '\\N')
    EMPTY_FIELD_AS_NULL = TRUE
    TRIM_SPACE = TRUE
    COMMENT = 'CSV without header row';


-- GRANT INTEGRATION ACCESS TO LOADER_ROLE (must happen before LOADER_ROLE creates stages)

GRANT USAGE ON INTEGRATION S3_SAAS_INTEGRATION TO ROLE LOADER_ROLE;


-- CREATING STAGES 

--as LOADER_ROLE since it has CREATE STAGE on RAW from 1.sql

USE ROLE LOADER_ROLE;
USE WAREHOUSE LOADING_WH;
USE SCHEMA SAAS_PROD.RAW;

CREATE STAGE IF NOT EXISTS STG_USERS
    STORAGE_INTEGRATION = S3_SAAS_INTEGRATION
    URL = 's3://saas-data-lakes/raw/users/'
    FILE_FORMAT = CSV_STANDARD
    COMMENT = 'User account data from application DB exports';

CREATE STAGE IF NOT EXISTS STG_SUBSCRIPTIONS
    STORAGE_INTEGRATION = S3_SAAS_INTEGRATION
    URL = 's3://saas-data-lakes/raw/subscriptions/'
    FILE_FORMAT = CSV_STANDARD
    COMMENT = 'Subscription lifecycle data from billing system';

CREATE STAGE IF NOT EXISTS STG_PAYMENTS
    STORAGE_INTEGRATION = S3_SAAS_INTEGRATION
    URL = 's3://saas-data-lakes/raw/payments/'
    FILE_FORMAT = CSV_STANDARD
    COMMENT = 'Payment transactions from Stripe webhook exports';

CREATE STAGE IF NOT EXISTS STG_SUPPORT_TICKETS
    STORAGE_INTEGRATION = S3_SAAS_INTEGRATION
    URL = 's3://saas-data-lakes/raw/support_tickets/'
    FILE_FORMAT = CSV_STANDARD
    COMMENT = 'Support ticket data from helpdesk system';


LIST @STG_USERS;
LIST @STG_SUBSCRIPTIONS;
LIST @STG_PAYMENTS;
LIST @STG_SUPPORT_TICKETS;
