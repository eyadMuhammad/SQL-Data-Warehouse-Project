/*
===============================================================================
Quality Checks
===============================================================================
Script Purpose:
    This script performs various quality checks for data consistency, accuracy, 
    and standardization across the 'silver' layer. It includes checks for:
    - Null or duplicate primary keys.
    - Unwanted spaces in string fields.
    - Data standardization and consistency.
    - Invalid date ranges and orders.
    - Data consistency between related fields.

Usage Notes:
    - Run these checks after data loading Silver Layer.
    - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/

-- ====================================================================
-- Checking 'silver.crm_cust_info'
-- ====================================================================
-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results

Select 
    cst_id,
    count(*) 
From silver.crm_cust_info
group by cst_id
having count(*) > 1 OR cst_id is null;

-- Check for Unwanted Spaces
-- Expectation: No Results
Select 
    cst_key 
From silver.crm_cust_info
where cst_key != trim(cst_key);

-- Data Standardization & Consistency
Select Distinct 
    cst_marital_status 
From silver.crm_cust_info;

-- ====================================================================
-- Checking 'silver.crm_prd_info'
-- ====================================================================
-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results
Select 
    prd_id,
    count(*) 
From silver.crm_prd_info
group by prd_id
having count(*) > 1 OR prd_id is null;

-- Check for Unwanted Spaces
-- Expectation: No Results
Select 
    prd_nm 
From silver.crm_prd_info
where prd_nm != trim(prd_nm);

-- Check for NULLs or Negative Values in Cost
-- Expectation: No Results
Select 
    prd_cost 
From silver.crm_prd_info
where prd_cost < 0 OR prd_cost is null;

-- Data Standardization & Consistency
Select Distinct 
    prd_line 
From silver.crm_prd_info;

-- Check for Invalid Date Orders (Start Date > End Date)
-- Expectation: No Results
Select 
    * 
From silver.crm_prd_info
where prd_end_dt < prd_start_dt;

-- ====================================================================
-- Checking 'silver.crm_sales_details'
-- ====================================================================
-- Check for Invalid Dates
-- Expectation: No Invalid Dates
Select 
    Nullif(sls_due_dt, 0) AS sls_due_dt 
From bronze.crm_sales_details
where sls_due_dt <= 0 
    OR LEN(sls_due_dt) != 8 
    OR sls_due_dt > 20500101 
    OR sls_due_dt < 19000101;

-- Check for Invalid Date Orders (Order Date > Shipping/Due Dates)
-- Expectation: No Results
Select 
    * 
From silver.crm_sales_details
where sls_order_dt > sls_ship_dt 
   OR sls_order_dt > sls_due_dt;

-- Check Data Consistency: Sales = Quantity * Price
-- Expectation: No Results
Select Distinct 
    sls_sales,
    sls_quantity,
    sls_price 
From silver.crm_sales_details
where sls_sales != sls_quantity * sls_price
   OR sls_sales IS NULL 
   OR sls_quantity IS NULL 
   OR sls_price IS NULL
   OR sls_sales <= 0 
   OR sls_quantity <= 0 
   OR sls_price <= 0
Order By sls_sales, sls_quantity, sls_price;

-- ====================================================================
-- Checking 'silver.erp_cust_az12'
-- ====================================================================
-- Identify Out-of-Range Dates
-- Expectation: Birthdates between 1924-01-01 and Today
Select Distinct 
    bdate 
From silver.erp_cust_az12
where bdate < '1924-01-01' 
   OR bdate > Getdate();

-- Data Standardization & Consistency
Select Distinct 
    gen 
From silver.erp_cust_az12;

-- ====================================================================
-- Checking 'silver.erp_loc_a101'
-- ====================================================================
-- Data Standardization & Consistency
Select Distinct 
    cntry 
From silver.erp_loc_a101
Order By cntry;

-- ====================================================================
-- Checking 'silver.erp_px_cat_g1v2'
-- ====================================================================
-- Check for Unwanted Spaces
-- Expectation: No Results
Select 
    * 
From silver.erp_px_cat_g1v2
where cat != trim(cat) 
   OR subcat != trim(subcat) 
   OR maintenance != trim(maintenance);

-- Data Standardization & Consistency
Select Distinct 
    maintenance 
From silver.erp_px_cat_g1v2;
