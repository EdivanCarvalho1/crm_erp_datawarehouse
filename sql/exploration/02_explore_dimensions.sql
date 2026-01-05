-- Explorar todos os países que os clientes residem

SELECT DISTINCT country FROM gold.dim_customers;

-- Explorar todas as categorias de produtos disponíveis

SELECT DISTINCT category, subcategory, product_name FROM gold.dim_products
ORDER BY category, subcategory, product_name;