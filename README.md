## Setup

1. Download Docker Desktop (if you don’t have installed) using the official website, install and launch.
2. Fork this Github project to you Github account. Clone the forked repo to your device.
3. Open your Command Prompt or Terminal, navigate to that folder, and run the command `docker compose up`.
4. Now you have launched a local Postgres database with the following credentials:
 ```
    Host: localhost
    User: admin
    Password: admin
    Port: 5432 
```
5. Connect to the db via a preferred tool (e.g. DataGrip, Dbeaver etc)
6. Install dbt-core and dbt-postgres using pip (if you don’t have) on your preferred environment.
7. Now you can run `dbt run` with the test model and check public_pipedrive_analytics schema to see the dbt result (with one test model)

## Project
1. Remove the test model once you make sure it works
2. Dive deep into the Pipedrive CRM source data to gain a thorough understanding of all its details. (You may also research the Pipedrive CRM tool terms).
3. Define DBT sources and build the necessary layers organizing the data flow for optimal relevance and maintainability.
4. Build a reporting model (rep_sales_funnel_monthly) with monthly intervals, incorporating the following funnel steps (KPIs):  
  &nbsp;&nbsp;&nbsp;Step 1: Lead Generation  
  &nbsp;&nbsp;&nbsp;Step 2: Qualified Lead  
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Step 2.1: Sales Call 1  
  &nbsp;&nbsp;&nbsp;Step 3: Needs Assessment  
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Step 3.1: Sales Call 2  
  &nbsp;&nbsp;&nbsp;Step 4: Proposal/Quote Preparation  
  &nbsp;&nbsp;&nbsp;Step 5: Negotiation  
  &nbsp;&nbsp;&nbsp;Step 6: Closing  
  &nbsp;&nbsp;&nbsp;Step 7: Implementation/Onboarding  
  &nbsp;&nbsp;&nbsp;Step 8: Follow-up/Customer Success  
  &nbsp;&nbsp;&nbsp;Step 9: Renewal/Expansion
5. Column names of the reporting model: `month`, `kpi_name`, `funnel_step`, `deals_count`
6. “Git commit” all the changes and create a PR to your forked repo (not the original one). Send your repo link to us.



### Data model overview ###
### Author: Ayushi Dani ###

### Architecture:

The project follows a 3 layered architecture:
1. Staging Layer - standardization of raw data 
2. Intermediate Layer - based on business logic
3. Mart - final reporting model based on requirements

### Models

1. Staging models:
  - stg_activity_types - lookup for activity types
  - stg_activity - activity events from pipedrive
  - stg_deal_changes - deal change events, as the main fact table
  - stg_stages - sales funnel stage definitions, lookup for stage id
  - stg_users - user data, lookup for user id

2. Intermediate models
  - init_deal_stage_events - extracts stage entry events from deal changes
  - init_deal_stage_enriched - extension of init_deal_stage_events with stage names

3. Reporting model
  - rep_sales_funnel_monthly - monthly sales funnel report 

### Data quality assumptions
  - All 'new value' entries in 'deal_changes' table for stage_id changes are valid intergers and can be cast to int
  - All 'stage_id' from 'deal_changes' table are present in 'stages' table

### Business Logic Assumptions
  - Deal counting - the report counts the distinct deals that entered each funnel step per month. 
  - Activity stages
    Sales Call 1 (step 2.1) counts only if the deal is in "Qualified Lead" stage at the time of the activity.
    Sales Call 2 (step 3.1) counts only if the deal is in "Needs Assessment" stage at the time of the activity.
    This enforces hierarchical relationship between the given steps and activities as required for the reporting model
  - Stage based steps - derived from 'deal_changes' table, based on when the stage_id for any deal changes
  - Activity based steps - derived from 'activity' table 
  - Time Aggregation - Monthly aggregation is based on change timestamps for an activity or a deal from 'change_time' and 'due_to' columns respectively in the 'deal_changes' and 'activity' tables
  - Multiple entries - if a deal enters the same stage multiple times in a month, it is counted only once

### Known Limitations & scope for future improvement
  - Data in raw tables is assumed to be clean for now, but it can be checked for consistent values types based on established terminology from the business. For example, stage id in raw data can only be between 1-9
  - The 'fields' table was not modeled as its structure and business requirement required further analysis. However, stg_users was staged because the purpose it can serve is clear
  - Intermediate tables are created solely for the required report at this stage but can are designed to be reusable for further analysis

## Usage

### Running the Models

#### Prerequisites
- Docker container running (from Setup step 3)
- dbt-core and dbt-postgres installed (from Setup step 6)

#### Run All Models
dbt run

All models are materialised in public_pipedrive_analytics schema
