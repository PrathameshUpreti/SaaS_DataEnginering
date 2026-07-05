# 🚀 SaaS Data Engineering Platform

<p align="center">
  <strong>Production-style ELT pipeline built with Snowflake, dbt, AWS S3, Snowpipe, CDC, Data Quality Monitoring, Governance, and GitHub Actions CI/CD.</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Snowflake-Data%20Warehouse-29B5E8?logo=snowflake&logoColor=white" alt="Snowflake">
  <img src="https://img.shields.io/badge/dbt-Transformation-FF694B?logo=dbt&logoColor=white" alt="dbt">
  <img src="https://img.shields.io/badge/AWS%20S3-Data%20Lake-569A31?logo=amazons3&logoColor=white" alt="AWS S3">
  <img src="https://img.shields.io/badge/GitHub%20Actions-CI%2FCD-2088FF?logo=githubactions&logoColor=white" alt="GitHub Actions">
  <img src="https://img.shields.io/badge/Architecture-ELT-blueviolet" alt="ELT Architecture">
  <img src="https://img.shields.io/badge/Modeling-Star%20Schema-orange" alt="Star Schema">
</p>

<p align="center">
  <a href="#-architecture">Architecture</a> •
  <a href="#-data-flow">Data Flow</a> •
  <a href="#-key-features">Features</a> •
  <a href="#-data-modeling">Data Modeling</a> •
  <a href="#-data-quality">Data Quality</a> •
  <a href="#-cicd-pipeline">CI/CD</a> •
  <a href="#-project-structure">Project Structure</a> •
  <a href="#-getting-started">Getting Started</a>
</p>

---

## 📌 Project Overview

This project implements an end-to-end, production-style data engineering platform for a SaaS analytics use case.

The platform ingests operational data from multiple source domains into **AWS S3**, loads data into **Snowflake** using **Snowpipe auto-ingest**, processes incremental changes using **Streams and Tasks**, transforms data using **dbt**, applies automated data quality checks and governance policies, and serves analytics-ready dimensional models to downstream BI tools.

The project also implements an isolated-schema CI strategy using **GitHub Actions**, allowing pull requests to validate dbt models and tests without modifying production schemas.

### What This Project Demonstrates

* Event-driven ingestion using Snowpipe and SQS notifications
* Change Data Capture using Snowflake Streams
* Automated MERGE-based processing using Snowflake Tasks
* Layered dbt transformation architecture
* Incremental fact models
* Dimensional modeling
* SCD Type-2 history tracking using dbt snapshots
* Automated source freshness checks
* Generic, singular, and custom dbt tests
* Snowflake Data Metric Functions
* Role-Based Access Control
* Dynamic Data Masking
* Object Tagging
* Managed Access Schemas
* Resource monitoring and cost controls
* Pipeline failure notifications
* Development and production environment isolation
* Pull-request CI validation
* Automated dbt deployment using GitHub Actions

---

## 🏗 Architecture

