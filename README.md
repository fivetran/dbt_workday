<!--section="workday_transformation_model"-->
# Workday HCM dbt Package

<p align="left">
    <a alt="License"
        href="https://github.com/fivetran/dbt_workday/blob/main/LICENSE">
        <img src="https://img.shields.io/badge/License-Apache%202.0-blue.svg" /></a>
    <a alt="dbt-core">
        <img src="https://img.shields.io/badge/dbt_Core™_version->=1.3.0,_<3.0.0-orange.svg" /></a>
    <a alt="Maintained?">
        <img src="https://img.shields.io/badge/Maintained%3F-yes-green.svg" /></a>
    <a alt="PRs">
        <img src="https://img.shields.io/badge/Contributions-welcome-blueviolet" /></a>
    <a alt="Fivetran Quickstart Compatible"
        href="https://fivetran.com/docs/transformations/data-models/quickstart-management#quickstartmanagement">
        <img src="https://img.shields.io/badge/Fivetran_Quickstart_Compatible%3F-yes-green.svg" /></a>
</p>

This dbt package transforms data from Fivetran's Workday HCM connector into analytics-ready tables.

## Resources

- Number of materialized models¹: 29
- Connector documentation
  - [Workday connector documentation](https://fivetran.com/docs/connectors/applications/workday-hcm)
  - [Workday ERD](https://fivetran.com/docs/connectors/applications/workday-hcm#schemainformation)
- dbt package documentation
  - [GitHub repository](https://github.com/fivetran/dbt_workday)
  - [dbt Docs](https://fivetran.github.io/dbt_workday/#!/overview)
  - [DAG](https://fivetran.github.io/dbt_workday/#!/overview?g_v=1)
  - [Changelog](https://github.com/fivetran/dbt_workday/blob/main/CHANGELOG.md)

## What does this dbt package do?

This package enables you to transform core object tables into analytics-ready models and gather daily historical records of employees. It creates enriched models with metrics focused on employee demographics, organizational structures, job profiles, and position management.

### Output schema
Final output tables are generated in the following target schema:

```
<your_database>.<connector/schema_name>_workday
```

### Final output tables

By default, this package materializes the following final tables:

| Table | Description |
| :---- | :---- |
| [workday__employee_overview](https://fivetran.github.io/dbt_workday/#!/model/model.workday.workday__employee_overview) | Consolidates employee profiles with personal information, position details, employment status, demographics, compensation data, and tenure metrics to analyze workforce composition, retention, turnover, and compensation across the organization. <br></br>**Example Analytics Questions:**<ul><li>What is the employee demographic distribution (gender, ethnicity_codes) by position_location and management_level_code?</li><li>How do days_employed and compensation (annual_summary_total_base_pay) vary by employee_type?</li><li>Which positions have the highest fte_percent and best retention (is_employed_five_years)?</li></ul>|
| [workday__job_overview](https://fivetran.github.io/dbt_workday/#!/model/model.workday.workday__job_overview) | Provides comprehensive job profiles with job family classifications, job titles, descriptions, and summaries to analyze job structures, recruitment patterns, and workforce planning needs. <br></br>**Example Analytics Questions:**<ul><li>How are jobs distributed across different job_family_codes and job_family_group_codes?</li><li>Which job_title values have the most detailed job_description and job_summary content?</li><li>What is the hierarchy relationship between job_family and job_family_group classifications?</li></ul>|
| [workday__organization_overview](https://fivetran.github.io/dbt_workday/#!/model/model.workday.workday__organization_overview) | Maps organizational hierarchies with organization codes, types, roles, associated positions and workers, plus manager and superior organization relationships to enable multi-dimensional analysis of organizational structure and headcount. <br></br>**Example Analytics Questions:**<ul><li>How are workers and positions distributed across organization_type and organization_sub_type?</li><li>What is the organizational hierarchy from top_level_organization_id to subordinate organizations?</li><li>Which organizations have the most positions and workers by organization_role_code?</li></ul>|
| [workday__position_overview](https://fivetran.github.io/dbt_workday/#!/model/model.workday.workday__position_overview) | Tracks position details including vacancy status, availability flags, worker assignments, job profiles, organizational ties, and compensation information to optimize hiring efforts, monitor position utilization, and control workforce costs. <br></br>**Example Analytics Questions:**<ul><li>Which positions are vacant (worker_for_filled_position_id is null) and have is_available_for_hire = true?</li><li>How do is_hiring_freeze and is_closed flags affect position availability by supervisory_organization_id?</li><li>What is the distribution of positions by worker_type_code and compensation_grade_code?</li></ul>|
| [workday__employee_daily_history](https://fivetran.github.io/dbt_workday/#!/model/model.workday.workday__employee_daily_history) | Chronicles daily employee snapshots with position assignments, personal info, employment status, compensation details, and demographic data to enable historical analysis, track employee changes over time, and measure workforce metrics at any point in time. <br></br>**Example Analytics Questions:**<ul><li>How has headcount (active employees) changed day-by-day across date_day by employee_type?</li><li>What employee attributes (business_title, compensation, fte_percent) change most frequently over time?</li><li>How do daily compensation snapshots (annual_currency_summary_total_base_pay) compare to current values?</li></ul>|
| [workday__monthly_summary](https://fivetran.github.io/dbt_workday/#!/model/model.workday.workday__monthly_summary) | Summarizes monthly workforce metrics including new hires, attrition (voluntary and involuntary), active headcount, average compensation, and tenure to support strategic workforce planning and trend analysis. <br></br>**Example Analytics Questions:**<ul><li>What is the monthly net headcount change (new_employees minus churned_employees) by metrics_month?</li><li>How do churned_voluntary_employees versus churned_involuntary_employees trends vary over time?</li><li>What are the monthly trends in avg_employee_primary_compensation and avg_employee_base_pay?</li></ul>|
| [workday__worker_position_org_daily_history](https://fivetran.github.io/dbt_workday/#!/model/model.workday.workday__worker_position_org_daily_history) | Tracks daily worker-position-organization combinations from activation to present or termination to enable historical organizational analysis and connect workers to organizational hierarchies over time. <br></br>**Example Analytics Questions:**<ul><li>How long do workers stay in specific position_id and organization_id combinations?</li><li>What is the historical organizational assignment path for each worker_id over time?</li><li>How many position or organization changes occur per worker based on date_day transitions?</li></ul>|

¹ Each Quickstart transformation job run materializes these models if all components of this data model are enabled. This count includes all staging, intermediate, and final models materialized as `view`, `table`, or `incremental`.

---

## Prerequisites
To use this dbt package, you must have the following:

- At least one Fivetran Workday HCM connection syncing data into your destination.
- A **BigQuery**, **Snowflake**, **Redshift**, **Databricks**, or **PostgreSQL** destination.

## How do I use the dbt package?
You can either add this dbt package in the Fivetran dashboard or import it into your dbt project:

- To add the package in the Fivetran dashboard, follow our [Quickstart guide](https://fivetran.com/docs/transformations/data-models/quickstart-management).
- To add the package to your dbt project, follow the setup instructions in the dbt package's [README file](https://github.com/fivetran/dbt_workday/blob/main/README.md#how-do-i-use-the-dbt-package) to use this package.

<!--section-end-->

### Install the package
Include the following Workday HCM package version in your `packages.yml` file:
> TIP: Check [dbt Hub](https://hub.getdbt.com/) for the latest installation instructions or [read the dbt docs](https://docs.getdbt.com/docs/package-management) for more information on installing packages.
```yml
packages:
  - package: fivetran/workday
    version: [">=0.8.0", "<0.9.0"] # we recommend using ranges to capture non-breaking changes automatically
```

#### Databricks dispatch configuration
If you are using a Databricks destination with this package, you must add the following (or a variation of the following) dispatch configuration within your `dbt_project.yml`. This is required in order for the package to accurately search for macros within the `dbt-labs/spark_utils` then the `dbt-labs/dbt_utils` packages respectively.
```yml
dispatch:
  - macro_namespace: dbt_utils
    search_order: ['spark_utils', 'dbt_utils']
```

### Define database and schema variables
#### Single connection
By default, this package runs using your destination and the `workday` schema. If this is not where your Workday HCM data is (for example, if your Workday HCM schema is named `workday_fivetran`), add the following configuration to your root `dbt_project.yml` file:

```yml
# dbt_project.yml

vars:
    workday_database: your_database_name
    workday_schema: your_schema_name
```
#### Union multiple connections
If you have multiple Workday HCM connections in Fivetran and would like to use this package on all of them simultaneously, we have provided functionality to do so. The package will union all of the data together and pass the unioned table into the transformations. You will be able to see which source it came from in the `source_relation` column of each model. To use this functionality, you will need to set either the `workday_union_schemas` OR `workday_union_databases` variables (cannot do both) in your root `dbt_project.yml` file:

```yml
# dbt_project.yml

vars:
    workday_union_schemas: ['workday_usa','workday_canada'] # use this if the data is in different schemas/datasets of the same database/project
    workday_union_databases: ['workday_usa','workday_canada'] # use this if the data is in different databases/projects but uses the same schema name
```

> NOTE: The native `source.yml` connection set up in the package will not function when the union schema/database feature is utilized. Although the data will be correctly combined, you will not observe the sources linked to the package models in the Directed Acyclic Graph (DAG). This happens because the package includes only one defined `source.yml`.

To connect your multiple schema/database sources to the package models, follow the steps outlined in the [Union Data Defined Sources Configuration](https://github.com/fivetran/dbt_fivetran_utils/tree/releases/v0.4.latest#union_data-source) section of the Fivetran Utils documentation for the union_data macro. This will ensure a proper configuration and correct visualization of connections in the DAG.


### (Optional) Utilizing Workday HCM History Mode

If you have History Mode enabled for your Workday HCM connection, we now include support for the worker, worker position, worker position organization, and personal information tables directly. You can view these files in the [`staging`](https://github.com/fivetran/dbt_workday/blob/main/models/workday_history/staging) folder. This staging data then flows into the employee daily history model, which in turn populates the monthly summary model. This will allow you access to your historical data for these tables for the most accurate record of your data over time.

#### Enabling Workday HCM History Mode Models
The History Mode models can get quite expansive since it will take in **ALL** historical records, so we've disabled them by default. You can enable the history models you'd like to utilize by adding the below variable configurations within your `dbt_project.yml` file for the equivalent models.

```yml
# dbt_project.yml

...
vars:
  employee_history_enabled: true  # False by default. Only use if you have history mode enabled and wish to view the full historical record. 
```

#### Filter your Workday HCM History Mode models
By default, these history models are set to bring in all your data from Workday HCM History, but you may be interested in bringing in only a smaller sample of historical records, given the relative size of the Workday HCM history source tables. By default, the package will use the minimum `_fivetran_start` date for the historical end models. This default may be overwritten to your liking by leveraging the below variable.

We have set up where conditions in our staging models to allow you to bring in only the data you need to run in. You can set a global history filter that would apply to all of our staging history models in your `dbt_project.yml`:

```yml 
vars:
    employee_history_start_date: 'YYYY-MM-DD' # The first `_fivetran_start` date you'd like to filter data on in all your history models.
```

The default date value in our models is set at `2005-03-01` (the month Workday was founded), designed for if you want to capture all available data by default. If you choose to set a custom date value as outlined above, these models will take the greater of either this value or the minimum `_fivetran_start` date in the source data. They will then be used for creating the first dates available with historical data in your daily history models.

### (Optional) Additional configurations

#### Changing the Build Schema
By default this package will build the Workday HCM staging models within a schema titled (<target_schema> + `_stg_workday`) and the Workday HCM final models within a schema titled (<target_schema> + `_workday`) in your target database. If this is not where you would like your modeled Workday HCM data to be written to, add the following configuration to your `dbt_project.yml` file:

```yml
# dbt_project.yml

models:
  workday:
    +schema: my_new_schema_name # leave blank for just the target_schema
    staging:
        +schema: my_new_schema_name # leave blank for just the target_schema
```

#### Change the source table references
If an individual source table has a different name than the package expects, add the table name as it appears in your destination to the respective variable:

> IMPORTANT: See this project's [`dbt_project.yml`](https://github.com/fivetran/dbt_workday/blob/main/dbt_project.yml) variable declarations to see the expected names.

```yml
# dbt_project.yml

vars:
    workday_<default_source_table_name>_identifier: your_table_name 
```

#### (Optional): Workday Schema Migration Configuration

Workday is migrating to a new API version with significant schema changes that will last for several months. Starting **January 5, 2026**, existing Fivetran Workday HCM connectors will begin syncing new tables with an "_INCOMING" suffix alongside existing tables during a transition period lasting until **April 6, 2026**.  This package automatically detects which tables are available in your warehouse and uses the appropriate tables. **No action is required in most cases.**

##### Impacted Tables
The following tables have new versions with "_incoming" suffix:
- `military_service` → `military_service_incoming` 
- `personal_information_ethnicity` → `personal_information_ethnicity_incoming` 

Additionally, fields from `personal_information_history` have been split into new tables:
- `personal_information_common_data`
- `country_personal_information` 

##### Leveraging Legacy or Incoming Table Names
If you need to leverage the old personal information schema or have set up a Workday HCM connector after January 5, you can set the following variables in your `dbt_project.yml`:

```yml
# dbt_project.yml

vars: 
  workday__using_military_service_incoming: false  # Default is currently true
  workday__using_personal_information_ethnicity_incoming: false  # Default is currently true 
  workday__using_personal_info_v2_schema: false  # To leverage old schema. Default is currently true
```

</details>

### (Optional) Orchestrate your models with Fivetran Transformations for dbt Core™
<details><summary>Expand for details</summary>
<br>

Fivetran offers the ability for you to orchestrate your dbt project through [Fivetran Transformations for dbt Core™](https://fivetran.com/docs/transformations/dbt#transformationsfordbtcore). Learn how to set up your project for orchestration through Fivetran in our [Transformations for dbt Core setup guides](https://fivetran.com/docs/transformations/dbt/setup-guide#transformationsfordbtcoresetupguide).
</details>

## Does this package have dependencies?
This dbt package is dependent on the following dbt packages. These dependencies are installed by default within this package. For more information on the following packages, refer to the [dbt hub](https://hub.getdbt.com/) site.
> IMPORTANT: If you have any of these dependent packages in your own `packages.yml` file, we highly recommend that you remove them from your root `packages.yml` to avoid package version conflicts.

```yml
packages:
    - package: fivetran/fivetran_utils
      version: [">=0.4.0", "<0.5.0"]

    - package: dbt-labs/dbt_utils
      version: [">=1.0.0", "<2.0.0"]
```
<!--section="workday_maintenance"-->
## How is this package maintained and can I contribute?
### Package Maintenance
The Fivetran team maintaining this package only maintains the [latest version](https://hub.getdbt.com/fivetran/workday/latest/) of the package. We highly recommend you stay consistent with the latest version of the package and refer to the [CHANGELOG](https://github.com/fivetran/dbt_workday/blob/main/CHANGELOG.md) and release notes for more information on changes across versions.

### Contributions
A small team of analytics engineers at Fivetran develops these dbt packages. However, the packages are made better by community contributions.

We highly encourage and welcome contributions to this package. Learn how to contribute to a package in dbt's [Contributing to an external dbt package article](https://discourse.getdbt.com/t/contributing-to-a-dbt-package/657).

<!--section-end-->

## Are there any resources available?
- If you have questions or want to reach out for help, see the [GitHub Issue](https://github.com/fivetran/dbt_workday/issues/new/choose) section to find the right avenue of support for you.
- If you would like to provide feedback to the dbt package team at Fivetran or would like to request a new dbt package, fill out our [Feedback Form](https://www.surveymonkey.com/r/DQ7K7WW).
