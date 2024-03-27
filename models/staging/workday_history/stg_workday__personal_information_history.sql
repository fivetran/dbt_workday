{{ config(enabled=var('employee_history_enabled', False)) }}

with base as (

    select *      
    from {{ source('workday','personal_information_history') }}
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
        hispanic_or_latino as is_hispanic_or_latino,
        local_hukou as is_local_hukou,
        tobacco_use as is_tobacco_use,
        {{ dbt_utils.generate_surrogate_key(['id', '_fivetran_start']) }} as history_unique_key,
        {{ dbt_utils.star(from=source('workday','personal_information_history'),
                        except=["id", "_fivetran_start", "_fivetran_end", "hispanic_or_latino",
                            "local_hukou", "tobacco_use"]) }}
    from base
)

select *
from final