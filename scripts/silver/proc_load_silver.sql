/*
===============================================================================
Silver Layer Transformation: CRM Customer Information

Purpose: This script transforms raw CRM customer data from the bronze layer 
         into clean, standardized records in the silver layer. It handles 
         deduplication, string trimming, and value standardization.

Transformations Applied:
         1. Deduplication - Keeps only the most recent record per customer
         2. String Trimming - Removes leading/trailing spaces from text fields
         3. Value Standardization - Converts coded values to readable formats:
            - Marital Status: 'S' -> 'Single', 'M' -> 'Married', else 'N/A'
            - Gender: 'F' -> 'Female', 'M' -> 'Male', else 'N/A'
         4. NULL Handling - Excludes records with NULL customer IDs

Source Table: bronze.crm_cust_info
Target Table: silver.crm_cust_info

Usage Example:
         Run this as part of the silver.load_silver stored procedure or
         independently for incremental loads.
===============================================================================
*/

TRUNCATE TABLE silver.crm_cust_info;

INSERT INTO silver.crm_cust_info (
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
	CASE
		WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
		WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
		ELSE 'N/A'
	END AS cst_marital_status,
	CASE
		WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
		WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
		ELSE 'N/A'
	END AS cst_gndr,
	cst_create_date
FROM (
	SELECT 
		*,
		ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
	FROM bronze.crm_cust_info
	WHERE cst_id IS NOT NULL
) t 
WHERE flag_last = 1;

-- =============================================================================
-- Quality Check: View Transformed Data
-- Purpose: Quick review of the loaded silver data
-- =============================================================================

-- View all records in silver layer
SELECT * FROM silver.crm_cust_info;

-- Summary statistics of transformed data
SELECT 
	'Total Records' AS metric,
	COUNT(*) AS value
FROM silver.crm_cust_info
UNION ALL
SELECT 
	'Unique Customers',
	COUNT(DISTINCT cst_id)
FROM silver.crm_cust_info
UNION ALL
SELECT 
	'Marital Status Distribution',
	COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_marital_status
UNION ALL
SELECT 
	'Gender Distribution',
	COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_gndr;

-- Sample of standardized values
SELECT DISTINCT 
	cst_marital_status,
	cst_gndr,
	COUNT(*) AS record_count
FROM silver.crm_cust_info
GROUP BY cst_marital_status, cst_gndr
ORDER BY cst_marital_status, cst_gndr;