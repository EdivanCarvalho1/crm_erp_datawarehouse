/*
===============================================================================
Verificações de Qualidade
===============================================================================
Objetivo do Script:
    Este script realiza verificações de qualidade para validar a integridade, 
    consistência e precisão da camada Gold. Essas verificações garantem:
    - Unicidade das chaves substitutas (surrogate keys) nas tabelas de dimensão.
    - Integridade referencial entre tabelas fato e dimensão.
    - Validação dos relacionamentos no modelo de dados para fins analíticos.

Notas de Uso:
    - Investigue e resolva quaisquer inconsistências encontradas durante as verificações.
===============================================================================
*/

-- ====================================================================
-- Verificando 'gold.dim_customers'
-- ====================================================================
-- Verificar Unicidade da Chave de Cliente em gold.dim_customers
-- Expectativa: Nenhum resultado
SELECT 
    customer_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;

-- ====================================================================
-- Verificando 'gold.product_key'
-- ====================================================================
-- Verificar Unicidade da Chave de Produto em gold.dim_products
-- Expectativa: Nenhum resultado
SELECT 
    product_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;

-- ====================================================================
-- Verificando 'gold.fact_sales'
-- ====================================================================
-- Verificar a conectividade do modelo de dados entre fato e dimensões
SELECT * 
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
WHERE p.product_key IS NULL OR c.customer_key IS NULL;
