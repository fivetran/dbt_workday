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
        personal_info_common_id as worker_id,  -- NEW field name
        {% else %}
        personal_info_system_id as worker_id,  -- OLD field name
        {% endif %}
        source_relation,
        _fivetran_synced,
        discharge_date,
        index,
        {% if use_incoming %}
        cast(null as {{ dbt.type_string() }}) as notes,  -- Field removed in new schema
        {% else %}
        notes,  -- Field exists in old schema
        {% endif %}
        rank,
        service,
        {% if use_incoming %}
        discharge_type as service_type,  -- NEW field name mapped to old output name
        {% else %}
        service_type,
        {% endif %}
        status as military_status,
        status_begin_date
    from fields
    where not coalesce(_fivetran_deleted, false)
)

select *
from final
