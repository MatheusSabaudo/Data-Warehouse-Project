/*
===============================================================================
Quality Check Script: Silver CRM Customer Data

Purpose: This script performs post-transformation data quality validation on the 
         silver.crm_cust_info table. It verifies that data cleaning operations 
         were successful and that the silver layer meets quality standards.

Expected Results:
         - All duplicate checks should return zero records
         - All space checks should return zero records
         - Gender field should show standardized values (e.g., 'Male', 'Female')

Checks Performed:
         1. Duplicate Records Validation
         2. Leading/Trailing Spaces Validation  
         3. Data Standardization Review

Usage Example:
         Run these queries after executing silver layer transformations to
         validate data quality before proceeding to gold layer.
===============================================================================
*/

-- =============================================================================
-- CHECK 1: Duplicate Records Validation
-- Expectation: No results (0 rows returned)
-- Verifies that duplicates from bronze layer were handled correctly
-- =============================================================================
SELECT 
    cst_id,
    COUNT(*) AS duplicate_count
FROM silver.crm_cust_info
GROUP BY cst_id	
HAVING COUNT(*) > 1 OR cst_id IS NULL
ORDER BY cst_id;

-- =============================================================================
-- CHECK 2: Leading/Trailing Spaces Validation
-- Expectation: No results (0 rows returned)
-- Verifies that all text fields have been properly trimmed
-- =============================================================================

-- Validate firstname has no leading/trailing spaces
SELECT cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);

-- Validate lastname has no leading/trailing spaces  
SELECT cst_lastname
FROM silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);

-- Validate gender has no leading/trailing spaces
SELECT cst_gndr
FROM silver.crm_cust_info
WHERE cst_gndr != TRIM(cst_gndr);

-- Validate customer key has no leading/trailing spaces
SELECT cst_key
FROM silver.crm_cust_info
WHERE cst_key != TRIM(cst_key);

-- =============================================================================
-- CHECK 3: Data Standardization Validation
-- Expectation: Clean, standardized values (e.g., 'Male', 'Female', 'n/a')
-- Verifies that inconsistent values from bronze layer were standardized
-- =============================================================================

-- Validate gender values are standardized
SELECT DISTINCT 
    cst_gndr AS gender_values,
    COUNT(*) AS record_count
FROM silver.crm_cust_info
GROUP BY cst_gndr
ORDER BY cst_gndr;

-- Validate marital status values are standardized (optional check)
SELECT DISTINCT 
    cst_material_status AS marital_status_values,
    COUNT(*) AS record_count
FROM silver.crm_cust_info
GROUP BY cst_material_status
ORDER BY cst_material_status;

-- =============================================================================
-- CHECK 4: Summary Statistics
-- Provides overview of data distribution after cleaning
-- =============================================================================

-- Record count summary
SELECT 
    'Total Records' AS metric,
    COUNT(*) AS value
FROM silver.crm_cust_info

UNION ALL

SELECT 
    'Unique Customers' AS metric,
    COUNT(DISTINCT cst_id) AS value
FROM silver.crm_cust_info

UNION ALL

SELECT 
    'NULL First Names' AS metric,
    COUNT(*) AS value
FROM silver.crm_cust_info
WHERE cst_firstname IS NULL

UNION ALL

SELECT 
    'NULL Last Names' AS metric,
    COUNT(*) AS value
FROM silver.crm_cust_info
WHERE cst_lastname IS NULL

UNION ALL

SELECT 
    'NULL Gender' AS metric,
    COUNT(*) AS value
FROM silver.crm_cust_info
WHERE cst_gndr IS NULL;

-- =============================================================================
-- CHECK 5: Sample Data Review
-- Displays sample of cleaned data for visual inspection
-- =============================================================================

SELECT TOP 10 *
FROM silver.crm_cust_info
ORDER BY cst_id;