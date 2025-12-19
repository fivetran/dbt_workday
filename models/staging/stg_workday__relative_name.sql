
with base as (

    select *
    from {{ ref('stg_workday__relative_name_base') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_workday__relative_name_base')),
                staging_columns=get_relative_name_columns()
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
        personal_info_system_id as worker_id,
        source_relation,
        _fivetran_synced,
        first_name as relative_first_name,
        last_name as relative_last_name,
        middle_name as relative_middle_name,
        relationship_type,
        relationship_type_id,
        index
    from fields
    where not coalesce(_fivetran_deleted, false)
)

select *
from final