```text
                               ┌──────────────────────┐
                               │   SaaS Applications  │
                               │                      │
                               │ Users                │
                               │ Subscriptions        │
                               │ Payments             │
                               │ Support Tickets      │
                               └───────────┬──────────┘
                                           │
                                           ▼
                               ┌──────────────────────┐
                               │        AWS S3        │
                               │                      │
                               │ CSV Landing Zone     │
                               └───────────┬──────────┘
                                           │
                                S3 Event Notifications
                                           │
                                           ▼
                                      ┌─────────┐
                                      │   SQS   │
                                      └────┬────┘
                                           │
                                           ▼
                               ┌──────────────────────┐
                               │      Snowpipe        │
                               │     Auto-Ingest      │
                               └───────────┬──────────┘
                                           │
                                           ▼
┌──────────────────────────────────────────────────────────────────────────┐
│                              SNOWFLAKE                                   │
│                                                                          │
│   ┌─────────────────┐                                                    │
│   │       RAW       │                                                    │
│   │                 │                                                    │
│   │ Users           │                                                    │
│   │ Subscriptions   │                                                    │
│   │ Payments        │                                                    │
│   │ Support Tickets │                                                    │
│   └────────┬────────┘                                                    │
│            │                                                             │
│            │ Streams                                                     │
│            ▼                                                             │
│   ┌─────────────────┐                                                    │
│   │   CDC STREAMS   │                                                    │
│   └────────┬────────┘                                                    │
│            │                                                             │
│            │ Scheduled Tasks + MERGE                                     │
│            ▼                                                             │
│   ┌─────────────────┐      ┌─────────────────────────────────────────    │
│   │     STAGING     │─────►│ Snowflake Data Metric Functions             │
│   │                 │      │                                             │
│   │ Deduplicated    │      │ NULL_COUNT                                  │
│   │ CDC Processed   │      │ DUPLICATE_COUNT                             │
│   │ Standardized    │      │ ROW_COUNT                                   │
│   └────────┬────────┘      └──────────────────────────────────────────   │
│            │                                                             │
│            │ dbt                                                         │
│            ▼                                                             │
│   ┌─────────────────┐                                                    │
│   │  INTERMEDIATE   │                                                    │
│   │                 │                                                    │
│   │ Cleaning        │                                                    │
│   │ Type Casting    │                                                    │
│   │ Business Logic  │                                                    │
│   │ Cross-Source    │                                                    │
│   │ Joins           │                                                    │
│   └────────┬────────┘                                                    │
│            │                                                             │
│            │ dbt                                                         │
│            ▼                                                             │
│   ┌─────────────────┐                                                    │
│   │      MARTS      │                                                    │
│   │                 │                                                    │
│   │ Dimensions      │                                                    │
│   │ Facts           │                                                    │
│   │ Incremental     │                                                    │
│   │ Models          │                                                    │
│   └────────┬────────┘                                                    │
│            │                                                             │
└────────────┼─────────────────────────────────────────────────────────────┘
             │
             ▼
   ┌───────────────────────┐
   │    BI / Analytics     │
   │                       │
   │      Power BI         │
   └───────────────────────┘
```

---

## 🔄 Data Flow

```mermaid
flowchart LR

    A[SaaS Source Systems] --> B[AWS S3]

    B -->|Event Notification| C[SQS]

    C --> D[Snowpipe Auto-Ingest]

    D --> E[RAW Tables]

    E --> F[Snowflake Streams]

    F --> G[Scheduled Tasks]

    G -->|MERGE + Deduplication| H[STAGING Tables]

    H --> I[Data Metric Functions]

    H --> J[dbt Intermediate Models]

    J --> K[dbt Marts]

    K --> L[Power BI / Analytics]

    M[GitHub Pull Request] --> N[GitHub Actions CI]

    N --> O[dbt Compile]

    O --> P[Isolated CI Schema]

    P --> Q[dbt Build + Tests]

    Q --> R[CI Schema Cleanup]

    S[Merge to Main] --> T[GitHub Actions CD]

    T --> U[Production dbt Build]

    U --> V[dbt Documentation Artifacts]
```

---

## 📥 Data Sources

| Source          | Business Domain             | Ingestion Strategy   |
| --------------- | --------------------------- | -------------------- |
| Users           | Customer account profiles   | Snowpipe Auto-Ingest |
| Subscriptions   | Subscription lifecycle      | Snowpipe Auto-Ingest |
| Payments        | Payment transactions        | Snowpipe Auto-Ingest |
| Support Tickets | Customer support operations | Snowpipe Auto-Ingest |

---

# ✨ Key Features

## 🔐 1. Role-Based Access Control

The project follows the **Principle of Least Privilege** using dedicated Snowflake roles for each workload.

| Role               | Responsibility                 | Access                                    |
| ------------------ | ------------------------------ | ----------------------------------------- |
| `LOADER_ROLE`      | Data ingestion service account | Write to RAW                              |
| `TRANSFORMER_ROLE` | dbt transformations            | Read STAGING and write INTERMEDIATE/MARTS |
| `BI_ROLE`          | BI service account             | Read MARTS                                |
| `ANALYST_ROLE`     | Business analysts              | Read INTERMEDIATE and MARTS               |
| `DEVELOPER_ROLE`   | Data engineers                 | Development environment access            |

