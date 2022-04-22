with customers as (
    select
        ID as customer_id,
        FIRST_NAME as customer_first_name,
        LAST_NAME as customer_last_name
    from {{ source('dbt_knguyen_refactor2','customers') }}
)
select * from customers