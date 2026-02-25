/*
===============================================================================
Silver Layer Transformation: ERP Product Category Data (px_cat_g1v2)

Purpose: This script transforms raw ERP product category data from the bronze layer 
         into clean, standardized records in the silver layer. This table contains
         product category information that will be used to enrich product data.

Transformations Applied:
         1. Direct mapping - No transformations needed as data appears clean
         2. Preserves all fields: id, cat, subcat, maintenance

Source Table: bronze.erp_px_cat_g1v2
Target Table: silver.erp_px_cat_g1v2

Note: This is a reference/lookup table with clean data, so only minimal
      transformation (trimming) is applied if needed.
===============================================================================
*/

TRUNCATE TABLE silver.erp_px_cat_g1v2;

INSERT INTO silver.erp_px_cat_g1v2 (
    id, 
    cat, 
    subcat, 
    maintenance
)
SELECT
    TRIM(id) AS id,
    TRIM(cat) AS cat,
    TRIM(subcat) AS subcat,
    TRIM(maintenance) AS maintenance
FROM bronze.erp_px_cat_g1v2
WHERE id IS NOT NULL;  -- Exclude records with NULL IDs