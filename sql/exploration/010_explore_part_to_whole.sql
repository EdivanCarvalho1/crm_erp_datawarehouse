-- Quais categorias contribuem mais para receita total?
WITH category_sales AS (
SELECT
    category,
    SUM(sales_amount) AS total_sales
FROM gold.fact_sales fs
LEFT JOIN gold.dim_products p 
ON fs.product_key = p.product_key
GROUP BY category
)

SELECT
    category,
    total_sales,
    ROUND((total_sales / SUM(total_sales) OVER()) * 100, 2) AS sales_percentage
FROM category_sales
ORDER BY total_sales DESC
