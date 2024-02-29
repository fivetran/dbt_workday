{{ config(
        enabled= var('worker_position_history_enabled', False),
        materialized='incremental',
        unique_key='history_unique_key',
        incremental_strategy='insert_overwrite' if target.type in ('bigquery', 'spark', 'databricks') else 'delete+insert',
        partition_by={
            "field": "_fivetran_date", 
            "data_type": "date"
        } if target.type not in ('spark','databricks') else ['_fivetran_date'],
        file_format='parquet',
        on_schema_change='fail'
    )
}}

with base as (

    select *      
    from {{ source('workday','worker_position_history') }}
    {% if is_incremental() %}
    where cast(_fivetran_start as {{ dbt.type_timestamp() }}) >= (select max(cast((_fivetran_start) as {{ dbt.type_timestamp() }})) from {{ this }} )
    {% else %}
    {% if var('worker_position_history_enabled',[]) %}
    where cast(_fivetran_start as {{ dbt.type_timestamp() }}) >= "{{ var('worker_position_history_start_date') }}"
    {% endif %}
    {% endif %} 
),

final as (

    select 
        worker_id,
        position_id,
        cast(_fivetran_start as {{ dbt.type_timestamp() }}) as _fivetran_start,
        cast(_fivetran_end as {{ dbt.type_timestamp() }}) as _fivetran_end,
        cast(_fivetran_start as date) as _fivetran_date,
        {{ dbt_utils.generate_surrogate_key(['worker_id', 'position_id', '_fivetran_start']) }} as history_unique_key,
        {{ dbt_utils.star(from=source('workday','worker_position_history'),
                        except=["worker_id", "position_id", "_fivetran_start", "_fivetran_end", "home_country"]) }}
    from base
)

select *
from final