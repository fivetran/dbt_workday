with worker_data as (

    select *
    from {{ var('worker') }}
),

worker_details as (

    select 
        id as worker_id,
        worker_code,
        user_id,
        universal_id as worker_universal_code,
        if(active, true, false) as is_user_active,
        if(
            hire_date <= current_date() 
            and (termination_date is null or termination_date > current_date()),
            true,
            false
        ) as is_employed,
        hire_date as start_date,
        if(termination_date > current_date(), null, termination_date) as departure_date,    
        case when termination_date is null
            then date_diff(CURRENT_DATE(), hire_date, day)
            else date_diff(termination_date, hire_date, day)
            end as days_of_employment,
        terminated as is_terminated,
        primary_termination_category,
        primary_termination_reason,
        case
            when terminated and regrettable_termination then true
            when terminated and not regrettable_termination then false
            else null
            end as is_regrettable_termination, 
        compensation_effective_date as comp_effective_date,
        employee_compensation_frequency,
        annual_currency_summary_currency as comp_default_currency,
        annual_currency_summary_total_base_pay as comp_default_annual_base,
        annual_currency_summary_primary_compensation_basis as comp_default_annual_base_and_ote,
        annual_summary_currency as comp_local_currency,
        annual_summary_total_base_pay as comp_local_annual_base,
        annual_summary_primary_compensation_basis as comp_local_annual_base_and_ote,
        compensation_grade_id,
        compensation_grade_profile_id
    from worker_data
)

select * 
from worker_details