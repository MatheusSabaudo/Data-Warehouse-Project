/*
===============================================================================
Quality Check Script: Bronze ERP Location Data (loc_a101)

Purpose: This script performs data quality checks on the bronze.erp_loc_a101
         table to identify country value standardization needs before 
         transformation to the silver layer.

Checks Performed:
         1. Distinct Country Values - Shows original vs standardized mapping
         
Expected Output:
         - View all unique country values and how they will be transformed
         - Identify any unexpected values that may need handling
===============================================================================
*/

-- =============================================================================
-- CHECK 1: Country Value Standardization Mapping
-- Shows all distinct country values from source and how they will be
-- transformed in the silver layer
-- =============================================================================
SELECT DISTINCT
    cntry AS old_cntry,
    CASE
        WHEN TRIM(cntry) = 'DE' THEN 'Germany'
        WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
        WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'N/A'
        ELSE TRIM(cntry)
    END AS standardized_cntry
FROM bronze.erp_loc_a101
ORDER BY standardized_cntry, old_cntry;

-- =============================================================================
-- CHECK 2: Count Distribution by Original Country
-- Shows how many records exist for each original value
-- =============================================================================
SELECT 
    cntry AS original_country,
    COUNT(*) AS record_count,
    CASE
        WHEN TRIM(cntry) = 'DE' THEN 'Germany'
        WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
        WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'N/A'
        ELSE TRIM(cntry)
    END AS target_country
FROM bronze.erp_loc_a101
GROUP BY cntry
ORDER BY target_country, original_country;

-- =============================================================================
-- CHECK 3: NULL or Empty Values Check
-- Specifically identifies records with missing country data
-- =============================================================================
SELECT 
    'Empty or NULL Countries' AS check_type,
    COUNT(*) AS record_count
FROM bronze.erp_loc_a101
WHERE cntry IS NULL OR TRIM(cntry) = '';

-- =============================================================================
-- CHECK 4: Customer ID Format Check
-- Shows examples of customer IDs with/without hyphens
-- =============================================================================
SELECT TOP 10
    cid AS original_cid,
    REPLACE(cid, '-', '') AS cleaned_cid
FROM bronze.erp_loc_a101
WHERE cid LIKE '%-%'  -- Only show IDs that actually have hyphens
ORDER BY cid;