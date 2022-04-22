
  create or replace  view analytics.dbt_knguyen_refactor2.stg_orders 
  
   as (
    with orders as (
    select
        ID as order_id,
        USER_ID as customer_id,
        ORDER_DATE as order_placed_at,
        STATUS as order_status
    from analytics.dbt_knguyen_refactor2.orders
)
select * from orders
  );
