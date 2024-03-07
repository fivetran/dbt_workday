with base as (

    select *      
    from {{ source('workday','personal_information_history') }}
    {% if var('personal_information_history_start_date',[]) %}
    where cast(_fivetran_start as {{ dbt.type_timestamp() }}) >= "{{ var('personal_information_history_start_date') }}"
    {% endif %} 
),

final as (

    select 
        id as worker_id,
        cast(_fivetran_start as {{ dbt.type_timestamp() }}) as _fivetran_start,
        cast(_fivetran_end as {{ dbt.type_timestamp() }}) as _fivetran_end,
        cast(_fivetran_start as date) as _fivetran_date,
        {{ dbt_utils.generate_surrogate_key(['id', '_fivetran_start']) }} as history_unique_key,
        {{ dbt_utils.star(from=source('workday','personal_information_history'),
                        except=["id", "_fivetran_start", "_fivetran_end"]) }}
    from base
)

select *
from final