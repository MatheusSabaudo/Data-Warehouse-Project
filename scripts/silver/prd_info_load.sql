/*
===============================================================================
Silver Layer Transformation: CRM Product Information

Purpose: This script transforms raw CRM product data from the bronze layer 
         into clean, standardized records in the silver layer. It handles:
         - Splitting composite keys into category ID and product key
         - Standardizing product line values
         - Handling NULL costs with default values
         - Managing date ranges for product validity

Transformations Applied:
         1. Key Splitting - Extracts category ID and product key from composite key
         2. Value Standardization - Converts coded product lines to readable formats
         3. NULL Handling - Replaces NULL costs with 0
         4. Date Management - Calculates end dates based on next start date

Source Table: bronze.crm_prd_info
Target Table: silver.crm_prd_info

Usage Example:
         Run this as part of the silver.load_silver stored procedure
===============================================================================
*/
TRUNCATE TABLE silver.crm_prd_info;

INSERT INTO silver.crm_prd_info (
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
	REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,          -- Extract category ID
	SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,                 -- Extract product key
	prd_nm,
	ISNULL(prd_cost, 0) AS prd_cost,                                 -- Replace NULL costs with 0
	CASE UPPER(TRIM(prd_line))                                       -- Standardize product line
		WHEN 'M' THEN 'Mountain'
		WHEN 'R' THEN 'Road'
		WHEN 'S' THEN 'Other Sales'
		WHEN 'T' THEN 'Touring'
		ELSE 'N/A'
	END AS prd_line,                                                 
	CAST(prd_start_dt AS DATE) AS prd_start_dt,
	CAST(
		DATEADD(day, -1, LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)) 
	AS DATE) AS prd_end_dt                                            -- Calculate end date as day before next start
FROM bronze.crm_prd_info
WHERE prd_id IS NOT NULL;                                            -- Exclude NULL IDs

-- =============================================================================
-- Quality Check: View Transformed Data
-- =============================================================================

-- View the transformed product data
SELECT * FROM silver.crm_prd_info ORDER BY prd_key, prd_start_dt;

-- Check for any NULL end dates (currently active products)
SELECT 
	prd_key,
	prd_nm,
	prd_start_dt,
	prd_end_dt
FROM silver.crm_prd_info
WHERE prd_end_dt IS NULL
ORDER BY prd_key;

-- Summary statistics
SELECT 
	prd_line,
	COUNT(*) AS product_count,
	MIN(prd_cost) AS min_cost,
	MAX(prd_cost) AS max_cost,
	AVG(prd_cost) AS avg_cost
FROM silver.crm_prd_info
GROUP BY prd_line
ORDER BY prd_line;