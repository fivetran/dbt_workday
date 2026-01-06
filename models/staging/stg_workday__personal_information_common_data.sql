{{ config(enabled=var('workday__using_personal_info_v2_schema', true)) }}

with base as (

    select *
    from {{ ref('stg_workday__personal_information_common_data_base') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_workday__personal_information_common_data_base')),
                staging_columns=get_personal_information_common_data_columns()
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
        id as worker_id,
        source_relation,
        _fivetran_synced,
        additional_nationality,
        blood_type,
        citizenship_status,
        city_of_birth,
        city_of_birth_code,
        country_of_birth,
        country_region_of_birth,
        date_of_birth,
        date_of_death,
        last_medical_exam_date,
        last_medical_exam_valid_to,
        medical_exam_notes,
        primary_nationality,
        region_of_birth
    from fields
)

select *
from final
