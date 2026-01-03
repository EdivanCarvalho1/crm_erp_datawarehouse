CREATE OR REPLACE PROCEDURE bronze.load_bronze_layer()
LANGUAGE plpgsql
AS $$
DECLARE
    start_date TIMESTAMP;
    end_date TIMESTAMP;
BEGIN

    RAISE NOTICE 'Iniciando o carregamento dos dados na camada bronze...';

    start_date := clock_timestamp();

    TRUNCATE TABLE bronze.crm_cust_info;
    COPY bronze.crm_cust_info
    FROM 'D:\projects\crm_erp_datawarehouse\datasets\source_crm\cust_info.csv'
    WITH (
        FORMAT csv,
        HEADER true,
        DELIMITER ','
    );
    TRUNCATE TABLE bronze.crm_prd_info;
    COPY bronze.crm_prd_info
    FROM 'D:\projects\crm_erp_datawarehouse\datasets\source_crm\prd_info.csv'
    WITH (
        FORMAT csv,
        HEADER true,
        DELIMITER ','
    );
    TRUNCATE TABLE bronze.crm_sales_details;
    COPY bronze.crm_sales_details
    FROM 'D:\projects\crm_erp_datawarehouse\datasets\source_crm\sales_details.csv'
    WITH (
        FORMAT csv,
        HEADER true,
        DELIMITER ','
    );
    TRUNCATE TABLE bronze.erp_cust_az12;
    COPY bronze.erp_cust_az12
    FROM 'D:\projects\crm_erp_datawarehouse\datasets\source_erp\CUST_AZ12.csv'
    WITH (
        FORMAT csv,
        HEADER true,
        DELIMITER ','
    );
    TRUNCATE TABLE bronze.erp_loc_a101;
    COPY bronze.erp_loc_a101
    FROM 'D:\projects\crm_erp_datawarehouse\datasets\source_erp\LOC_A101.csv'
    WITH (
        FORMAT csv,
        HEADER true,
        DELIMITER ','
    );

    TRUNCATE TABLE bronze.erp_px_cat_g1v2;
    COPY bronze.erp_px_cat_g1v2
    FROM 'D:\projects\crm_erp_datawarehouse\datasets\source_erp\PX_CAT_G1V2.csv'
    WITH (
        FORMAT csv,
        HEADER true,
        DELIMITER ','
    );

    end_date := clock_timestamp();

    RAISE NOTICE
        'Duração do carregamento: % minutos',
        ROUND(EXTRACT(EPOCH FROM (end_date - start_date)) / 60, 2);

    RAISE NOTICE 'Carregamento dos dados na camada bronze concluído com sucesso.';
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING 'Um erro ocorreu ao carregar dados na camada bronze: %', SQLERRM;
END;
$$;