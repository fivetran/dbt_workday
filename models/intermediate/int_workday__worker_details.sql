with worker_data as (

    select *,
        {{ dbt.current_timestamp_backcompat() }} as current_date
    from {{ var('worker') }}
),

worker_details as (

    select 
        id as worker_id,
        worker_code,
        user_id,
        universal_id as worker_universal_code,
        case when active then true else false end as is_user_active,
        case when hire_date <= current_date
            and (termination_date is null or termination_date > current_date)
            then true 
            else false 
            end as is_employed,
        hire_date as start_date,
        case when termination_date > current_date then null
            else termination_date 
            end as departure_date,    
        case when termination_date is null
            then {{ dbt.datediff('current_date', 'hire_date', 'day') }}
            else {{ dbt.datediff('termination_date', 'hire_date', 'day') }}
            end as days_of_employment,
        terminated as is_terminated,
        primary_termination_category,
        primary_termination_reason,
        case
            when terminated and regrettable_termination then true
            when terminated and not regrettable_termination then false
            else null
            end as is_regrettable_termination, 
        compensation_effective_date,
        employee_compensation_frequency,
        annual_currency_summary_currency,
        annual_currency_summary_total_base_pay,
        annual_currency_summary_primary_compensation_basis,
        annual_summary_currency,
        annual_summary_total_base_pay,
        annual_summary_primary_compensation_basis,
        compensation_grade_id,
        compensation_grade_profile_id
    from worker_data
)

select * 
from worker_details