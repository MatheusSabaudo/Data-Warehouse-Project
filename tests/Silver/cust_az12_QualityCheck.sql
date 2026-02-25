/*
===============================================================================
Quality Check Script: Bronze ERP Customer Data (cust_az12)

Purpose: This script performs data quality checks on the bronze.erp_cust_az12
         table to identify issues before transformation to the silver layer.

Checks Performed:
         1. Invalid Birth Dates (too old or future dates)
         2. Gender Value Distribution (identify standardization needs)

Expected Issues to Flag:
         - Birth dates that are unreasonably old (before 1924)
         - Birth dates in the future
         - Inconsistent gender values needing standardization
===============================================================================
*/

-- =============================================================================
-- CHECK 1: Invalid Birth Dates
-- Identifies birth dates that are either:
--   - Too old (before 1924 - would make customers 100+ years old)
--   - In the future (not yet born)
-- =============================================================================
SELECT DISTINCT 
    bdate AS invalid_birth_date,
    COUNT(*) OVER (PARTITION BY bdate) AS occurrence_count
FROM bronze.erp_cust_az12
WHERE bdate < '1924-01-01' 
   OR bdate > GETDATE()
ORDER BY bdate;

-- =============================================================================
-- CHECK 2: Gender Value Distribution
-- Shows all distinct gender values in the source data to identify
-- what values need to be standardized in the transformation
-- =============================================================================
SELECT DISTINCT 
    gen AS gender_values,
    COUNT(*) OVER (PARTITION BY gen) AS occurrence_count
FROM bronze.erp_cust_az12
ORDER BY gen;

-- =============================================================================
-- CHECK 3: Additional Context - Sample Records with Invalid Birth Dates
-- Shows full records with invalid birth dates for better understanding
-- =============================================================================
SELECT 
    cid,
    bdate,
    gen
FROM bronze.erp_cust_az12
WHERE bdate < '1924-01-01' 
   OR bdate > GETDATE()
ORDER BY bdate;

-- =============================================================================
-- CHECK 4: NULL or Missing Values Check
-- Identifies records with missing critical data
-- =============================================================================
SELECT 
    'NULL Customer IDs' AS check_type,
    COUNT(*) AS record_count
FROM bronze.erp_cust_az12
WHERE cid IS NULL OR TRIM(cid) = ''
UNION ALL
SELECT 
    'NULL Birth Dates',
    COUNT(*)
FROM bronze.erp_cust_az12
WHERE bdate IS NULL
UNION ALL
SELECT 
    'NULL Gender',
    COUNT(*)
FROM bronze.erp_cust_az12
WHERE gen IS NULL OR TRIM(gen) = '';

-- =============================================================================
-- CHECK 5: Summary Statistics
-- Provides overview of data quality issues
-- =============================================================================
SELECT 
    'Total Records' AS metric,
    COUNT(*) AS value
FROM bronze.erp_cust_az12
UNION ALL
SELECT 
    'Records with Birth Dates < 1924',
    COUNT(*)
FROM bronze.erp_cust_az12
WHERE bdate < '1924-01-01'
UNION ALL
SELECT 
    'Records with Future Birth Dates',
    COUNT(*)
FROM bronze.erp_cust_az12
WHERE bdate > GETDATE()
UNION ALL
SELECT 
    'Distinct Gender Values',
    COUNT(DISTINCT gen)
FROM bronze.erp_cust_az12;