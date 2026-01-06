
WITH yearly_sales AS (
    SELECT
        EXTRACT(YEAR FROM f.order_date) AS order_year,
        p.product_name,
        SUM(f.sales_amount) AS current_sales
    FROM
        gold.fact_sales f
    LEFT JOIN gold.dim_products p ON f.product_key = p.product_key
    WHERE order_date IS NOT NULL
    GROUP BY
        EXTRACT(YEAR FROM f.order_date),
        p.product_name
)

SELECT
    order_year,
    product_name,
    current_sales,
    ROUND(AVG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year), 2) as avg_sales,
    current_sales - ROUND(AVG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year), 2) AS sales_performance,
    CASE WHEN current_sales - ROUND(AVG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year), 2) > 0 THEN 'Above Average'
         WHEN current_sales - ROUND(AVG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year), 2) < 0 THEN 'Below Average'
         ELSE 'Average'
    END AS performance_category,
    LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS previous_year_sales,
    current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS sales_change,
    CASE WHEN current_sales - LAG (current_sales) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
         WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
         ELSE 'No Change'
    END AS change_direction
FROM yearly_sales;