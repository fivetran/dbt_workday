{{ config(enabled=var('employee_history_enabled', False)) }}

with base as (

    select *      
    from {{ ref('stg_workday__position_organization_base') }}
    {% if var('employee_history_start_date',[]) %}
    where cast(_fivetran_start as {{ dbt.type_timestamp() }}) >= "{{ var('employee_history_start_date') }}"
    {% endif %} 
),

final as (

    select 
        worker_id,
        position_id,
        organization_id,
        source_relation,
        cast(_fivetran_start as {{ dbt.type_timestamp() }}) as _fivetran_start,
        cast(_fivetran_end as {{ dbt.type_timestamp() }}) as _fivetran_end,
        cast(_fivetran_start as date) as _fivetran_date, 
        {{ dbt_utils.generate_surrogate_key(['worker_id', 'position_id', 'organization_id', 'source_relation', '_fivetran_start']) }} as stg_history_unique_key,
        index,   
        date_of_pay_group_assignment, 
        primary_business_site,
        used_in_change_organization_assignments as is_used_in_change_organization_assignments
    from base
)

select *
from final