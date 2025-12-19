
with base as (

    select *
    from {{ ref('stg_workday__personal_information_sexual_orientation_base') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_workday__personal_information_sexual_orientation_base')),
                staging_columns=get_personal_information_sexual_orientation_columns()
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
        id as worker_id,
        source_relation,
        _fivetran_synced,
        sexual_orientation_code,
        sexual_orientation_id,
        index
    from fields
    where {{ dbt.current_timestamp() }} between _fivetran_start and _fivetran_end
)

select *
from final
