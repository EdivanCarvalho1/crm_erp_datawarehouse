-- Encontrar a data do primeiro e do último pedido na tabela de fatos de vendas
-- Quantos anos de dados de vendas estão disponíveis?
SELECT 
    MIN(order_date) AS first_order_date, 
    MAX(order_date) AS last_order_date,
    EXTRACT(YEAR FROM AGE(MAX(order_date), MIN(order_date))) AS years_of_data
FROM gold.fact_sales;

-- Encontrar o cliente com menor idade e maior idade na tabela de clientes
SELECT
    MIN(birthdate) AS oldest_customer_birth_date,
    MAX(birthdate) AS youngest_customer_birth_date,
    EXTRACT(YEAR FROM AGE(NOW(), MIN(birthdate))) AS youngest_age,
    EXTRACT(YEAR FROM AGE(NOW(), MAX(birthdate))) AS oldest_age,
    EXTRACT(YEAR FROM AGE(MAX(birthdate), MIN(birthdate))) AS age_range_years
FROM gold.dim_customers;
-- Evolução mensal do número de pedidos ao longo do tempo
SELECT
    DATE_TRUNC('month', order_date) AS month,
    COUNT(DISTINCT order_number) AS total_orders
FROM gold.fact_sales
GROUP BY month
ORDER BY month;
-- Evolução mensal da receita total ao longo do tempo
SELECT
    DATE_TRUNC('month', order_date) AS month,
    SUM(sales_amount) AS total_revenue
FROM gold.fact_sales
GROUP BY month
ORDER BY month;
