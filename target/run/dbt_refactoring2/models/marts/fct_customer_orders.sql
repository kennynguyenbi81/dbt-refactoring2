
  create or replace  view analytics.dbt_knguyen_refactor2.fct_customer_orders 
  
   as (
    with 
------Source-------
orders as (
    select * from analytics.dbt_knguyen_refactor2.stg_orders
),
customers as (
    select * from analytics.dbt_knguyen_refactor2.stg_customers
),
payments as (
    select * from analytics.dbt_knguyen_refactor2.stg_payments
),

-----Logical CTEs----
total_payments_by_orders as (
    select
        order_id
        , sum(total_amount_paid)
    from payments
    group by 1
),
paid_orders as (
    select 
        orders.order_id,
        orders.customer_id,
        orders.order_placed_at,
        orders.order_status,
        payments.total_amount_paid,
        payments.payment_finalized_date,
        customers.customer_first_name,
        customers.customer_last_name
    FROM orders
    left join payments ON orders.order_id = payments.order_id
    left join customers on orders.customer_id = customers.customer_id 
),
customer_orders as (
    select customers.customer_id
        , min(orders.order_placed_at) over(
            partition by customers.customer_id
        ) as first_order_date
        , max(orders.order_placed_at) over(
            partition by customers.customer_id
        ) as most_recent_order_date
        , count(orders.order_id) over(
            partition by customers.customer_id
        ) AS number_of_orders
    from customers
    left join orders
        on orders.customer_id = customers.customer_id
),
x as (
    select
        p.order_id,
        sum(t2.total_amount_paid) as clv_bad
    from paid_orders p
    left join paid_orders t2 on p.customer_id = t2.customer_id and p.order_id >= t2.order_id
    group by 1
    order by p.order_id
),

----Final-----
final as (
    select
        p.*,
        ROW_NUMBER() OVER (ORDER BY p.order_id) as transaction_seq,
        ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY p.order_id) as customer_sales_seq,
        CASE 
            WHEN c.first_order_date = p.order_placed_at
                THEN 'new'
        ELSE 'return' END as nvsr,
        x.clv_bad as customer_lifetime_value,
        c.first_order_date as fdos
    from paid_orders p
    left join customer_orders as c using (customer_id)
    left outer join x on x.order_id = p.order_id
)
select *
from final
order by order_id
  );
