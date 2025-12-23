{%- set use_incoming = var('workday__using_relative_name_incoming',
    workday.does_table_exist('relative_name_incoming')) -%}

with base as (

    select *
    from {{ ref('stg_workday__relative_name_base') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_workday__relative_name_base')),
                staging_columns=get_relative_name_incoming_columns() if use_incoming
                else get_relative_name_columns()
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
        source_relation,
        _fivetran_synced,
        {% if use_incoming %}
        country_personal_information_id as worker_id,  -- NEW field name
        first_name as relative_first_name,
        last_name as relative_last_name,
        middle_name as relative_middle_name,
        relative_type_code as relationship_type,  -- NEW field name mapped to old output name
        relative_name_reference_id as relationship_type_id,  -- NEW field name mapped to old output name
        id as index  -- NEW field name mapped to old output name
        {% else %}
        personal_info_system_id as worker_id,  -- OLD field name
        first_name as relative_first_name,
        last_name as relative_last_name,
        middle_name as relative_middle_name,
        relationship_type,
        relationship_type_id,
        index
        {% endif %}
    from fields
    where not coalesce(_fivetran_deleted, false)
)

select *
from final
