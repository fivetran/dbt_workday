{{ config(enabled=var('employee_history_enabled', False)) }}

with base as (

    select *      
    from {{ source('workday','worker_position_history') }}
    {% if var('employee_history_start_date',[]) %}
    where cast(_fivetran_start as {{ dbt.type_timestamp() }}) >= "{{ var('employee_history_start_date') }}"
    {% endif %}
),

final as (

    select 
        worker_id,
        position_id,
        cast(_fivetran_start as {{ dbt.type_timestamp() }}) as _fivetran_start,
        cast(_fivetran_end as {{ dbt.type_timestamp() }}) as _fivetran_end,
        cast(_fivetran_start as date) as _fivetran_date,
        cast(effective_date as {{ dbt.type_timestamp() }}) as effective_date,
        cast(end_employment_date as {{ dbt.type_timestamp() }}) as end_employment_date,
        cast(start_date as {{ dbt.type_timestamp() }}) as position_start_date,
        cast(end_date as {{ dbt.type_timestamp() }}) as position_end_date,
        business_site_summary_location as position_location,
        exclude_from_head_count as is_exclude_from_head_count,
        full_time_equivalent_percentage as fte_percent,
        job_exempt as is_job_exempt,
        specify_paid_fte as is_specify_paid_fte,
        specify_working_fte as is_specify_working_fte,
        work_shift_required as is_work_shift_required,
        {{ dbt_utils.generate_surrogate_key(['worker_id', 'position_id', '_fivetran_start']) }} as history_unique_key,
        {{ dbt_utils.star(from=source('workday','worker_position_history'),
                        except=["worker_id", "position_id", "_fivetran_start", "_fivetran_end", 
                            "home_country", "effective_date", "end_employment_date", 
                            "start_date", "end_date", "business_site_summary_location", "exclude_from_head_count",
                            "full_time_equivalent_percentage", "job_exempt", "specify_paid_fte",
                            "specify_working_fte", "work_shift_required"]) }}
    from base
)

select *
from final