-- Explorar vendas acumuladas ao longo do tempo
SELECT
    order_month,
    total_sales,
    SUM(total_sales) OVER(PARTITION BY order_month ORDER BY order_month) AS running_total_sales
    FROM(
        SELECT
            DATE_TRUNC('month', s.order_date) AS order_month,
            SUM(s.sales_amount) AS total_sales
        FROM gold.fact_sales s
        GROUP BY order_month
        ORDER BY order_month
    )
    