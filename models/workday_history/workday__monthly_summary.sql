with row_month_partition as (

    select *, 
        {{ dbt.date_trunc("month", "date_day") }} as date_month,
        row_number() over (partition by employee_id, extract(year from date_day), extract(month from date_day) order by date_day desc) AS recent_dom_row
    from {{ ref('workday__employee_daily_history') }}
    order by employee_id, date_day
),

end_of_month_history as (
    
    select *
    from row_month_partition
    where recent_dom_row = 1
    order by employee_id, date_day
),

monthly_employee_metrics as (

    select date_month,
        sum(case when date_month = {{ dbt.date_trunc("month", "effective_date") }} then 1 else 0 end) as new_employees,
        sum(case when date_month = {{ dbt.date_trunc("month", "termination_date") }} then 1 else 0 end) as churned_employees,
        sum(case when date_month = {{ dbt.date_trunc("month", "wh_end_employment_date") }} then 1 else 0 end) as churned_workers
    from end_of_month_history
    group by 1
),

monthly_active_employee_metrics as (

    select date_month,
        count(distinct employee_id) as active_employees,
        sum(case when gender is not null and lower(gender) = 'male' then 1 else 0 end) as active_male_employees,
        sum(case when gender is not null and lower(gender) = 'female' then 1 else 0 end) as active_female_employees,
        sum(case when gender is not null then 1 else 0 end) as active_known_gender_employees
    from end_of_month_history
    where date_month >= {{ dbt.date_trunc("month", "effective_date") }}
        and (date_month <= {{ dbt.date_trunc("month", "wph_end_employment_date") }}
            or wph_end_employment_date is null)
    group by 1
),

monthly_active_worker_metrics as (
    
    select date_month,
        count(distinct worker_id) as active_workers
    from end_of_month_history
    where (date_month >= {{ dbt.date_trunc("month", "effective_date") }}
        and date_month <= {{ dbt.date_trunc("month", "wh_end_employment_date") }})
            or wh_end_employment_date is null
    group by 1
),

monthly_summary as (

    select 
        monthly_employee_metrics.date_month,
        monthly_employee_metrics.new_employees,
        monthly_employee_metrics.churned_employees,
        monthly_employee_metrics.churned_workers,
        monthly_active_employee_metrics.active_employees,
        monthly_active_employee_metrics.active_male_employees,
        monthly_active_employee_metrics.active_female_employees,
        monthly_active_employee_metrics.active_known_gender_employees,
        monthly_active_worker_metrics.active_workers
    from monthly_employee_metrics
    left join monthly_active_employee_metrics 
        on monthly_employee_metrics.date_month = monthly_active_employee_metrics.date_month
    left join monthly_active_worker_metrics
        on monthly_employee_metrics.date_month = monthly_active_worker_metrics.date_month
)

select *
from monthly_summary