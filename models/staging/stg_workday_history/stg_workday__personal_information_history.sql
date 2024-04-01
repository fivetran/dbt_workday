{{ config(enabled=var('employee_history_enabled', False)) }}

with base as (

    select *      
    from {{ ref('stg_workday__personal_information_base') }}
    {% if var('employee_history_start_date',[]) %}
    where cast(_fivetran_start as {{ dbt.type_timestamp() }}) >= "{{ var('employee_history_start_date') }}"
    {% endif %} 
),

final as (

    select 
        id as worker_id,
        source_relation,
        cast(_fivetran_start as {{ dbt.type_timestamp() }}) as _fivetran_start,
        cast(_fivetran_end as {{ dbt.type_timestamp() }}) as _fivetran_end,
        cast(_fivetran_start as date) as _fivetran_date,
        {{ dbt_utils.generate_surrogate_key(['id', '_fivetran_start']) }} as stg_history_unique_key,
        additional_nationality,
        blood_type,
        citizenship_status,
        city_of_birth,
        city_of_birth_code,
        country_of_birth,
        date_of_birth,
        date_of_death,
        gender, 
        hispanic_or_latino as is_hispanic_or_latino,
        hukou_locality,
        hukou_postal_code,
        hukou_region,
        hukou_subregion,
        hukou_type,
        last_medical_exam_date,
        last_medical_exam_valid_to,
        local_hukou as is_local_hukou, 
        marital_status,
        marital_status_date,
        medical_exam_notes,
        native_region,
        native_region_code,
        personnel_file_agency,
        political_affiliation,
        primary_nationality,
        region_of_birth,
        region_of_birth_code,
        religion,
        social_benefit,
        tobacco_use as is_tobacco_use,
        type
    from base
)

select *
from final