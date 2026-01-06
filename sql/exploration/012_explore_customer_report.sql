-- Explorar relatório detalhado por cliente
CREATE VIEW gold.report_customers AS
WITH base_query AS (
    SELECT 
        f.order_number,
        f.product_key,
        f.order_date,
        f.sales_amount,
        f.quantity,
        c.customer_key,
        c.customer_number,
        c.first_name,
        c.last_name,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        c.birthdate,
        DATE_PART('year', AGE(NOW(), c.birthdate)) AS age
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c 
        ON f.customer_key = c.customer_key
),

customer_aggregation AS (
    SELECT
        customer_key,
        customer_number,
        customer_name,
        age,
        COUNT(DISTINCT order_number) AS total_orders,
        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_quantity,
        COUNT(DISTINCT product_key) AS total_products,
        MAX(order_date) AS last_order_date,
        (
          DATE_PART('year', AGE(MAX(order_date), MIN(order_date))) * 12
          +
          DATE_PART('month', AGE(MAX(order_date), MIN(order_date)))
        ) AS lifespan
    FROM base_query
    GROUP BY 
        customer_key, 
        customer_number, 
        customer_name, 
        age
)

SELECT
    customer_key,
    customer_number,
    customer_name,
    age,
    CASE WHEN age < 18 THEN 'Under 18'
         WHEN age BETWEEN 18 AND 25 THEN '18-25'
         WHEN age BETWEEN 26 AND 35 THEN '26-35'
         WHEN age BETWEEN 36 AND 45 THEN '36-45'
         WHEN age BETWEEN 46 AND 55 THEN '46-55'
         WHEN age BETWEEN 56 AND 65 THEN '56-65'
         ELSE '66 and above'
    END AS age_group,
    CASE WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
         WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
         ELSE 'New'
    END AS customer_segment,
    last_order_date,
    (DATE_PART('year', CURRENT_DATE) * 12 + DATE_PART('month', CURRENT_DATE)) 
    - 
    (DATE_PART('year', last_order_date) * 12 + DATE_PART('month', last_order_date))
    AS recency,
    total_orders,
    total_sales,
    total_quantity,
    total_products,
    lifespan,
    CASE WHEN total_sales = 0 THEN 0
        ELSE total_sales / total_orders
    END AS avg_order_value,
    CASE WHEN lifespan = 0 THEN 0
        ELSE total_sales / lifespan
    END AS avg_monthly_spend
FROM customer_aggregation
