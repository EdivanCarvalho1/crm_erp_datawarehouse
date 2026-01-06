-- Quais 5 produtos geram a maior receita?
SELECT
    DENSE_RANK() OVER (ORDER BY SUM(fs.sales_amount) DESC) AS revenue_rank,
    p.category,
    p.product_name,
    SUM(fs.sales_amount) AS total_revenue
FROM gold.fact_sales fs
LEFT JOIN gold.dim_products p ON fs.product_key = p.product_key
GROUP BY p.category, p.product_name
ORDER BY revenue_rank
LIMIT 5;

-- Quais os 5 produtos com menores vendas em quantidade?
SELECT
    DENSE_RANK() OVER (ORDER BY SUM(fs.sales_amount) DESC) AS revenue_rank,
    p.category,
    p.product_name,
    SUM(fs.sales_amount) AS total_revenue
FROM gold.fact_sales fs
LEFT JOIN gold.dim_products p ON fs.product_key = p.product_key
GROUP BY p.category, p.product_name
ORDER BY revenue_rank DESC
LIMIT 5;
-- Quais 5 clientes geraram a maior receita?
SELECT
    DENSE_RANK() OVER (ORDER BY SUM(fs.sales_amount) DESC) AS revenue_rank,
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(fs.sales_amount) AS total_revenue
FROM gold.fact_sales fs
LEFT JOIN gold.dim_customers c ON fs.customer_key = c.customer_key
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY revenue_rank
LIMIT 5;

-- Quais 3 clientes com menor número de pedidos?
SELECT
    DENSE_RANK() OVER (ORDER BY SUM(fs.sales_amount) DESC) AS revenue_rank,
    c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(DISTINCT fs.order_number) AS total_orders
FROM gold.fact_sales fs
LEFT JOIN gold.dim_customers c ON fs.customer_key = c.customer_key
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY revenue_rank DESC
LIMIT 3;