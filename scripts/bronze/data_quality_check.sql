/*
===============================================================================
Quality Check Script: Bronze CRM Customer Data

Purpose: This script performs initial data quality checks on the bronze.crm_cust_info
         table to identify data issues before transformation to the silver layer.
         It helps identify duplicates, NULL values, inconsistent formatting,
         and standardization needs.

Checks Performed:
         1. Duplicate Records and NULL ID Check
         2. Leading/Trailing Spaces in Text Fields
         3. Data Standardization Review

Usage Example:
         Run these queries after loading data into bronze layer and before
         executing silver layer transformations.
===============================================================================
*/

-- =============================================================================
-- CHECK 1: Duplicate Records and NULL ID Check
-- Identifies duplicate customer IDs and NULL values in primary key field
-- =============================================================================
SELECT 
    cst_id,
    COUNT(*) AS duplicate_count
FROM bronze.crm_cust_info
GROUP BY cst_id	
HAVING COUNT(*) > 1 OR cst_id IS NULL
ORDER BY cst_id;

-- =============================================================================
-- CHECK 2: Leading/Trailing Spaces Check
-- Identifies records with inconsistent spacing that need trimming
-- =============================================================================

-- Check firstname for leading/trailing spaces
SELECT cst_firstname
FROM bronze.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);

-- Check lastname for leading/trailing spaces
SELECT cst_lastname
FROM bronze.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);

-- Check gender for leading/trailing spaces
SELECT cst_gndr
FROM bronze.crm_cust_info
WHERE cst_gndr != TRIM(cst_gndr);

-- Check customer key for leading/trailing spaces
SELECT cst_key
FROM bronze.crm_cust_info
WHERE cst_key != TRIM(cst_key);

-- =============================================================================
-- CHECK 3: Data Standardization & Consistency
-- Reviews distinct values in key fields for standardization opportunities
-- =============================================================================

-- Review gender values for consistency (e.g., 'M', 'Male', 'F', 'Female', etc.)
SELECT DISTINCT 
    cst_gndr AS gender_values,
    COUNT(*) AS record_count
FROM bronze.crm_cust_info
GROUP BY cst_gndr
ORDER BY cst_gndr;

-- Additional standardization checks for other fields (optional)

-- Check marital status values for consistency
SELECT DISTINCT 
    cst_material_status AS marital_status_values,
    COUNT(*) AS record_count
FROM bronze.crm_cust_info
GROUP BY cst_material_status
ORDER BY cst_material_status;

-- Check for future dates in create_date
SELECT 
    cst_create_date,
    COUNT(*) AS record_count
FROM bronze.crm_cust_info
WHERE cst_create_date > GETDATE()
GROUP BY cst_create_date
ORDER BY cst_create_date;