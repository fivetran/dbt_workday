{{ config(enabled=var('employee_history_enabled', False)) }}

with base as (

    select *      
    from {{ source('workday','worker_history') }} 
    {% if var('employee_history_start_date',[]) %}
    where cast(_fivetran_start as {{ dbt.type_timestamp() }}) >= "{{ var('employee_history_start_date') }}"
    {% endif %} 
),

final as (

    select 
        id as worker_id, 
        cast(_fivetran_start as {{ dbt.type_timestamp() }}) as _fivetran_start,
        cast(_fivetran_end as {{ dbt.type_timestamp() }}) as _fivetran_end,
        cast(_fivetran_start as date) as _fivetran_date,
        cast(end_employment_date as {{ dbt.type_timestamp() }}) as end_employment_date, 
        cast(termination_date as {{ dbt.type_timestamp() }}) as termination_date,
        active as is_active,
        has_international_assignment as is_has_international_assignment,
        hire_rescinded as is_hire_rescinded,
        not_returning as is_not_returning,
        regrettable_termination as is_regrettable_termination,
        rehire as is_rehire,
        retired as is_retired,
        return_unknown as is_return_unknown,
        terminated as is_terminated,
        termination_involuntary as is_termination_involuntary,
        {{ dbt_utils.generate_surrogate_key(['id', '_fivetran_start']) }} as history_unique_key,
        {{ dbt_utils.star(from=source('workday','worker_history'),
                        except=["id", "_fivetran_start", "_fivetran_end", "home_country", "end_employment_date", "termination_date", "active",
                                "has_international_assignment", "hire_rescinded", "not_returning", "regrettable_termination", "rehire",
                                "retired", "return_unknown", "terminated", "termination_involuntary"]) }}
    from base
)

select *
from final