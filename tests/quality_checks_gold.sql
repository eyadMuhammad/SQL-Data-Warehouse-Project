/*
===============================================================================
Quality Checks
===============================================================================
Script Purpose:
    This script performs quality checks to validate the integrity, consistency, 
    and accuracy of the Gold Layer. These checks ensure:
    - Uniqueness of surrogate keys in dimension tables.
    - Referential integrity between fact and dimension tables.
    - Validation of relationships in the data model for analytical purposes.

Usage Notes:
    - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/

-- ====================================================================
-- Checking 'gold.dim_customers'
-- ====================================================================
-- Check for Uniqueness of Customer Key in gold.dim_customers
-- Expectation: No results 
Select 
    customer_key,
    Count(*) as duplicate_count
From gold.dim_customers
Group By customer_key
Having Count(*) > 1;

-- ====================================================================
-- Checking 'gold.product_key'
-- ====================================================================
-- Check for Uniqueness of Product Key in gold.dim_products
-- Expectation: No results 
Select 
    product_key,
    Count(*) as duplicate_count
From gold.dim_products
Group By product_key
Having Count(*) > 1;

-- ====================================================================
-- Checking 'gold.fact_sales'
-- ====================================================================
-- Check the data model connectivity between fact and dimensions
Select * 
From gold.fact_sales f
Left Join gold.dim_customers c
on c.customer_key = f.customer_key
Left Join gold.dim_products p
on p.product_key = f.product_key
Where p.product_key is null OR c.customer_key is null  