This prevents service accounts and downstream consumers from receiving unnecessary database privileges.

---

## ☁️ 2. AWS S3 Storage Integration

Snowflake accesses S3 through a secure **Storage Integration** backed by an AWS IAM role.

### Implementation

* IAM role-based authentication
* No hardcoded AWS credentials
* Dedicated external stage for every source domain
* Centralized CSV file formats
* Null-value handling
* Load metadata tracking
* Fault-tolerant ingestion configuration

```text
S3
├── users/
├── subscriptions/
├── payments/
└── support_tickets/
```

---

## ❄️ 3. Event-Driven Ingestion with Snowpipe

Four Snowpipes automatically load files arriving in S3.

```text
PIPE_USERS
PIPE_SUBSCRIPTIONS
PIPE_PAYMENTS
PIPE_SUPPORT_TICKETS
```

### Ingestion Flow

```text
File Uploaded to S3
        │
        ▼
S3 Event Notification
        │
        ▼
       SQS
        │
        ▼
Snowpipe Auto-Ingest
        │
        ▼
     RAW Table
```

Snowpipe is configured with:

```text
AUTO_INGEST = TRUE
ON_ERROR = 'SKIP_FILE'
```

---

## 🔁 4. Change Data Capture

Snowflake Streams capture changes occurring in RAW tables.

### Stream Strategy

| Dataset         | Stream Type | Reason                                  |
| --------------- | ----------- | --------------------------------------- |
| Users           | Standard    | User records can change                 |
| Subscriptions   | Standard    | Subscription lifecycle updates          |
| Payments        | Append-Only | Payment transactions are immutable      |
| Support Tickets | Standard    | Ticket status and resolution can change |

Initial records are captured using:

```text
SHOW_INITIAL_ROWS = TRUE
```

---

## ⚙️ 5. Automated CDC Processing

Snowflake Tasks execute every five minutes.

Tasks only execute MERGE operations when their corresponding stream contains records.

```sql
WHEN SYSTEM$STREAM_HAS_DATA('STREAM_NAME')
```

The processing logic implements:

* Incremental stream consumption
* MERGE-based upserts
* Insert and update handling
* Deduplication
* Latest-record selection

### Deduplication Pattern

```sql
ROW_NUMBER() OVER (
    PARTITION BY BUSINESS_KEY
    ORDER BY LOADED_AT DESC
)
```

---

## 🧱 6. dbt Transformation Architecture

The dbt project uses layered data modeling.

```text
STAGING
    │
    ▼
INTERMEDIATE
    │
    ▼
MARTS
```

| Layer        | Materialization             | Responsibility                                            |
| ------------ | --------------------------- | --------------------------------------------------------- |
| STAGING      | Snowflake Tables            | CDC processing and deduplication                          |
| INTERMEDIATE | Views                       | Cleaning, type casting, joins and reusable business logic |
| MARTS        | Tables / Incremental Models | Analytics-ready dimensional models                        |

---

## 📊 Data Modeling

The MARTS layer implements dimensional modeling for analytical workloads.

### Dimensions

```text
DIM_USERS
DIM_PLAN
DIM_DATE
DIM_PAYMENT_METHOD
```

### Facts

```text
FACT_PAYMENTS
FACT_SUBSCRIPTION
FACT_SUPPORT_TICKET
```

### Simplified Star Schema

```mermaid
erDiagram

    DIM_USERS ||--o{ FACT_PAYMENTS : makes
    DIM_USERS ||--o{ FACT_SUBSCRIPTION : owns
    DIM_USERS ||--o{ FACT_SUPPORT_TICKET : creates

    DIM_PLAN ||--o{ FACT_SUBSCRIPTION : categorizes

    DIM_PAYMENT_METHOD ||--o{ FACT_PAYMENTS : classifies

    DIM_DATE ||--o{ FACT_PAYMENTS : payment_date
    DIM_DATE ||--o{ FACT_SUBSCRIPTION : subscription_date
    DIM_DATE ||--o{ FACT_SUPPORT_TICKET : created_date
```

