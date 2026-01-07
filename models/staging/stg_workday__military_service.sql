with base as (

    select * 
    from {{ ref('stg_workday__military_service_base') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_workday__military_service_base')),
                staging_columns=get_military_service_columns()
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
        personal_info_common_id as worker_id,
        source_relation,
        _fivetran_synced,
        discharge_date,
        cast(null as {{ dbt.type_int() }}) as index,  -- Field removed in new schema
        notes,
        rank,
        service,
        discharge_type,  -- New field
        coalesce(status_id, status) as military_status,  -- status_id new value, status legacy value
        status_begin_date
    from fields
    where not coalesce(_fivetran_deleted, false)
)

select *
from final
