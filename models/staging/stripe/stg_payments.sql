with payments as (
    select 
        ORDERID as order_id, 
        max(CREATED) as payment_finalized_date, 
        sum(AMOUNT) / 100.0 as total_amount_paid
    from {{ source('dbt_knguyen_refactor2','payments') }}
    where STATUS <> 'fail'
    group by 1
)
select * from payments