---

## ⚡ 7. Incremental dbt Models

Large fact tables are processed incrementally.

Example configuration:

```text
materialized = incremental
incremental_strategy = merge
unique_key = business key
```

`FACT_PAYMENTS` uses incremental MERGE processing to avoid rebuilding the complete table during every dbt execution.

---

## 🕒 8. Source Freshness Monitoring

dbt source freshness is configured for RAW and STAGING datasets.

| Layer   | Warning Threshold | Error Threshold |
| ------- | ----------------- | --------------- |
| RAW     | 12 Hours          | 24 Hours        |
| STAGING | 1 Hour            | 6 Hours         |

Freshness checks help identify delayed ingestion and CDC processing.

---

## 🧪 Data Quality

The project implements multiple layers of automated data validation.

### dbt Generic Tests

```text
unique
not_null
accepted_values
relationships
```

### Custom Data Tests

```text
active_subscription_not_ended
no_future_signup_dates
no_orphan_payment
resolved_tickets_have_resolution_date
```

### Custom Generic Test

```text
test_is_non_negative
```

### Snowflake Data Metric Functions

Native Snowflake Data Metric Functions monitor STAGING datasets.

| Metric            | Purpose                        |
| ----------------- | ------------------------------ |
| `NULL_COUNT`      | Detect missing critical values |
| `DUPLICATE_COUNT` | Detect duplicate business keys |
| `ROW_COUNT`       | Monitor dataset volume         |

DMFs execute using change-triggered scheduling.

```text
TRIGGER_ON_CHANGES
```

---

## 📸 9. SCD Type-2 History Tracking

dbt snapshots preserve historical changes for mutable entities.

```text
SNAP_USERS
SNAP_SUBSCRIPTION
```

Snapshots maintain:

```text
DBT_VALID_FROM
DBT_VALID_TO
DBT_UPDATED_AT
```

This allows analytical queries to reconstruct historical entity states.

---

## 🛡️ 10. Data Governance

### Dynamic Data Masking

Sensitive customer information is protected using Snowflake masking policies.

Protected attributes include:

```text
EMAIL
PHONE
```

Unauthorized roles receive masked values while approved roles retain full access.

### Object Tagging

Objects are classified using Snowflake tags.

```text
COST_CENTER
PII_FLAG
DATA_DOMAIN
DATA_CLASSIFICATION
```

### Managed Access Schemas

All schemas use:

```sql
WITH MANAGED ACCESS
```

This centralizes privilege management under schema owners.

---

## 💰 11. Cost Management

Dedicated warehouses isolate workloads.

| Warehouse         | Workload            |
| ----------------- | ------------------- |
| `LOADING_WH`      | Data ingestion      |
| `TRANSFORMING_WH` | dbt transformations |
| `BI_WH`           | BI queries          |
| `DEV_WH`          | Development         |

### Resource Monitors

| Monitor             | Monthly Quota |
| ------------------- | ------------: |
| `LOADING_MONITOR`   |   100 Credits |
| `TRANSFORM_MONITOR` |   200 Credits |

Thresholds:

```text
75%  → Notification
90%  → Notification
100% → Warehouse Suspension
```

All warehouses use automatic suspension and resume settings.

---

## 🌍 12. Environment Strategy

The project separates development and production workloads.

### Production

```text
SAAS_PROD
```

* Production datasets
* 7-day Time Travel
* Restricted access
* Production dbt deployment target

### Development

```text
SAAS_DEV
```

* Engineering development environment
* Isolated compute resources
* Zero-copy cloned from production
* Safe model experimentation

### RAW Data Retention

```text
14 Days
```

This provides additional recovery protection for source data.

---

## 🚨 13. Monitoring and Notifications

Pipeline failures are monitored using Snowflake Alerts.

```text
ALERT_TASK_FAILURE
```

The alert periodically checks task execution history for failures.

```text
TASK_HISTORY
        │
        ▼
Failure Detected
        │
        ▼
Snowflake Alert
        │
        ▼
Email Notification
```

---

# 🔄 CI/CD Pipeline

