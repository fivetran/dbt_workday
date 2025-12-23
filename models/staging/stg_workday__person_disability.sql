{%- set use_incoming = var('workday__using_person_disability_incoming',
    workday.does_table_exist('person_disability_incoming')) -%}

with base as (

    select *
    from {{ ref('stg_workday__person_disability_base') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_workday__person_disability_base')),
                staging_columns=get_person_disability_incoming_columns() if use_incoming
                else get_person_disability_columns()
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
        degree as disability_degree,  -- NEW field name mapped to old output name
        grade as disability_grade,  -- NEW field name mapped to old output name
        code as disability_type,  -- NEW field name mapped to old output name
        id as index  -- NEW field name mapped to old output name
        {% else %}
        personal_info_system_id as worker_id,  -- OLD field name
        disability_degree,
        disability_grade,
        disability_type,
        index
        {% endif %}
    from fields
    where not coalesce(_fivetran_deleted, false)
)

select *
from final
