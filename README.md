
# Workday HCM dbt Package ([Docs](https://fivetran.github.io/dbt_workday/))

<p align="left">
    <a alt="License"
        href="https://github.com/fivetran/dbt_workday/blob/main/LICENSE">
        <img src="https://img.shields.io/badge/License-Apache%202.0-blue.svg" /></a>
    <a alt="dbt-core">
        <img src="https://img.shields.io/badge/dbt_Core™_version->=1.3.0_,<2.0.0-orange.svg" /></a>
    <a alt="Maintained?">
        <img src="https://img.shields.io/badge/Maintained%3F-yes-green.svg" /></a>
    <a alt="PRs">
        <img src="https://img.shields.io/badge/Contributions-welcome-blueviolet" /></a>
    <a alt="Fivetran Quickstart Compatible"
        href="https://fivetran.com/docs/transformations/dbt/quickstart">
        <img src="https://img.shields.io/badge/Fivetran_Quickstart_Compatible%3F-yes-green.svg" /></a>
</p>

## What does this dbt package do?

This package models Workday HCM data from [Fivetran's connector](https://fivetran.com/docs/applications/workday-hcm). It uses data in the format described by [this ERD](https://fivetran.com/docs/applications/workday-hcm#schemainformation).

The main focus of the package is to transform the core object tables into analytics-ready models, including:
- Materializes [Workday HCM staging tables](https://fivetran.github.io/dbt_workday/#!/overview/workday_source/models/?g_v=1) which leverage data in the format described by [this ERD](https://fivetran.com/docs/applications/workday-hcm/#schemainformation). These staging tables clean, test, and prepare your Workday data from [Fivetran's connector](https://fivetran.com/docs/applications/workday-hcm) for analysis by doing the following:
- Name columns for consistency across all packages and for easier analysis
      - Primary keys are renamed from `id` to `<table name>_id`.  
  - Adds column-level testing where applicable. For example, all primary keys are tested for uniqueness and non-null values.
  - Provides insight into your Workday HCM data across the following grains:
    - Employee, job, organization, position.
- Gather daily historical records of employees.

This package generates a comprehensive data dictionary of your Workday HCM data through the [dbt docs site](https://fivetran.github.io/dbt_workday/).

> This package does not apply freshness tests to source data due to the variability of survey cadences.

<!--section="workday_transformation_model"-->
The following table provides a detailed list of all tables materialized within this package by default.
> TIP: See more details about these tables in the package's [dbt docs site](https://fivetran.github.io/dbt_workday/#!/overview/workday).

| **Table**                 |    **Description**             | Available in Quickstart?
| ------------------------- | ------------------------------------------------------------------------------------------------------------------|------------------------------
| [workday__employee_overview](https://fivetran.github.io/dbt_workday/#!/model/model.workday.workday__employee_overview)  | Each record represents an employee with enriched personal information and the positions they hold. This helps measure employee demographic and geographical distribution, overall retention and turnover, and compensation analysis of their employees. |  Yes
[workday__job_overview](https://fivetran.github.io/dbt_workday/#!/model/model.workday.workday__job_overview)  | Each record represents a job with enriched details on job profiles and job families. This allows users to understand recruitment patterns and details within a job and job groupings.  | Yes
| [workday__organization_overview](https://fivetran.github.io/dbt_workday/#!/model/model.workday.workday__organization_overview) |  Each record represents organization, organization roles, as well as positions and workers tied to these organizations. This allows end users to slice organizational data at any grain to better analyze organizational structures.  | Yes
| [workday__position_overview](https://fivetran.github.io/dbt_workday/#!/model/model.workday.workday__position_overview) | Each record represents a position with enriched data on positions. This allows end users to understand position availabilities, vacancies, cost to optimize hiring efforts.  | Yes
| [workday__employee_daily_history](https://fivetran.github.io/dbt_workday/#!/model/model.workday.workday__employee_daily_history)  | Each record represents a daily record for an employee, employee position, and employee personal information within Workday HCM, to help customers gather the most historically accurate data regarding their employees.  | No
| [workday__monthly_summary](https://fivetran.github.io/dbt_workday/#!/model/model.workday.workday__monthly_summary)  | Each record is a month, aggregated from the last day of each month of the employee daily history. This captures monthly aggregated metrics to track trends like employee additions and churns, salary movements, demographic changes, etc.    | No
| [workday__worker_position_org_daily_history](https://fivetran.github.io/dbt_workday/#!/model/model.workday.workday__worker_position_org_daily_history)  | Each record is a daily record for a worker/position/organization combination, starting with its first active date and updating up toward either the current date (if still active) or its last active date. This will allow customers to tie in organizations to employees via other organization tables (such as `workday__organization_overview`) more easily in their warehouses. | No

### Materialized Models
Each Quickstart transformation job run materializes 29 models if all components of this data model are enabled. This count includes all staging, intermediate, and final models materialized as `view`, `table`, or `incremental`.
<!--section-end-->

## How do I use the dbt package?

### Step 1: Prerequisites
To use this dbt package, you must have the following:

- At least one Fivetran Workday HCM connection syncing data into your destination.
- A **BigQuery**, **Snowflake**, **Redshift**, **Databricks**, or **PostgreSQL** destination.

#### Databricks dispatch configuration
If you are using a Databricks destination with this package, you must add the following (or a variation of the following) dispatch configuration within your `dbt_project.yml`. This is required in order for the package to accurately search for macros within the `dbt-labs/spark_utils` then the `dbt-labs/dbt_utils` packages respectively.
```yml
dispatch:
  - macro_namespace: dbt_utils
    search_order: ['spark_utils', 'dbt_utils']
```

### Step 2: Install the package
Include the following Workday HCM package version in your `packages.yml` file:
> TIP: Check [dbt Hub](https://hub.getdbt.com/) for the latest installation instructions or [read the dbt docs](https://docs.getdbt.com/docs/package-management) for more information on installing packages.
```yml
packages:
  - package: fivetran/workday
    version: [">=0.4.0", "<0.5.0"] # we recommend using ranges to capture non-breaking changes automatically
```

### Step 3: Define database and schema variables
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

### (Optional) Step 4: Utilizing Workday HCM History Mode

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

### (Optional) Step 5: Additional configurations

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
</details>

### (Optional) Step 6: Orchestrate your models with Fivetran Transformations for dbt Core™
<details><summary>Expand for details</summary>
<br>

Fivetran offers the ability for you to orchestrate your dbt project through [Fivetran Transformations for dbt Core™](https://fivetran.com/docs/transformations/dbt). Learn how to set up your project for orchestration through Fivetran in our [Transformations for dbt Core setup guides](https://fivetran.com/docs/transformations/dbt#setupguide).
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
## How is this package maintained and can I contribute?
### Package Maintenance
The Fivetran team maintaining this package _only_ maintains the latest version of the package. We highly recommend you stay consistent with the [latest version](https://hub.getdbt.com/fivetran/workday/latest/) of the package and refer to the [CHANGELOG](https://github.com/fivetran/dbt_workday/blob/main/CHANGELOG.md) and release notes for more information on changes across versions.

### Contributions
A small team of analytics engineers at Fivetran develops these dbt packages. However, the packages are made better by community contributions.

We highly encourage and welcome contributions to this package. Check out [this dbt Discourse article](https://discourse.getdbt.com/t/contributing-to-a-dbt-package/657) on the best workflow for contributing to a package.

## Are there any resources available?
- If you have questions or want to reach out for help, see the [GitHub Issue](https://github.com/fivetran/dbt_workday/issues/new/choose) section to find the right avenue of support for you.
- If you would like to provide feedback to the dbt package team at Fivetran or would like to request a new dbt package, fill out our [Feedback Form](https://www.surveymonkey.com/r/DQ7K7WW).