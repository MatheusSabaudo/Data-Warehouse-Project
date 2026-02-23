/*
===============================================================================
DDL Script: Create Silver Tables

Purpose: This script creates all tables in the 'silver' schema for the cleaned
         and transformed layer of the data warehouse. It drops existing tables
         (if they exist) and recreates them with the appropriate schema 
         structure. The silver layer represents data that has been cleansed,
         standardized, and enriched from the bronze layer.

Source Systems (via Bronze Layer):
         1. CRM System - Customer, Product, and Sales data
         2. ERP System - Customer, Location, and Product Category data

Key Features:
         - Includes data quality checks and transformations from bronze to silver
         - Adds audit column (dwh_create_date) to track when records were loaded
         - Maintains consistent data types and formats
         - Prepares data for business logic implementation in gold layer

Tables Created:
         - silver.crm_cust_info: Cleaned customer master data from CRM
         - silver.crm_prd_info: Cleaned product master data from CRM
         - silver.crm_sales_details: Cleaned sales transaction data from CRM
         - silver.erp_cust_az12: Cleaned customer data from ERP
         - silver.erp_loc_a101: Cleaned location data from ERP
         - silver.erp_px_cat_g1v2: Cleaned product category data from ERP

Usage Example:
         Run this script once to set up the Silver layer tables before
         executing the silver.load_silver stored procedure.
===============================================================================
*/

-- TABLE CREATION FROM THE SOURCE CRM DATASET

IF OBJECT_ID ('silver.crm_cust_info' , 'U') IS NOT NULL
	DROP TABLE silver.crm_cust_info;

CREATE TABLE silver.crm_cust_info (
	cst_id INT,
	cst_key NVARCHAR(50),
	cst_firstname NVARCHAR(50),
	cst_lastname NVARCHAR(50),
	cst_marital_status NVARCHAR(50),
	cst_gndr NVARCHAR(50),
	cst_create_date DATE,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID ('silver.crm_prd_info' , 'U') IS NOT NULL
	DROP TABLE silver.crm_prd_info;

CREATE TABLE silver.crm_prd_info (
	prd_id INT,
	cat_id NVARCHAR(50),
	prd_key NVARCHAR(50),
	prd_nm NVARCHAR(50),
	prd_cost INT,
	prd_line NVARCHAR(50),
	prd_start_dt DATE,
	prd_end_dt DATE,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID ('silver.crm_sales_details' , 'U') IS NOT NULL
	DROP TABLE silver.crm_sales_details;

CREATE TABLE silver.crm_sales_details (
	sls_ord_num NVARCHAR(50),
	sls_prd_key NVARCHAR(50),
	sls_cust_id INT,
	sls_order_dt DATE,
	sls_ship_dt DATE,
	sls_due_dt DATE,
	sls_sales INT,
	sls_quantity INT,
	sls_price INT,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);

-- TABLE CREATION FROM THE SOURCE ERP DATASET

IF OBJECT_ID ('silver.erp_cust_az12' , 'U') IS NOT NULL
	DROP TABLE silver.erp_cust_az12;

CREATE TABLE silver.erp_cust_az12 (
	cid NVARCHAR(50),
	bdate DATE,
	gen NVARCHAR(50),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID ('silver.erp_loc_a101' , 'U') IS NOT NULL
	DROP TABLE silver.erp_loc_a101;

CREATE TABLE silver.erp_loc_a101 (
	cid NVARCHAR(50),
	cntry NVARCHAR(50),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID ('silver.erp_px_cat_g1v2' , 'U') IS NOT NULL
	DROP TABLE silver.erp_px_cat_g1v2;

CREATE TABLE silver.erp_px_cat_g1v2 (
	id NVARCHAR(50),
	cat NVARCHAR(50),
	subcat NVARCHAR(50),
	maintenance NVARCHAR(50),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);