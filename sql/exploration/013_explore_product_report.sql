CREATE OR REPLACE VIEW gold.report_products AS
WITH base_query AS (
    SELECT
        f.order_number,
        f.order_date,
        f.product_key,
        f.customer_key,
        f.sales_amount,
        f.quantity,
        p.product_name,
        p.category,
        p.subcategory,
        p.cost
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p 
        ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
),

product_aggregations AS (
    SELECT
        product_key,
        product_name,
        category,
        subcategory,
        cost,

        (
            DATE_PART('year', AGE(MAX(order_date), MIN(order_date))) * 12
            +
            DATE_PART('month', AGE(MAX(order_date), MIN(order_date)))
        ) AS lifespan,

        MAX(order_date) AS last_sale_date,
        COUNT(DISTINCT order_number) AS total_orders,
        COUNT(DISTINCT customer_key) AS total_customers,
        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_quantity,

        ROUND(
            AVG(sales_amount / NULLIF(quantity, 0)), 
            2
        ) AS avg_selling_price

    FROM base_query
    GROUP BY 
        product_key,
        product_name,
        category,
        subcategory,
        cost
)

SELECT 
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    last_sale_date,

    (
        DATE_PART('year', CURRENT_DATE) * 12 
        + DATE_PART('month', CURRENT_DATE)
    ) -
    (
        DATE_PART('year', last_sale_date) * 12 
        + DATE_PART('month', last_sale_date)
    ) AS recency_in_months,

    CASE
        WHEN total_sales > 50000 THEN 'High-Performer'
        WHEN total_sales >= 10000 THEN 'Mid-Range'
        ELSE 'Low-Performer'
    END AS product_segment,

    lifespan,
    total_orders,
    total_sales,
    total_quantity,
    total_customers,
    avg_selling_price,

    CASE 
        WHEN total_orders = 0 THEN 0
        ELSE total_sales / total_orders
    END AS avg_order_revenue,

    CASE
        WHEN lifespan = 0 THEN total_sales
        ELSE total_sales / lifespan
    END AS avg_monthly_revenue

FROM product_aggregations;
