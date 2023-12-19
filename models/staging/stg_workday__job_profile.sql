
with base as (

    select * 
    from {{ ref('stg_workday__job_profile_base') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_workday__job_profile_base')),
                staging_columns=get_job_profile_columns()
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
        _fivetran_deleted,
        _fivetran_synced,
        additional_job_description,
        compensation_grade_id,
        critical_job,
        description,
        difficulty_to_fill,
        effective_date,
        id as job_profile_id,
        inactive,
        include_job_code_in_name,
        job_category_id,
        job_profile_code,
        level,
        management_level,
        private_title,
        public_job,
        referral_payment_plan,
        summary,
        title,
        union_code,
        union_membership_requirement,
        work_shift_required,
        work_study_award_source_code,
        work_study_requirement_option_code
    from fields
)

select *
from final
