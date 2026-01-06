--- Explorar mudanças ao longo do tempo nas vendas mensais
SELECT
    DATE_TRUNC('month', s.order_date) AS order_month,
    SUM(s.sales_amount) AS total_sales,
    COUNT(DISTINCT s.order_number) AS total_orders,
    SUM(s.quantity) AS total_items_sold
FROM gold.fact_sales s
GROUP BY order_month
ORDER BY order_month;