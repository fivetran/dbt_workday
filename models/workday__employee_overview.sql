with employee_surrogate_key as (
    
    select 
        {{ dbt_utils.generate_surrogate_key(['worker_id', 'position_id', 'position_start_date']) }} as employee_id,
        worker_id,
        position_id,
        position_start_date,
        {{ dbt_utils.star(ref('int_workday__worker_employee_enhanced'), except=['worker_id', 'position_id', 'position_start_date']) }}
    from {{ ref('int_workday__worker_employee_enhanced') }} 
)

select * 
from employee_surrogate_key