The repository implements automated CI/CD using GitHub Actions.

## Pull Request Workflow

Every pull request executes:

```text
Pull Request
      │
      ▼
Install dbt Dependencies
      │
      ▼
dbt deps
      │
      ▼
dbt compile
      │
      ▼
Create Isolated CI Schema
      │
      ▼
dbt build
      │
      ▼
Run Tests
      │
      ▼
Drop CI Schema
```

Each pull request uses an isolated schema:

```text
CI_<PR_NUMBER>
```

Example:

```text
CI_42
```

This prevents CI workloads from modifying production tables.

The cleanup step executes even when dbt validation fails.

---

## Production Deployment Workflow

Merging code into the `main` branch triggers deployment.

```text
Merge to Main
      │
      ▼
GitHub Actions
      │
      ▼
Install Dependencies
      │
      ▼
dbt deps
      │
      ▼
dbt build
      │
      ▼
Production Models + Tests
      │
      ▼
dbt docs generate
      │
      ▼
Upload Documentation Artifact
```

---

## 🧰 Technology Stack

| Category             | Technology                     |
| -------------------- | ------------------------------ |
| Cloud Storage        | AWS S3                         |
| Cloud Data Warehouse | Snowflake                      |
| Event Notifications  | Amazon SQS                     |
| Continuous Ingestion | Snowpipe                       |
| Change Data Capture  | Snowflake Streams              |
| Orchestration        | Snowflake Tasks                |
| Transformation       | dbt                            |
| Data Modeling        | Dimensional Modeling           |
| Historical Tracking  | dbt Snapshots                  |
| Data Quality         | dbt Tests + Snowflake DMFs     |
| Governance           | Masking Policies + Object Tags |
| Access Control       | Snowflake RBAC                 |
| Cost Management      | Resource Monitors              |
| CI/CD                | GitHub Actions                 |
| Version Control      | GitHub                         |
| BI Consumption       | Power BI                       |

---

## 📁 Project Structure

```text
.
├── .github/
│   └── workflows/
│       └── ci.yml
│
├── 01_Setup_&_Role.sql
├── 02_storage_integration.sql
├── 03_raw_tables_and_snowpipe.sql
├── 04_streams_and_tasks.sql
├── 05_alert_and_notification.sql
│
├── SAAS_DBT/
│   ├── dbt_project.yml
│   ├── packages.yml
│   ├── profiles.yml
│   │
│   ├── models/
│   │   ├── source.yml
│   │   │
│   │   ├── intermediate/
│   │   │   ├── user_cleaned.sql
│   │   │   ├── payment_cleaned.sql
│   │   │   ├── subscription_cleaned.sql
│   │   │   ├── support_ticket_cleaned.sql
│   │   │   ├── user_payment.sql
│   │   │   └── user_subscription.sql
│   │   │
│   │   └── marts/
│   │       ├── dimensions/
│   │       │   ├── dim_users.sql
│   │       │   ├── dim_plan.sql
│   │       │   ├── dim_date.sql
│   │       │   └── dim_payment_method.sql
│   │       │
│   │       └── facts/
│   │           ├── fact_payments.sql
│   │           ├── fact_subscription.sql
│   │           └── fact_support_ticket.sql
│   │
│   ├── snapshots/
│   │   ├── snap_subscription.sql
│   │   └── snap_users.sql
│   │
│   ├── macros/
│   │   ├── generate_schema_name.sql
│   │   ├── drop_ci_schema.sql
│   │   └── test_is_non_negative.sql
│   │
│   └── tests/
│       ├── active_subscription_not_ended.sql
│       ├── no_future_signup_dates.sql
│       ├── no_orphan_payment.sql
│       └── resolved_tickets_have_resolution_date.sql
│
└── README.md
```

---

# 🚀 Getting Started

## Prerequisites

Before deploying the project, configure:

* Snowflake account
* AWS account
* S3 bucket
* AWS IAM role
* GitHub repository
* Python environment
* dbt-snowflake

---

## 1️⃣ Clone the Repository

```bash
git clone <repository-url>

cd <repository-name>
```

---

