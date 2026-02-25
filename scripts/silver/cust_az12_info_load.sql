/*
===============================================================================
Silver Layer Transformation: ERP Customer Data (cust_az12)

Purpose: This script transforms raw ERP customer data from the bronze layer 
         into clean, standardized records in the silver layer. It handles:
         - Customer ID standardization (removing 'NAS' prefix)
         - Birth date validation (future dates set to NULL)
         - Gender standardization to consistent format

Transformations Applied:
         1. Customer ID - Removes 'NAS' prefix if present to match with CRM IDs
         2. Birth Date - Validates dates and sets future dates to NULL
         3. Gender - Standardizes to 'Male', 'Female', or 'N/A'

Source Table: bronze.erp_cust_az12
Target Table: silver.erp_cust_az12
===============================================================================
*/

TRUNCATE TABLE silver.erp_cust_az12;

INSERT INTO silver.erp_cust_az12 (
    cid, 
    bdate, 
    gen
)
SELECT
    -- Customer ID: Remove 'NAS' prefix if present to match CRM format
    CASE
        WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
        ELSE cid
    END AS cid,
    
    -- Birth Date: Set future dates to NULL (invalid)
    CASE
        WHEN bdate > GETDATE() THEN NULL
        ELSE bdate
    END AS bdate,
    
    -- Gender: Standardize to 'Male', 'Female', or 'N/A'
    CASE
        WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
        WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
        ELSE 'N/A'
    END AS gen
    
FROM bronze.erp_cust_az12;