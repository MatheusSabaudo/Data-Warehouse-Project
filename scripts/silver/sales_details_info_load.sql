/*
===============================================================================
Silver Layer Transformation: CRM Sales Details

Purpose: This script transforms raw CRM sales data from the bronze layer 
         into clean, standardized records in the silver layer.

Transformations Applied:
         1. Date Validation - Converts integer dates to proper DATE format
         2. Sales Calculation - Ensures data consistency between fields
         3. Price Derivation - Calculates unit price when missing/invalid

Source Table: bronze.crm_sales_details
Target Table: silver.crm_sales_details
===============================================================================
*/

INSERT INTO silver.crm_sales_details (
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	sls_order_dt,
	sls_ship_dt,
	sls_due_dt,
	sls_sales,
	sls_quantity,
	sls_price
)
SELECT
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	
	-- Date validation and conversion for order date
	CASE
		WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
		ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
	END AS sls_order_dt,

	-- Date validation and conversion for ship date
	CASE
		WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
		ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
	END AS sls_ship_dt,

	-- Date validation and conversion for due date
	CASE
		WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
		ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
	END AS sls_due_dt,

	-- Sales amount calculation/validation
	CASE 
		WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
			THEN sls_quantity * ABS(sls_price)
		ELSE sls_sales
	END AS sls_sales,

	sls_quantity,

	-- Price calculation/validation
	CASE
		WHEN sls_price IS NULL OR sls_price <= 0
			THEN sls_sales / NULLIF(sls_quantity, 0)
		ELSE sls_price
	END AS sls_price

FROM bronze.crm_sales_details;