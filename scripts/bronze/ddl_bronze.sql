/*
===============================================================================
DDL Script: Create Bronze Tables

Purpose: This script creates all tables in the 'bronze' schema for the initial
         data ingestion layer of the data warehouse. It drops existing tables
         (if they exist) and recreates them with the appropriate schema 
         structure to match the source CSV files from CRM and ERP systems.

Source Systems:
         1. CRM System - Customer, Product, and Sales data
         2. ERP System - Customer, Location, and Product Category data

Tables Created:
         - bronze.crm_cust_info: Customer master data from CRM
         - bronze.crm_prd_info: Product master data from CRM
         - bronze.crm_sales_details: Sales transaction data from CRM
         - bronze.erp_cust_az12: Customer data from ERP
         - bronze.erp_loc_a101: Location data from ERP
         - bronze.erp_px_cat_g1v2: Product category data from ERP

Usage Example:
         Run this script once to set up the Bronze layer tables before
         executing the bronze.load_bronze stored procedure.
===============================================================================
*/

-- TABLE CREATION FROM THE SOURCE CRM DATASET

IF OBJECT_ID ('bronze.crm_cust_info' , 'U') IS NOT NULL
	DROP TABLE bronze.crm_cust_info;

CREATE TABLE bronze.crm_cust_info (
	cst_id INT,
	cst_key NVARCHAR(50),
	cst_firstname NVARCHAR(50),
	cst_lastname NVARCHAR(50),
	cst_marital_status NVARCHAR(50),
	cst_gndr NVARCHAR(50),
	cst_create_date DATE
);

IF OBJECT_ID ('bronze.crm_prd_info' , 'U') IS NOT NULL
	DROP TABLE bronze.crm_prd_info;

CREATE TABLE bronze.crm_prd_info (
	prd_id INT,
	prd_key NVARCHAR(50),
	prd_nm NVARCHAR(50),
	prd_cost INT,
	prd_line NVARCHAR(50),
	prd_start_dt DATETIME,
	prd_end_dt DATETIME
);

IF OBJECT_ID ('bronze.crm_sales_details' , 'U') IS NOT NULL
	DROP TABLE bronze.crm_sales_details;

CREATE TABLE bronze.crm_sales_details (
	sls_ord_num NVARCHAR(50),
	sls_prd_key NVARCHAR(50),
	sls_cust_id INT,
	sls_order_dt INT,
	sls_ship_dt INT,
	sls_due_dt INT,
	sls_sales INT,
	sls_quantity INT,
	sls_price INT
);

-- TABLE CREATION FROM THE SOURCE ERP DATASET

IF OBJECT_ID ('bronze.erp_cust_az12' , 'U') IS NOT NULL
	DROP TABLE bronze.erp_cust_az12;

CREATE TABLE bronze.erp_cust_az12 (
	cid NVARCHAR(50),
	bdate DATE,
	gen NVARCHAR(50)
);

IF OBJECT_ID ('bronze.erp_loc_a101' , 'U') IS NOT NULL
	DROP TABLE bronze.erp_loc_a101;

CREATE TABLE bronze.erp_loc_a101 (
	cid NVARCHAR(50),
	cntry NVARCHAR(50)
);

IF OBJECT_ID ('bronze.erp_px_cat_g1v2' , 'U') IS NOT NULL
	DROP TABLE bronze.erp_px_cat_g1v2;

CREATE TABLE bronze.erp_px_cat_g1v2 (
	id NVARCHAR(50),
	cat NVARCHAR(50),
	subcat NVARCHAR(50),
	maintenance NVARCHAR(50)
);