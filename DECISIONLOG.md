## On not adding incremental logic into the Workday HCM History models
Generally, when working with large volume models like the ones created by Fivetran History Mode, we tend to implement incremental models. [See Salesforce](https://github.com/fivetran/dbt_salesforce?tab=readme-ov-file#optional-step-4-utilizing-salesforce-history-mode-records) for a particular example of that implementation. 

However, in the Workday HCM case, we have found that History Mode does not fit the use case for incremental logic due to the following reasons.
* Transactions can be future-dated. The most common case is an employee being hired for a future date beyond the current date, so an incremental run will pick up numerous records in the future, leading to potential duplications down the road for an employee's records.
* There are additional cases where an employee's record can be updated in the past beyond a common incremental window.

For this reason, we will recommend users utilize the `--full-refresh` method to grab records to maintain accuracy. So we recommend that you optimize your refresh strategy when using this package to reduce warehouse load and minimize costs. 

We welcome all attempts to optimize this strategy though, and would be open to enhancements to the package!

## Why we kept the worker position organization history model separate from the employee daily history model

The intent of the `workday__employee_daily_history` model was to combine historical data from all relevant worker history models and gather a daily look at that data based on employee and worker. 

However, with `stg_workday__worker_position_organization_history`, the values for organization are too customizable, and thus impossible to just into an `employee_daily_history` model with any clear definitions.

Instead we have decided to keep the model separate in `workday__worker_position_org_history`, leaving end customers the ability to configure what organizations they end up joining into the employee daily history within their warehouses. The `int_workday__employee_history` model provides a solid guide into configuring your own custom-type history mode model. 