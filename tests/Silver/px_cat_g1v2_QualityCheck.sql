/*
===============================================================================
Quality Check Script: Bronze ERP Product Category Data (px_cat_g1v2)

Purpose: This script performs data quality checks on the bronze.erp_px_cat_g1v2
         table to verify data cleanliness before transformation.

Checks Performed:
         1. NULL value checks
         2. Unwanted spaces
         3. Distinct value distributions
===============================================================================
*/

-- =============================================================================
-- CHECK 1: NULL Value Checks
-- Identifies any NULL values in key fields
-- =============================================================================
SELECT 
    'NULL IDs' AS check_type,
    COUNT(*) AS record_count
FROM bronze.erp_px_cat_g1v2
WHERE id IS NULL
UNION ALL
SELECT 
    'NULL Categories',
    COUNT(*)
FROM bronze.erp_px_cat_g1v2
WHERE cat IS NULL
UNION ALL
SELECT 
    'NULL Subcategories',
    COUNT(*)
FROM bronze.erp_px_cat_g1v2
WHERE subcat IS NULL
UNION ALL
SELECT 
    'NULL Maintenance',
    COUNT(*)
FROM bronze.erp_px_cat_g1v2
WHERE maintenance IS NULL;

-- =============================================================================
-- CHECK 2: Unwanted Spaces Check
-- Identifies fields with leading/trailing spaces
-- =============================================================================
SELECT 
    'IDs with spaces' AS check_type,
    COUNT(*) AS record_count
FROM bronze.erp_px_cat_g1v2
WHERE id != TRIM(id)
UNION ALL
SELECT 
    'Categories with spaces',
    COUNT(*)
FROM bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat)
UNION ALL
SELECT 
    'Subcategories with spaces',
    COUNT(*)
FROM bronze.erp_px_cat_g1v2
WHERE subcat != TRIM(subcat)
UNION ALL
SELECT 
    'Maintenance with spaces',
    COUNT(*)
FROM bronze.erp_px_cat_g1v2
WHERE maintenance != TRIM(maintenance);

-- =============================================================================
-- CHECK 3: Distinct Value Distributions
-- Shows all unique values for each field
-- =============================================================================
SELECT DISTINCT 
    cat AS category,
    COUNT(*) OVER (PARTITION BY cat) AS record_count
FROM bronze.erp_px_cat_g1v2
ORDER BY cat;

SELECT DISTINCT 
    subcat AS subcategory,
    COUNT(*) OVER (PARTITION BY subcat) AS record_count
FROM bronze.erp_px_cat_g1v2
ORDER BY subcat;

SELECT DISTINCT 
    maintenance,
    COUNT(*) OVER (PARTITION BY maintenance) AS record_count
FROM bronze.erp_px_cat_g1v2
ORDER BY maintenance;

-- =============================================================================
-- CHECK 4: Sample Data Review
-- Shows sample records for visual inspection
-- =============================================================================
SELECT TOP 10 *
FROM bronze.erp_px_cat_g1v2
ORDER BY id;

-- =============================================================================
-- CHECK 5: Category-Subcategory Relationship Check
-- Verifies that category/subcategory relationships are consistent
-- =============================================================================
SELECT 
    cat,
    subcat,
    COUNT(*) AS combination_count
FROM bronze.erp_px_cat_g1v2
GROUP BY cat, subcat
ORDER BY cat, subcat;