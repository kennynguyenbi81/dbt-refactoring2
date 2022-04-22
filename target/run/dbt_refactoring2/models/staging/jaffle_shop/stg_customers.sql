
  create or replace  view analytics.dbt_knguyen_refactor2.stg_customers 
  
   as (
    with customers as (
    select
        ID as customer_id,
        FIRST_NAME as customer_first_name,
        LAST_NAME as customer_last_name
    from analytics.dbt_knguyen_refactor2.customers
)
select * from customers
  );
