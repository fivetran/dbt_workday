{%- set use_incoming = var('workday__using_military_service_incoming',
workday.does_table_exist('military_service_incoming')) -%}

with base as (

    select * 
    from {{ ref('stg_workday__military_service_base') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_workday__military_service_base')),
                staging_columns=get_military_service_incoming_columns() if use_incoming 
                else get_military_service_columns()
            )
        }}
        {{ fivetran_utils.source_relation(
            union_schema_variable='workday_union_schemas', 
            union_database_variable='workday_union_databases') 
        }}
    from base
),

final as (
    select
        {% if use_incoming %}
        -- New v42.2 schema fields
        personal_info_common_id as worker_id,
        source_relation,
        _fivetran_synced,
        discharge_date,
        cast(null as {{ dbt.type_int() }}) as index,  -- Field removed in new schema
        notes,
        rank,
        service,
        discharge_type as service_type,  -- Renamed field
        status_id as military_status,  -- Renamed field
        status_begin_date
        {% else %}
        -- Legacy schema fields
        personal_info_system_id as worker_id,
        source_relation,
        _fivetran_synced,
        discharge_date,
        index,
        notes,
        rank,
        service,
        service_type,
        status as military_status,
        status_begin_date
        {% endif %}
    from fields
    where not coalesce(_fivetran_deleted, false)
)

select *
from final
