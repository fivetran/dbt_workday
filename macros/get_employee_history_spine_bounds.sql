{#- Returns the query that finds the first and last dates for the daily history spine.
    Future-dated records, such as a hire that starts next month, extend the spine, but start dates later than today plus
    `employee_history_future_months` are ignored. This stops a mistyped far-future effective date from stretching the spine,
    and the daily models, by thousands of years. -#}
{% macro get_employee_history_spine_bounds(history_relation) %}

{%- set future_cap -%}
cast({{ dbt.dateadd('month', var('employee_history_future_months', 12), dbt.current_timestamp()) }} as {{ dbt.type_timestamp() }})
{%- endset -%}

with min_max_values as (

    select
        min(_fivetran_start) as min_start,
        max(case when _fivetran_start <= {{ future_cap }} then _fivetran_start end) as max_start
    from {{ history_relation }}
)

select
    min_start,
    case when max_start >= {{ dbt.current_timestamp() }}
        then max_start
        else {{ dbt.date_trunc('day', dbt.current_timestamp()) }}
    end as max_date
from min_max_values

{% endmacro %}