## 2️⃣ Configure Snowflake Infrastructure

Execute the SQL scripts in order:

```text
01_Setup_&_Role.sql

02_storage_integration.sql

03_raw_tables_and_snowpipe.sql

04_streams_and_tasks.sql

05_alert_and_notification.sql
```

Administrative infrastructure configuration should be performed using the appropriate Snowflake administrative role.

---

## 3️⃣ Configure AWS S3 Event Notifications

Retrieve the Snowpipe notification channel:

```sql
SHOW PIPES;
```

Configure the S3 bucket event notification using the generated SQS ARN.

The resulting ingestion architecture is:

```text
S3 Object Created
        │
        ▼
SQS Notification
        │
        ▼
Snowpipe
        │
        ▼
RAW Table
```

---

## 4️⃣ Install dbt Dependencies

```bash
dbt deps --project-dir SAAS_DBT
```

---

## 5️⃣ Validate the Project

```bash
dbt debug --project-dir SAAS_DBT
```

Compile the project:

```bash
dbt compile --project-dir SAAS_DBT
```

---

## 6️⃣ Build the Analytics Models

```bash
dbt build --project-dir SAAS_DBT
```

---

## 7️⃣ Configure GitHub Actions Secrets

Add the following repository secrets:

```text
SNOWFLAKE_ACCOUNT

SNOWFLAKE_USER

SNOWFLAKE_PASSWORD

SNOWFLAKE_ROLE

SNOWFLAKE_WAREHOUSE

SNOWFLAKE_DATABASE
```

For production environments, key-pair authentication or workload identity federation should be preferred over password-based authentication.

---

## 8️⃣ Test the CI Pipeline

Create a feature branch:

```bash
git checkout -b feature/add-new-model
```

Push the branch:

```bash
git add .

git commit -m "feat: add new dbt model"

git push origin feature/add-new-model
```

Open a Pull Request.

GitHub Actions will automatically:

```text
Compile dbt Project
        │
        ▼
Create Isolated CI Schema
        │
        ▼
Build Models
        │
        ▼
Execute Tests
        │
        ▼
Clean Up CI Resources
```

---

## 📈 Future Improvements

Potential extensions to the platform include:

* dbt Slim CI using state comparison and `state:modified+`
* Snowflake key-pair authentication for GitHub Actions
* GitHub OpenID Connect authentication
* Terraform-based Snowflake infrastructure provisioning
* Automated Snowflake RBAC validation
* Data contract enforcement
* Schema change detection
* Centralized observability dashboard
* Dead-letter processing for rejected source files
* Cost attribution dashboards using `ACCOUNT_USAGE`
* Power BI semantic model and executive dashboard
* Automated deployment approval gates
* Blue/green deployment strategy for critical dimensional models

---

## 🎯 Engineering Concepts Demonstrated

This project demonstrates practical experience with:

```text
Cloud Data Warehousing

Event-Driven Data Ingestion

ELT Pipeline Design

Change Data Capture

Incremental Data Processing

Idempotent MERGE Operations

Dimensional Data Modeling

Slowly Changing Dimensions

Data Quality Engineering

Data Governance

Role-Based Access Control

Data Security

Cost Optimization

Environment Isolation

CI/CD for Analytics Engineering

Automated Testing

Production Monitoring
```

---

## 📚 Lessons Learned

Building this project demonstrates several important data engineering principles:

1. **Ingestion, transformation, and serving workloads should be isolated.**

2. **CDC pipelines require deterministic deduplication and idempotent processing.**

3. **Data quality should be enforced at multiple layers rather than relying on a single testing mechanism.**

4. **Production transformations should be version controlled and automatically validated before deployment.**

5. **CI workloads should run in isolated environments to prevent accidental production modifications.**

6. **Security, governance, observability, and cost controls are part of pipeline architecture—not optional additions.**

---

## 👤 Author

**Prathamesh Upreti**

Data Engineering | Snowflake | dbt | AWS | SQL | Python

---

## ⭐ Support

If you found this project useful, consider giving the repository a ⭐.

Contributions, suggestions, and feedback are welcome.
