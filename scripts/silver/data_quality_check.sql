-- Check for unwanted spaces
-- Expectation: No results

SELECT 
cst_id,
COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id	
HAVING COUNT(*) > 1 OR cst_id IS NULL

SELECT cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)

SELECT cst_lastname
FROM silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname)

SELECT cst_gndr
FROM silver.crm_cust_info
WHERE cst_gndr != TRIM(cst_gndr)

SELECT cst_key
FROM silver.crm_cust_info
WHERE cst_key != TRIM(cst_key)

-- Data Standardization& Consistency

SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info