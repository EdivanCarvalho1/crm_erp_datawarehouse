--- Segmentação de Produtos com base no custo
WITH product_segments AS (
SELECT
    product_key,
    product_name,
    cost,
    CASE WHEN cost < 100 THEN 'Below 100'
         WHEN cost BETWEEN 100 AND 500 THEN '100-500'
         WHEN cost BETWEEN 501 AND 1000 THEN '501-1000'
         ELSE 'Above 1000'
    END AS cost_range
FROM gold.dim_products
)

SELECT
    cost_range,
    COUNT(product_key) AS total_products
FROM product_segments
GROUP BY cost_range
ORDER BY total_products DESC;
--- Segmentação de Clientes com base em gastos e tempo como cliente
WITH customer_spending AS (
SELECT
    c.customer_key,
    SUM(f.sales_amount) AS total_spending,
    MIN(f.order_date) AS first_order,
    MAX(f.order_date) AS last_order,
    (
          DATE_PART('year', AGE(MAX(f.order_date), MIN(f.order_date))) * 12
          +
          DATE_PART('month', AGE(MAX(f.order_date), MIN(f.order_date)))
    ) AS lifespan
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c 
ON f.customer_key = c.customer_key
GROUP BY c.customer_key
)

SELECT
    customer_segment,
    COUNT(customer_key) AS total_customers
FROM (
SELECT
    customer_key,
    total_spending,
    lifespan,
    CASE WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
        WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
        ELSE 'New'
    END AS customer_segment
FROM customer_spending
) cs
GROUP BY customer_segment