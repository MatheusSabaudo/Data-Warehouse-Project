/*
===============================================================================
Silver Layer Transformation: ERP Location Data (loc_a101)

Purpose: This script transforms raw ERP location data from the bronze layer 
         into clean, standardized records in the silver layer. It handles:
         - Customer ID cleanup (removing hyphens)
         - Country name standardization

Transformations Applied:
         1. Customer ID - Removes hyphens to match with CRM/Cust format
         2. Country - Standardizes country codes to full names:
            - 'DE' -> 'Germany'
            - 'US', 'USA' -> 'United States'
            - Empty or NULL -> 'N/A'
            - Other values are trimmed and kept as-is

Source Table: bronze.erp_loc_a101
Target Table: silver.erp_loc_a101
===============================================================================
*/

INSERT INTO silver.erp_loc_a101 (
    cid, 
    cntry
)
SELECT 
    -- Customer ID: Remove hyphens to match with other tables
    REPLACE(cid, '-', '') AS cid,
    
    -- Country: Standardize codes to full names
    CASE
        WHEN TRIM(cntry) = 'DE' THEN 'Germany'
        WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
        WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'N/A'
        ELSE TRIM(cntry)
    END AS cntry
    
FROM bronze.erp_loc_a101;