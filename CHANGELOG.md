# dbt_workday v0.8.1

[PR #26](https://github.com/fivetran/dbt_workday/pull/26) includes the following updates:

## Test Fixes
- Removes duplicate column definitions in YAML schema files to avoid `dbt parse` warnings.

# Contributors
- [@dhawkins1234](https://github.com/dhawkins1234) ([PR #25](https://github.com/fivetran/dbt_workday/pull/25))

# dbt_workday v0.8.0

[PR #20](https://github.com/fivetran/dbt_workday/pull/20) includes the following updates:

## Documentation
- Updates README with standardized Fivetran formatting.

## Under the Hood
- In the `quickstart.yml` file:
  - Adds `table_variables` for relevant sources to prevent missing sources from blocking downstream Quickstart models.

# dbt_workday v0.7.0
[PR #19](https://github.com/fivetran/dbt_workday/pull/19) includes the following updates:

## Schema and Data Changes
**10 total changes • 0 possible breaking changes**

| Data Model(s) | Change type | Old | New | Notes |
| ---------- | ----------- | -------- | -------- | ----- |
| `workday__employee_overview` | Field added | N/A | `fivetran_id` | Added Fivetran composite key field to enable advanced joins with new schema updates. Field is null for legacy schema connections. |
| `stg_workday__personal_information_common_data` | New model | N/A | New staging model | New staging model for [January 2026 Workday personal information schema update](https://fivetran.com/docs/connectors/applications/workday-hcm/changelog#january2026) containing personal information fields including date and city of birth, nationality and blood type. |
| `stg_workday__country_personal_information` | New model | N/A | New staging model | New staging model for [January 2026 Workday personal information schema update](https://fivetran.com/docs/connectors/applications/workday-hcm/changelog#january2026) containing country-specific personal information fields including gender and marital status. |
| `stg_workday__military_service` | Join key changed | `worker_id` sourced from `personal_info_system_id` | `worker_id` sourced from `personal_info_common_id` | Model now uses [updated `military_service` schema](https://fivetran.com/docs/connectors/applications/workday-hcm/changelog#january2026). Automatically uses `military_service_incoming` table if available for existing Fivetran connections, otherwise uses `military_service` table for new connections after January 5, 2026. |
| `stg_workday__military_service` | New columns | N/A | `discharge_type`, `status_id` | New fields available in updated schema. |
| `stg_workday__military_service` | Null legacy columns | `service_type`, `military_status`, `index` |  `service_type`, `military_status`, `index`  cast to null | Legacy fields cast to null for backward compatibility with updated schema. |
| `stg_workday__personal_information_ethnicity` | Join key changed | `worker_id` sourced from `personal_info_system_id` | `worker_id` sourced from `country_personal_information_id` | Model now uses [updated `personal_information_ethnicity` schema](https://fivetran.com/docs/connectors/applications/workday-hcm/changelog#january2026). Automatically uses `personal_information_ethnicity_incoming` table if available for existing Fivetran connections, otherwise uses `personal_information_ethnicity` table for new connections after January 5, 2026. |
| `stg_workday__personal_information_ethnicity` | Null legacy column | `index` | `index` cast to null | Legacy field cast to null for backward compatibility with updated schema. |

**Note**: These staging models are ephemeral and will not be present in the warehouse, but we felt it important to document these updates to capture the full depth of changes. 

## Feature Updates
- Adds automatic table detection to support the newest version of the Workday API schema updates for new and existing Fivetran customers. [Details in the Fivetran release notes](https://fivetran.com/docs/connectors/applications/workday-hcm/changelog#january2026):
  - `stg_workday__military_service` automatically detects and uses `military_service_incoming` table for existing customers if available, otherwise uses `military_service` table for new customers. 
  - `stg_workday__personal_information_ethnicity` automatically detects and uses `personal_information_ethnicity_incoming` for existing customers table if available, otherwise uses `personal_information_ethnicity` table. 
  - All models maintain backward compatibility by setting legacy fields to `null`.
- Added variables to enable table detection support. These variables are `true` by default to support existing customers, who will have the `*_incoming` tables available.
  - `workday__using_military_service_incoming` 
  - `workday__using_personal_information_ethnicity_incoming`
- If you're a new customer who set up a Workday HCM Fivetran connection after January 5, you should set these variables to `false`. See the [README](https://github.com/fivetran/dbt_workday/blob/main/README.md#optional-workday-schema-migration-configuration) for more details.
- Additionally, if customers need to leverage the old `personal_information` schema, they can set the below variable to `false` in the `dbt_project.yml`:
  - `workday__using_personal_info_v2_schema`

## Documentation
- Updates [DECISIONLOG](https://github.com/fivetran/dbt_workday/blob/main/DECISIONLOG.md) with rationale for why we are not supporting the legacy schema. 

## Quickstart Updates
- Adds table variables to support the above automatic table switching feature. **Note:** These will be removed after the transition period when table switching is no longer needed.

## Under the Hood
- Adds `does_table_exist` macro to dynamically detect table availability for automatic schema migration. Updates base models (`stg_workday__military_service_base`, `stg_workday__personal_information_ethnicity_base`) to use `*_incoming` table when available via automatic detection.
- Updates `int_workday__personal_details` to automatically detect and use new split personal information tables when both are available.
- Updates `src_workday.yml` with source definitions for new tables: `personal_information_common_data`, `country_personal_information`, plus `_legacy` variants for old schemas that will be deprecated after April. 
- Adds 4 integration test seed files for the new Workday personal information schema; renames seed files to keep reference to old `military_service `and `personal_information_ethnicity` schema; will deprecate after full transition to new tables in April 2026: `workday_military_service_legacy_data`, `workday_personal_information_ethnicity_legacy_data`.
- Adds consistency tests for remaining Workday models.
- Updates seed files to ensure proper validation of data downstream in `workday__employee_overview`.

# dbt_workday v0.6.0
[PR #17](https://github.com/fivetran/dbt_workday/pull/17) includes the following updates:

## Features
- Increases the required dbt version upper limit to v3.0.0.

# dbt_workday v0.5.0
[PR #15](https://github.com/fivetran/dbt_workday/pull/15) includes the following updates:

### dbt Fusion Compatibility Updates
- Updated package to maintain compatibility with dbt-core versions both before and after v1.10.6, which introduced a breaking change to multi-argument test syntax (e.g., `unique_combination_of_columns`).
- Temporarily removed unsupported tests to avoid errors and ensure smoother upgrades across different dbt-core versions. These tests will be reintroduced once a safe migration path is available.
  - Removed all `dbt_utils.unique_combination_of_columns` tests.

## Under the Hood
- Updated conditions in `.github/workflows/auto-release.yml`.
- Added `.github/workflows/generate-docs.yml`.

# dbt_workday v0.4.0

## Schema Changes and Bug Fixes
[PR #12](https://github.com/fivetran/dbt_workday/pull/12) contains the following updates:

**2 total changes • 1 possible breaking change** 

| Data Model                                    | Change Type | Old Name | New Name                                  | Notes                                                             |
|---------------------------------------------------|-------------|----------|-------------------------------------------|-------------------------------------------------------------------|
| [workday__employee_overview](https://fivetran.github.io/dbt_workday/#!/model/model.workday.workday__employee_overview)        | New Field   | `first_name ` | `compensation_grade_profile_id` |  Fixed a bug where `compensation_grade_profile_id` was incorrectly selected and aliased as `first_name`. This update introduces `compensation_grade_profile_id` as a distinct field. This results in a schema change. |
| [workday__employee_overview](https://fivetran.github.io/dbt_workday/#!/model/model.workday.workday__employee_overview)        | Corrected Field   | `first_name ` | `first_name` |  Resolved an issue where `first_name` was incorrectly displaying the `compensation_grade_profile_id` value. The field now returns the correct `first_name`. |

## Documentation
- Added Quickstart model counts to README. ([#10](https://github.com/fivetran/dbt_workday/pull/10))
- Corrected references to connectors and connections in the README. ([#10](https://github.com/fivetran/dbt_workday/pull/10))

## Under the Hood
- Introduced consistency test for `workday__employee_overview` end model.
- Updated seed data to ensure proper test results.

# dbt_workday v0.3.0
[PR #8](https://github.com/fivetran/dbt_workday/pull/8) includes the following changes:

  ## Breaking Changes
  - Updated the `workday__monthly_summary` model to segment out inactive employees within the monthly employee and worker active metrics.
    - The model now utilizes the `is_active` field to filter employees who are active at the end of a month, which are further filtered into active employee and worker metrics, particularly all `active_*` and `avg_*` fields. 
    - This new logic accounts for employees that move between active and inactive states while still being employed, so `avg_days_as_employee` and `avg_days_as_worker` are properly calculated.
    - Removed existing conditions for active metrics as they only handled a subset of employee/worker cases, whereas `is_active` appears to provide more comprehensive coverage.
  - As these changes will significantly impact the metrics in the monthly summary model, these are defined as **breaking changes**. 

  ## Under The Hood
  - Added consistency and integrity tests within integration tests for `workday__monthly_summary` and `workday__employee_daily_history` to ensure proper validation of model changes. 
  - Added `employee_history_enabled: true` variable to `integration_tests/dbt_project.yml` for testing history model changes and generating docs.

# dbt_workday v0.2.0
Lots of major updates! [PR #5](https://github.com/fivetran/dbt_workday/pull/5) includes the following changes:

## 🚨 Breaking Changes 🚨
- We are now materializing staging models as ephemeral rather than views, as they are mostly redundant with the source tables and are primarily designed for preparing models for final transformation. Previous staging views will no longer be used and will be considered stale.

## 🔑 New Primary Key 🔑 
- Created a surrogate key `employee_id` in `workday__employee_overview` that combines `worker_id`, `source_relation`, `position_id`, and `position_start_date`. This accounts for edge cases like when:
  - A worker can hold multiple positions concurrently.
  - A position being held by multiple workers concurrently.
  - A worker being rehired for the same position.

## 🚀 Feature Updates 🚀 
- We have added three end models in the [`models/workday_history`](https://github.com/fivetran/dbt_workday/tree/main/models/workday_history) folder [thanks to support from Fivetran's history mode feature](https://fivetran.com/docs/core-concepts/sync-modes/history-mode). These models provide historical daily data looks into crucial worker/employee Workday models, as well as allowing users to assess monthly summary metrics. These end models include:

  - `workday__employee_daily_history`: Each record is a daily record in an employee, starting with its first active date and updating up toward either the current date (if still active) or its last active date. This will allow customers to track the daily history of their employees from when they started.

  - `workday__monthly_summary`: Each record is a month, aggregated from the last day of each month of the employee daily history. This captures monthly metrics of workers, such as average salary, churned and retained employees, etc.

  - `workday_worker_position_org_daily_history`: Each record is a daily record for a worker/position/organization combination, starting with its first active date and updating up toward either the current date (if still active) or its last active date. This will allow customers to tie in organizations to employees via other organization models (such as `workday__organization_overview`) more easily in their warehouses.

- We have added staging history mode models in the [`models/workday_history/staging`](https://github.com/fivetran/dbt_workday/tree/main/models/workday_history/staging) folder.  This allows customers to utilize the Fivetran history mode feature, which records every version of each record in the source table from the moment this mode is activated in the equivalent tables. 

- These staging models include:

  - `stg_workday__personal_information_history`: Containing historical records of a worker's personal information.
  - `stg_workday__worker_history`: Containing historical records of a worker's history.
  - `stg_workday__worker_position_history`: Containing historical records of a worker's position history.
  - `stg_workday__worker_position_organization_history`: Containing historical records of a worker's position and organization history.

- We have then utilized the `workday__employee_daily_history` model in the [`models/workday_history`](https://github.com/fivetran/dbt_workday/tree/main/models/workday_history) folder [based off of Fivetran's history mode feature](https://fivetran.com/docs/core-concepts/sync-modes/history-mode), pulling from Workday HCM source models you can view in the [`models/workday_history/staging`](https://github.com/fivetran/dbt_workday/tree/main/models/workday_history/staging) folder.

- We have kept the `stg_workday__worker_position_organization_history` model separate, as organizational data is too flexible in Workday to effectively join in the majority of data. We leave it to the customer to use their best judgement in joining this data into other end models in their own warehouse. [See the DECISIONLOG for more details](https://github.com/fivetran/dbt_workday/blob/main/DECISIONLOG.md).

- These models are disabled by default due to their size, so you will need to set the below variable configurations for each of the individual models you want to utilize in your `dbt_project.yml`.

```yml
vars:
   employee_history_enabled: true   
```

- Users can set a custom `employee_history_start_date` filter to narrow down the number of historical records they bring into your staging and end models. By default, the package will use the minimum `_fivetran_start` date to generate the start date for the final daily history models. This default may be overwritten to your liking by leveraging the below variable.

```yml 
vars:
    employee_history_start_date: 'YYYY-MM-DD' # The first `_fivetran_start` date you'd like to filter data on in all your history models.
```

- We have also added the `workday__monthly_summary` model in the [`models/workday_history`](https://github.com/fivetran/dbt_workday/tree/main/models/workday_history) folder. This table aggregates high-level monthly metrics to track changes over time to overall employee data for a customer. 

- We have chosen not to implement incremental logic in the history models due to the future-facing updating of Workday HCM transactions beyond current daily updates. [See the DECISIONLOG](https://github.com/fivetran/dbt_workday/blob/main/DECISIONLOG.md) for more details.

- Workday HCM History Mode models can contain a multitude of rows if you bring in all historical data, so we've introduced the flexibility to set first date filters to bring in only the historical data you need. [More details can be found in the README](https://github.com/fivetran/dbt_workday/blob/main/README.md#filter-your-workday-hcm-history-mode-models).

## 🚘 Under the Hood 🚘
- Created `int_workday__worker_employee_enhanced` model to simplify end model processing in the `workday__employee_overview`, which is now focused on generating the surrogate key. 

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