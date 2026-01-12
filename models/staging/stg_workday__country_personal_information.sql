{{ config(enabled=var('workday__using_personal_info_v2_schema', true)) }}

with base as (

    select *
    from {{ ref('stg_workday__country_personal_information_base') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_workday__country_personal_information_base')),
                staging_columns=get_country_personal_information_columns()
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
        fivetran_id,
        personal_info_common_id,
        country_code,
        source_relation,
        _fivetran_synced,
        gender,
        hispanic_or_latino as is_hispanic_or_latino,
        hukou_locality,
        hukou_postal_code,
        hukou_region_code,
        hukou_subregion_code,
        hukou_type_code,
        local_hukou as is_local_hukou,
        marital_status,
        marital_status_date,
        native_region_code,
        native_region,
        personnel_file_agency_for_person,
        political_affiliation,
        religion,
        social_benefits_locality
    from fields
)

select *
from final
