# dbt_workday v0.1.0

## 🎉 Initial Release 🎉
This is the initial release of this package!

## 📣 What does this dbt package do?
This package models Workday HCM data from [Fivetran's connector](https://fivetran.com/docs/applications/workday-hcm). It uses data in the format described by [this ERD](https://fivetran.com/docs/applications/workday-hcm#schemainformation).

The main focus of the package is to transform the core object tables into analytics-ready models:
<!--section="workday_model"-->
  - Materializes [Salesforce Marketing Cloud staging tables](https://fivetran.github.io/dbt_workday/#!/overview/workday/models/?g_v=1) which leverage data in the format described by [this ERD](https://fivetran.com/docs/applications/workday-hcm/#schemainformation). The staging tables clean, test, and prepare your Workday HCM data from [Fivetran's connector](https://fivetran.com/docs/applications/workday-hcm) for analysis by doing the following:
  - Primary keys are renamed from `id` to `<table name>_id`. 
  - Adds column-level testing where applicable. For example, all primary keys are tested for uniqueness and non-null values.
  - Provides insight into your Workday HCM data across the following grains:
    - Email, send, event, link, list, and subscriber
  - Generates a comprehensive data dictionary of your Workday HCM data through the [dbt docs site](https://fivetran.github.io/dbt_workday/).