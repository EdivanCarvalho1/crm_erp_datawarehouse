-- Total de Vendas
SELECT SUM(sales_amount) AS total_sales
FROM gold.fact_sales;

-- Total de Itens Vendidos
SELECT SUM(quantity) AS total_items_sold
FROM gold.fact_sales;

-- Total de Pedidos
SELECT COUNT(DISTINCT order_number) AS total_orders
FROM gold.fact_sales;

-- Total de Produtos Cadastrados
SELECT COUNT(product_id) AS total_products
FROM gold.dim_products;

-- Total de Clientes Cadastrados
SELECT COUNT(customer_id) AS total_customers
FROM gold.dim_customers;

-- Total de Clientes que realizaram compras
SELECT COUNT(DISTINCT customer_key) AS total_customers_with_purchases
FROM gold.fact_sales;

-- Gerar relatório consolidado com todas as medidas principais

SELECT 'Total Sales' AS measure, SUM(sales_amount) AS measure_value
FROM gold.fact_sales
UNION ALL
SELECT 'Total Quantity' AS measure, SUM(quantity) AS measure_value
FROM gold.fact_sales
UNION ALL
SELECT 'Average Price per Item' AS measure, AVG(price) AS measure_value
FROM gold.fact_sales
UNION ALL
SELECT 'Total Orders' AS measure, COUNT(DISTINCT order_number) AS measure_value
FROM gold.fact_sales
UNION ALL
SELECT 'Total Products' AS measure, COUNT(product_id) AS measure_value
FROM gold.dim_products
UNION ALL
SELECT 'Total Customers' AS measure, COUNT(customer_id) AS measure_value
FROM gold.dim_customers
       