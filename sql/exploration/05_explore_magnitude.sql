-- Total de Clientes por País
SELECT 
    country, 
    COUNT(DISTINCT customer_id) AS total_customers
FROM gold.dim_customers
GROUP BY country
ORDER BY total_customers DESC;
-- Total de Clientes por Gênero
SELECT
    gender,
    COUNT(DISTINCT customer_id) AS total_customers
FROM gold.dim_customers
GROUP BY gender
ORDER BY total_customers DESC;
-- Total de Produtos por Categoria
SELECT
    category,
    COUNT(product_id) AS total_products
FROM gold.dim_products
GROUP BY category
ORDER BY total_products DESC;
-- Preço médio por categoria de produto
SELECT
    category,
    ROUND(AVG(cost), 2) as average_price
FROM gold.dim_products
GROUP BY category
ORDER BY average_price DESC;
-- Total de Receita por Categoria de Produto
SELECT
    p.category,
    SUM(s.sales_amount) AS total_revenue
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p ON s.product_key = p.product_key
GROUP BY p.category
ORDER BY total_revenue DESC;
-- Itens vendidos por país
SELECT
    c.country,
    SUM(s.quantity) AS total_items_sold
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c ON s.customer_key = c.customer_key
GROUP BY c.country
ORDER BY total_items_sold DESC;