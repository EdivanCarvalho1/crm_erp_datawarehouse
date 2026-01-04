/*
===========================================================
    Script: 04_load_silver_layer.sql
    Descrição: Stored Procedure para carregar dados nas tabelas da camada silver do Data Warehouse CRM/ERP
    Autor: Edivan Carvalho
    Data: 2026-01-03

    Parâmetros: Nenhum
    Retorno: Nenhum

    Exemplo de uso:
    CALL silver.load_silver_layer();
===========================================================
*/
CREATE OR REPLACE PROCEDURE silver.load_silver_layer()
LANGUAGE plpgsql
AS $$
DECLARE
    start_time TIMESTAMP;
    end_time TIMESTAMP;
    batch_start_time TIMESTAMP;
    batch_end_time TIMESTAMP;
BEGIN
    RAISE NOTICE 'Iniciando o carregamento dos dados na camada silver...';
    batch_start_time := clock_timestamp();
    start_time := clock_timestamp();
    RAISE NOTICE 'Carregando Tabela: silver.crm_cust_info';
    TRUNCATE TABLE silver.crm_cust_info;
    INSERT INTO silver.crm_cust_info(
        cst_id,
        cst_key,
        cst_firstname,
        cst_lastname,
        cst_marital_status,
        cst_gndr,
        cst_create_date
    )
    SELECT
        cst_id,
        cst_key,
        TRIM(cst_firstname) AS cst_firstname,
        TRIM(cst_lastname) AS cst_lastname,
        CASE WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
            WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
            ELSE 'N/A'
        END cst_marital_status,
        CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
            WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
            ELSE 'N/A'
        END cst_gndr,
        cst_create_date FROM (
            SELECT *,
            ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC)
            AS flag_last 
            FROM bronze.crm_cust_info
            WHERE cst_id IS NOT NULL
        ) as subquery 
        WHERE subquery.flag_last = 1;
    end_time := clock_timestamp();
    RAISE NOTICE 'Tempo gasto para carregar silver.crm_cust_info: % minutos', EXTRACT(MINUTE FROM end_time - start_time);

    RAISE NOTICE 'Tabela Carregada: silver.crm_cust_info';

    RAISE NOTICE 'Carregando Tabela: silver.crm_prd_info';
    start_time := clock_timestamp();
    TRUNCATE TABLE silver.crm_prd_info;
    INSERT INTO silver.crm_prd_info(
        prd_id,
        cat_id,
        prd_key,
        prd_nm,
        prd_cost,
        prd_line,
        prd_start_dt,
        prd_end_dt
    )
    SELECT
        prd_id,
        REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
        SUBSTRING(prd_key, 7, LENGTH(prd_key)) AS prd_key,
        TRIM(prd_nm) as prd_nm,
        COALESCE(prd_cost, 0) as prd_cost,
        CASE WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
            WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
            WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
            WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
            ELSE 'N/A'
        END prd_line,
        CAST(prd_start_dt AS DATE) AS prd_start_dt,
        CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - INTERVAL '1 day' AS DATE) AS prd_end_dt
    FROM bronze.crm_prd_info;
    end_time := clock_timestamp();

    RAISE NOTICE 'Tempo gasto para carregar silver.crm_prd_info: % minutos', EXTRACT(MINUTE FROM end_time - start_time);

    RAISE NOTICE 'Tabela Carregada: silver.crm_prd_info';

    RAISE NOTICE 'Carregando Tabela: silver.crm_sales_details';
    start_time := clock_timestamp();

    TRUNCATE TABLE silver.crm_sales_details;
    INSERT INTO silver.crm_sales_details(
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        sls_order_dt,
        sls_ship_dt,
        sls_due_dt,
        sls_price,
        sls_quantity,
        sls_sales
    )
    SELECT
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        CASE WHEN sls_order_dt = 0 OR LENGTH(CAST(sls_order_dt AS VARCHAR)) <> 8 THEN NULL
            ELSE TO_DATE(CAST(sls_order_dt AS VARCHAR), 'YYYYMMDD')
        END AS sls_order_dt,
        CASE WHEN sls_ship_dt = 0 OR LENGTH(CAST(sls_ship_dt AS VARCHAR)) <> 8 THEN NULL
            ELSE TO_DATE(CAST(sls_ship_dt AS VARCHAR), 'YYYYMMDD')
        END AS sls_ship_dt,
        CASE WHEN sls_due_dt = 0 OR LENGTH(CAST(sls_due_dt AS VARCHAR)) <> 8 THEN NULL
            ELSE TO_DATE(CAST(sls_due_dt AS VARCHAR), 'YYYYMMDD')
        END AS sls_due_dt,
        CASE WHEN sls_price IS NULL OR sls_price <= 0
            THEN NULL
        ELSE ABS(sls_price)
        END AS sls_price,
        ABS(sls_quantity) AS sls_quantity,
        CASE WHEN sls_quantity IS NULL OR sls_price IS NULL THEN NULL
        ELSE sls_quantity * sls_price
        END AS sls_sales	
    FROM bronze.crm_sales_details;
    end_time := clock_timestamp();

    RAISE NOTICE 'Tempo gasto para carregar silver.crm_sales_details: % minutos', EXTRACT(MINUTE FROM end_time - start_time);

    RAISE NOTICE 'Tabela Carregada: silver.crm_sales_details';

    RAISE NOTICE 'Carregando Tabela: silver.erp_cust_az12';

    start_time := clock_timestamp();
    TRUNCATE TABLE silver.erp_cust_az12;
    INSERT INTO silver.erp_cust_az12(
        cid,
        bdate,
        gen
    )
    SELECT
        CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LENGTH(cid))
            ELSE cid
        END AS cid,
        CASE WHEN bdate > NOW() THEN NULL
            ELSE bdate
        END AS bdate,
        CASE WHEN UPPER((TRIM(gen))) IN ('F', 'FEMALE') THEN 'Female'
            WHEN UPPER((TRIM(gen))) IN ('M', 'MALE') THEN 'Male'
            ELSE 'N/A'
        END AS gen
    FROM bronze.erp_cust_az12;
    end_time := clock_timestamp();
    RAISE NOTICE 'Tempo gasto para carregar silver.erp_cust_az12: % minutos', EXTRACT(MINUTE FROM end_time - start_time);
    RAISE NOTICE 'Tabela Carregada: silver.erp_cust_az12';
    RAISE NOTICE 'Carregando Tabela: silver.erp_loc_a101';
    start_time := clock_timestamp();
    TRUNCATE TABLE silver.erp_loc_a101;
    INSERT INTO silver.erp_loc_a101(
        cid,
        cntry
    )
    SELECT
        REPLACE(cid, '-', '') AS cid,
        CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
            WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
            WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'N/A'
            ELSE TRIM(cntry)
        END AS cntry
    FROM bronze.erp_loc_a101;
    end_time := clock_timestamp();
    RAISE NOTICE 'Tempo gasto para carregar silver.erp_loc_a101: % minutos', EXTRACT(MINUTE FROM end_time - start_time);
    RAISE NOTICE 'Tabela Carregada: silver.erp_loc_a101';
    RAISE NOTICE 'Carregando Tabela: silver.erp_px_cat_g1v2';
    start_time := clock_timestamp();
    TRUNCATE TABLE silver.erp_px_cat_g1v2;
    INSERT INTO silver.erp_px_cat_g1v2(
        id,
        cat,
        subcat,
        maintenance
    )
    SELECT
        TRIM(id),
        TRIM(cat),
        TRIM(subcat),
        TRIM(maintenance)
    FROM bronze.erp_px_cat_g1v2;
    end_time := clock_timestamp();
    RAISE NOTICE 'Tempo gasto para carregar silver.erp_px_cat_g1v2: % minutos', EXTRACT(MINUTE FROM end_time - start_time);
    RAISE NOTICE 'Tabela Carregada: silver.erp_px_cat_g1v2';
    batch_end_time := clock_timestamp();
    RAISE NOTICE 'Duração total do carregamento da camada silver: % minutos', EXTRACT(MINUTE FROM batch_end_time - batch_start_time);
END;
$$;

CALL bronze.load_bronze_layer();