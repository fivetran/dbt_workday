# dbt_workday v0.2.0
## 🚨 Breaking Changes 🚨
- Created a surrogate key `employee_id` in `workday__employee_overview` that combines `worker_id`, `position_id`, and `position_start_date`. This accounts for the edge cases where:
  - A worker can hold multiple positions concurrently.
  - A position being held by multiple workers concurrently.
  - A worker being rehired for the same position. 
- Using this surrogate key as our grain will hopefully provide uniqueness for the majority of Workday HCM customer cases. 

## 🚀 Feature Updates 🚀 
- We have added staging history mode models in the [`models/history`](https://github.com/fivetran/dbt_workday/tree/main/models/staging/history) folder [to support Fivetran's history mode feature](https://fivetran.com/docs/core-concepts/sync-modes/history-mode). 

This will allow customers to utilize the Fivetran history mode feature, which records every version of each record in the source table from the moment this mode is activated in the equivalent tables. 

These staging models include:

  - `stg_workday__personal_information_history`: Containing historical records of a worker's personal information.
  - `stg_workday__worker_history`: Containing historical records of a worker's history.
  - `stg_workday__worker_position_history`: Containing historical records of a worker's position history.
  - `stg_workday__worker_position_organization_history`: Containing historical records of a worker's position history.

- We have then utilized the `workday__employee_daily_history` model in the [`models/workday_history`](https://github.com/fivetran/dbt_workday/tree/main/models/workday_history) folder [based off of Fivetran's history mode feature](https://fivetran.com/docs/core-concepts/sync-modes/history-mode), pulling from Workday HCM source models you can view in the [`models/staging/workday_history`](https://github.com/fivetran/dbt_workday/tree/main/models/staging/workday_history) folder.

- These models are disabled by default due to their size, so you will need to set the below variable configurations for each of the individual models you want to utilize in your `dbt_project.yml`.

```yml
vars:
   employee_history_enabled: true  ##Ex: employee_history_enabled: true    
```

- We have also added the `workday__monthly_summary` model in the [`models/workday_history`](https://github.com/fivetran/dbt_workday/tree/main/models/workday_history) folder. This table aggregates high-level monthly metrics to track changes over time to overall employee data for a customer. 

- We have chosen not to implement incremental logic in the history models due to the future-facing updating of Workday HCM transactions beyond current daily updates. [See the DECISIONLOG](https://github.com/fivetran/dbt_workday/blob/main/DECISIONLOG.md) for more details.

- We support the option to pull from both your Workday HCM and History Mode connectors simultaneously from their specific database/schemas.  We also support pulling from just your History Mode connector on its own and bypassing the standard connector on its own. [See more detailed instructions in the README](https://github.com/fivetran/dbt_workday/blob/main/README.md#configuring-your-workday-history-mode-database-and-schema-variables). 

- Workday HCM History Mode models can contain a multitude of rows if you bring in all historical data, so we've introduced the flexibility to set first date filters to bring in only the historical data you need. [More details can be found in the README](https://github.com/fivetran/dbt_workday/blob/main/README.md#filter-your-workday-hcm-history-mode-models).

# dbt_workday v0.1.1

[PR #4](https://github.com/fivetran/dbt_workday/pull/4) contains the following updates:
## Bug Fixes
- Updates the filtering done in the history staging models to pull the correct active statuses. Since some changes are entered but not yet effective, we needed to replace the `_fivetran_active` filter to where current timestamp is between `_fivetran_start` and `_fivetran_end` times for each record.

## Under the Hood
- Switched from using `dbt.current_timestamp_backcompat()` to `dbt.current_timestamp()` since the former has since been deprecated and was just previously used to ensure Snowflake and Postgres compatibility. 

# dbt_workday v0.1.0

## 🎉 Initial Release 🎉
This is the initial release of this package!

## 📣 What does this dbt package do?
This package models Workday HCM data from [Fivetran's connector](https://fivetran.com/docs/applications/workday-hcm).  

The main focus of the Workday HCM package is to transform the core object tables into analytics-ready models:

<!--section="workday_model"-->
- Materializes [Workday HCM staging tables](https://fivetran.github.io/dbt_workday/#!/overview/workday/models/?g_v=1) which leverage data in the format described by [this ERD](https://fivetran.com/docs/applications/workday-hcm/#schemainformation). 
- The staging tables clean, test, and prepare your Workday HCM data from [Fivetran's connector](https://fivetran.com/docs/applications/workday-hcm) for analysis by doing the following:
  - Primary keys are renamed from `id` to `<table name>_id`. 
  - Adds column-level testing where applicable. For example, all primary keys are tested for uniqueness and non-null values.
  - Provides insight into your Workday HCM data by creating the final end models for further transformation and analysis:
  
| **model**                 | **description**                                                                                                    |
| ------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| [workday__employee_overview](https://fivetran.github.io/dbt_workday/#!/model/model.workday.workday__employee_overview)  | Each record represents an employee with enriched personal information and the positions they hold. This helps measure employee demographic and geographical distribution, overall retention and turnover, and compensation analysis of their employees. |
| [workday__job_overview](https://fivetran.github.io/dbt_workday/#!/model/model.workday.workday__job_overview)  | Each record represents a job with enriched details on job profiles and job families. This allows users to understand recruitment patterns and details within a job and job groupings. |
| [workday__organization_overview](https://fivetran.github.io/dbt_workday/#!/model/model.workday.workday__organization_overview) |  Each record represents organization, organization roles, as well as positions and workers tied to these organizations. This allows end users to slice organizational data at any grain to better analyze organizational structures.  |
| [workday__position_overview](https://fivetran.github.io/dbt_workday/#!/model/model.workday.workday__position_overview) | Each record represents a position with enriched data on positions. This allows end users to understand position availabilities, vacancies, cost to optimize hiring efforts. |

  - Generates a comprehensive data dictionary of your Workday HCM data through the [dbt docs site](https://fivetran.github.io/dbt_workday/).