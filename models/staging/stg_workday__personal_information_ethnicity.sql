with base as (

    select *
    from {{ ref('stg_workday__personal_information_ethnicity_base') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_workday__personal_information_ethnicity_base')),
                staging_columns=get_personal_information_ethnicity_columns()
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
        -- New schema fields (always use new schema, cast legacy fields as null for backward compatibility)
        country_personal_information_id as worker_id,
        ethnicity_code,
        id as ethnicity_id,
        cast(null as {{ dbt.type_int() }}) as index  -- Legacy field (null for backward compatibility)
    from fields
    where not coalesce(_fivetran_deleted, false)
)

select *
from final
