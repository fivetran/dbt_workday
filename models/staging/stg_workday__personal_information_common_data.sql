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
        {{ fivetran_utils.apply_source_relation(package_name='workday') }}
    from base
),

final as (

    select
        fivetran_id,
        worker_id,
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
    where not coalesce(_fivetran_deleted, false)
)

select *
from final