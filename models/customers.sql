{{ config(materialized='table') }}

with raw_customers as (
    select id as customer_id, first_name, last_name from {{ source('snowgres', 'RAW_CUSTOMERS') }}
),

raw_orders as (
    select id as order_id, user_id as customer_id, order_date from {{ source('snowgres', 'RAW_ORDERS') }}
),

raw_payments as (
    select order_id, amount from {{ source('snowgres', 'RAW_PAYMENTS') }}
),

customer_orders as (
    select
        customer_id,
        min(order_date) as first_order,
        max(order_date) as most_recent_order,
        count(order_id) as number_of_orders
    from raw_orders
    group by 1
),

customer_payments as (
    select
        o.customer_id,
        sum(p.amount) as customer_lifetime_value
    from raw_payments p
    left join raw_orders o on p.order_id = o.order_id
    group by 1
),

final as (
    select
        c.customer_id,
        c.first_name,
        c.last_name,
        co.first_order,
        co.most_recent_order,
        co.number_of_orders,
        cp.customer_lifetime_value
    from raw_customers c
    left join customer_orders co on c.customer_id = co.customer_id
    left join customer_payments cp on c.customer_id = cp.customer_id
)

select * from final
