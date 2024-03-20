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
        {{ dbt_utils.generate_surrogate_key(['id', '_fivetran_start']) }} as history_unique_key,
        {{ dbt_utils.star(from=source('workday','worker_history'),
                        except=["id", "_fivetran_start", "_fivetran_end", "home_country", "end_employment_date", "termination_date"]) }}
    from base
)

select *
from final