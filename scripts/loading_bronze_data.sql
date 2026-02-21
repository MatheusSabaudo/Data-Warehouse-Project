CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY
		SET @batch_start_time = GETDATE();

		PRINT '=========================================';
		PRINT '		 LOADING THE BRONZE LAYER...';
		PRINT '=========================================';


		PRINT '-----------------------------------------';
		PRINT '			LOADING CRM TABLES';
		PRINT '-----------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.crm_cust_info';
		TRUNCATE TABLE bronze.crm_cust_info;

		PRINT '>> Inserting Data Into: bronze.crm_cust_info';
		BULK INSERT bronze.crm_cust_info
		FROM 'C:\Users\matte\Desktop\Data Engineering\Data-Warehouse-Project\datasets\source_crm\cust_info.csv' -- ADD YOUR SOURCE CRM FILE PATH HERE
		WITH (
			FIRSTROW = 2, -- IGNORE COLUMN NAME
			FIELDTERMINATOR = ',', -- SEPARATOR USED
			TABLOCK -- LOCK THE TABLE WHILE R/W
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '----------------------------------------';
		PRINT '';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.crm_prd_info';
		TRUNCATE TABLE bronze.crm_prd_info;

		PRINT '>> Inserting Data Into: bronze.crm_prd_info';
		BULK INSERT bronze.crm_prd_info
		FROM 'C:\Users\matte\Desktop\Data Engineering\Data-Warehouse-Project\datasets\source_crm\prd_info.csv' -- ADD YOUR SOURCE CRM FILE PATH HERE
		WITH (
			FIRSTROW = 2, -- IGNORE COLUMN NAME
			FIELDTERMINATOR = ',', -- SEPARATOR USED
			TABLOCK -- LOCK THE TABLE WHILE R/W
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '----------------------------------------';
		PRINT '';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.crm_sales_details';
		TRUNCATE TABLE bronze.crm_sales_details;

		PRINT '>> Inserting Data Into: bronze.crm_sales_details';
		BULK INSERT bronze.crm_sales_details
		FROM 'C:\Users\matte\Desktop\Data Engineering\Data-Warehouse-Project\datasets\source_crm\sales_details.csv' -- ADD YOUR SOURCE CRM FILE PATH HERE
		WITH (
			FIRSTROW = 2, -- IGNORE COLUMN NAME
			FIELDTERMINATOR = ',', -- SEPARATOR USED
			TABLOCK -- LOCK THE TABLE WHILE R/W
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '';

		-- CRM
		---------------------------------------------------------------------------
		-- ERP

		PRINT '-----------------------------------------';
		PRINT '			LOADING ERP TABLES';
		PRINT '-----------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_cust_az12';
		TRUNCATE TABLE bronze.erp_cust_az12;

		PRINT '>> Inserting Data Into: bronze.erp_cust_az12';
		BULK INSERT bronze.erp_cust_az12
		FROM 'C:\Users\matte\Desktop\Data Engineering\Data-Warehouse-Project\datasets\source_erp\cust_az12.csv' -- ADD YOUR SOURCE CRM FILE PATH HERE
		WITH (
			FIRSTROW = 2, -- IGNORE COLUMN NAME
			FIELDTERMINATOR = ',', -- SEPARATOR USED
			TABLOCK -- LOCK THE TABLE WHILE R/W
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '----------------------------------------';
		PRINT '';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_loc_a101';
		TRUNCATE TABLE bronze.erp_loc_a101;

		PRINT '>> Inserting Data Into: bronze.erp_loc_a101';
		BULK INSERT bronze.erp_loc_a101
		FROM 'C:\Users\matte\Desktop\Data Engineering\Data-Warehouse-Project\datasets\source_erp\loc_a101.csv' -- ADD YOUR SOURCE CRM FILE PATH HERE
		WITH (
			FIRSTROW = 2, -- IGNORE COLUMN NAME
			FIELDTERMINATOR = ',', -- SEPARATOR USED
			TABLOCK -- LOCK THE TABLE WHILE R/W
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '----------------------------------------';
		PRINT '';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_px_cat_g1v2';
		TRUNCATE TABLE bronze.erp_px_cat_g1v2;

		PRINT '>> Inserting Data Into: bronze.erp_px_cat_g1v2';
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'C:\Users\matte\Desktop\Data Engineering\Data-Warehouse-Project\datasets\source_erp\px_cat_g1v2.csv' -- ADD YOUR SOURCE CRM FILE PATH HERE
		WITH (
			FIRSTROW = 2, -- IGNORE COLUMN NAME
			FIELDTERMINATOR = ',', -- SEPARATOR USED
			TABLOCK -- LOCK THE TABLE WHILE R/W
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '----------------------------------------';
		PRINT '';

		SET @batch_end_time = GETDATE();
		PRINT '>> Bronze Layer Load Finished!';
		PRINT '>> Total Load Duration: ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT '----------------------------------------';
		PRINT '';

	END TRY

	BEGIN CATCH
		PRINT '=========================================================================';
		PRINT '				 ERROR OCCURED DURING LOADING BRONZE LAYER';
		PRINT 'Error Message: ' + ERROR_MESSAGE();
		PRINT 'Error Number: ' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error State: ' + ERROR_STATE();
		PRINT '=========================================================================';
	END CATCH

END