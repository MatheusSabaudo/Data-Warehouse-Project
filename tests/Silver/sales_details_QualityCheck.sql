/*
===============================================================================
Quality Check Script: Bronze CRM Sales Details

Purpose: This script performs data quality checks on the bronze.crm_sales_details
         table to identify issues before transformation to the silver layer.

Checks Performed:
         1. Invalid Ship Dates (zero, wrong length, future dates)
         2. Invalid Due Dates (zero, wrong length, future dates)
         3. Logical Date Relationships (order_dt vs ship_dt vs due_dt)
         4. Data Consistency (sales, quantity, price relationships)

Expected Issues to Flag:
         - Dates with incorrect format or out of valid range
         - Negative or zero values in numeric fields
         - Inconsistent sales calculations
         - Illogical date sequences
===============================================================================
*/

-- =============================================================================
-- CHECK 1: Invalid Ship Dates
-- Identifies ship dates that are zero, wrong length, or in the future
-- =============================================================================
SELECT
    sls_ship_dt AS invalid_ship_date,
    COUNT(*) AS record_count
FROM bronze.crm_sales_details
WHERE sls_ship_dt <= 0 
    OR LEN(sls_ship_dt) != 8 
    OR sls_ship_dt > 20270101
GROUP BY sls_ship_dt
ORDER BY sls_ship_dt;

-- =============================================================================
-- CHECK 2: Invalid Due Dates
-- Identifies due dates that are zero, wrong length, or in the future
-- =============================================================================
SELECT
    sls_due_dt AS invalid_due_date,
    COUNT(*) AS record_count
FROM bronze.crm_sales_details
WHERE sls_due_dt <= 0 
    OR LEN(sls_due_dt) != 8 
    OR sls_due_dt > 20270101
GROUP BY sls_due_dt
ORDER BY sls_due_dt;

-- =============================================================================
-- CHECK 3: Logical Date Relationships
-- Identifies records where order date is after ship date or due date
-- =============================================================================
SELECT 
    sls_ord_num,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    'Order after ship' AS issue_type
FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_ship_dt 
  AND sls_ship_dt != 0  -- Exclude zero dates from this check
UNION ALL
SELECT 
    sls_ord_num,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    'Order after due'
FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_due_dt
  AND sls_due_dt != 0  -- Exclude zero dates from this check
ORDER BY sls_ord_num;

-- =============================================================================
-- CHECK 4: Data Consistency Issues
-- Identifies records where sales, quantity, price have inconsistencies:
--   - Sales doesn't equal quantity * price
--   - Negative or zero values in any numeric field
--   - Shows both original and corrected values for comparison
-- =============================================================================
SELECT DISTINCT
    sls_sales AS old_sls_sales,
    sls_quantity,
    sls_price AS old_sls_price,
    -- Calculated correct sales value
    CASE 
        WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
            THEN sls_quantity * ABS(sls_price)
        ELSE sls_sales
    END AS corrected_sls_sales,
    -- Calculated correct price value
    CASE
        WHEN sls_price IS NULL OR sls_price <= 0
            THEN sls_sales / NULLIF(sls_quantity, 0)
        ELSE sls_price
    END AS corrected_sls_price,
    COUNT(*) AS occurrence_count
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
    OR sls_sales <= 0
    OR sls_price <= 0
    OR sls_quantity <= 0
GROUP BY 
    sls_sales,
    sls_quantity,
    sls_price,
    -- Include the calculated fields in GROUP BY
    CASE 
        WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
            THEN sls_quantity * ABS(sls_price)
        ELSE sls_sales
    END,
    CASE
        WHEN sls_price IS NULL OR sls_price <= 0
            THEN sls_sales / NULLIF(sls_quantity, 0)
        ELSE sls_price
    END
ORDER BY old_sls_sales, sls_quantity, old_sls_price;

-- =============================================================================
-- CHECK 5: Summary Statistics
-- Provides overview of data quality issues
-- =============================================================================
SELECT 
    'Total Records' AS check_description,
    COUNT(*) AS value
FROM bronze.crm_sales_details
UNION ALL
SELECT 
    'Records with Zero/Invalid Order Dates',
    COUNT(*)
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0 OR LEN(sls_order_dt) != 8
UNION ALL
SELECT 
    'Records with Zero/Invalid Ship Dates',
    COUNT(*)
FROM bronze.crm_sales_details
WHERE sls_ship_dt <= 0 OR LEN(sls_ship_dt) != 8
UNION ALL
SELECT 
    'Records with Zero/Invalid Due Dates',
    COUNT(*)
FROM bronze.crm_sales_details
WHERE sls_due_dt <= 0 OR LEN(sls_due_dt) != 8
UNION ALL
SELECT 
    'Records with Negative Sales',
    COUNT(*)
FROM bronze.crm_sales_details
WHERE sls_sales < 0
UNION ALL
SELECT 
    'Records with Negative Quantity',
    COUNT(*)
FROM bronze.crm_sales_details
WHERE sls_quantity < 0
UNION ALL
SELECT 
    'Records with Negative Price',
    COUNT(*)
FROM bronze.crm_sales_details
WHERE sls_price < 0;