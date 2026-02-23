/*
===============================================================================
Quality Check Script: Bronze CRM Product Data

Purpose: This script performs comprehensive data quality checks on the 
         bronze.crm_prd_info table to identify data issues before transformation 
         to the silver layer. It helps identify duplicates, NULL values, 
         inconsistent formatting, and logical data inconsistencies.

Checks Performed:
         1. Duplicate Records and NULL ID Check
         2. Leading/Trailing Spaces in Text Fields
         3. Invalid/Negative Values in Numeric Fields
         4. Data Standardization Review
         5. Logical Date Validation

Expected Results:
         - Duplicate check may show some products with multiple records
           (different date ranges for the same product)
         - Negative cost values should be flagged for correction
         - Date range inconsistencies should be identified
===============================================================================
*/

-- =============================================================================
-- CHECK 1: Duplicate Records and NULL ID Check
-- Identifies duplicate product IDs (may be valid if different date ranges)
-- =============================================================================

SELECT
	prd_id,
	COUNT(*) AS duplicate_count
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL
ORDER BY prd_id;

-- =============================================================================
-- CHECK 2: Leading/Trailing Spaces Check
-- Identifies text fields with inconsistent spacing
-- =============================================================================
SELECT 
    prd_id,
    prd_nm AS product_name_with_spaces
FROM bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- =============================================================================
-- CHECK 3: Invalid/Negative Values in Cost Field
-- Identifies cost values that are negative or NULL
-- =============================================================================
SELECT 
    prd_id,
    prd_nm,
    prd_cost,
    prd_line
FROM bronze.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL
ORDER BY prd_cost;

-- =============================================================================
-- CHECK 4: Data Standardization - Product Line Values
-- Reviews distinct product line values for standardization
-- =============================================================================
SELECT DISTINCT 
    prd_line AS product_line_values,
    COUNT(*) AS record_count
FROM bronze.crm_prd_info
GROUP BY prd_line
ORDER BY prd_line;

-- =============================================================================
-- CHECK 5: Logical Date Validation
-- Identifies records where end date is before start date (invalid)
-- =============================================================================
SELECT 
    prd_id,
    prd_nm,
    prd_start_dt,
    prd_end_dt,
    DATEDIFF(day, prd_start_dt, prd_end_dt) AS days_difference
FROM bronze.crm_prd_info
WHERE prd_end_dt < prd_start_dt
ORDER BY prd_start_dt;

-- =============================================================================
-- CHECK 6: Additional Quality Checks
-- =============================================================================

-- Check for NULL values in key fields
SELECT 
    'NULL Product Names' AS check_type,
    COUNT(*) AS record_count
FROM bronze.crm_prd_info
WHERE prd_nm IS NULL
UNION ALL
SELECT 
    'NULL Product Keys',
    COUNT(*)
FROM bronze.crm_prd_info
WHERE prd_key IS NULL
UNION ALL
SELECT 
    'NULL Start Dates',
    COUNT(*)
FROM bronze.crm_prd_info
WHERE prd_start_dt IS NULL;

-- Check for future start dates
SELECT 
    prd_id,
    prd_nm,
    prd_start_dt
FROM bronze.crm_prd_info
WHERE prd_start_dt > GETDATE()
ORDER BY prd_start_dt;

-- =============================================================================
-- CHECK 7: Data Profiling Summary
-- Provides overview of data distribution
-- =============================================================================

-- Record count by product line
SELECT 
    prd_line,
    COUNT(*) AS record_count,
    MIN(prd_cost) AS min_cost,
    MAX(prd_cost) AS max_cost,
    AVG(prd_cost) AS avg_cost
FROM bronze.crm_prd_info
GROUP BY prd_line
ORDER BY prd_line;

-- Sample of data for review
SELECT TOP 20 *
FROM bronze.crm_prd_info
ORDER BY prd_id, prd_start_dt;