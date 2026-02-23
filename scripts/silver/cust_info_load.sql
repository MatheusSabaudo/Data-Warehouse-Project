/*
===============================================================================
Stored Procedure: silver.load_silver (CRM Customer Info Section)

Purpose: This is part of the larger silver.load_silver procedure that transforms
         and loads data from bronze to silver layer. This specific section handles
         the CRM customer information transformation.

Transformations Applied:
         1. Deduplication - Keeps only the most recent record per customer
         2. String Trimming - Removes leading/trailing spaces from text fields
         3. Value Standardization - Converts coded values to readable formats
         4. NULL Handling - Excludes records with NULL customer IDs

Source Table: bronze.crm_cust_info
Target Table: silver.crm_cust_info

Note: Quality validation is performed separately using the quality check script
===============================================================================
*/

-- =============================================================================
-- TRANSFORM AND LOAD CRM CUSTOMER INFORMATION
-- =============================================================================

PRINT '>> Truncating Table: silver.crm_cust_info';
TRUNCATE TABLE silver.crm_cust_info;

PRINT '>> Inserting Data Into: silver.crm_cust_info';
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
        ELSE 'n/a'
    END AS cst_marital_status,
    CASE 
        WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
        WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
        ELSE 'n/a'
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

PRINT '>> Load Complete: ' + CAST(@@ROWCOUNT AS NVARCHAR) + ' records inserted';
PRINT '';