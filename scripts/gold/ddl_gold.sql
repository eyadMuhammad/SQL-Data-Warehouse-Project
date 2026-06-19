/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse. 
    The Gold layer represents the final dimension and fact tables (Star Schema)

    Each view performs transformations and combines data from the Silver layer 
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================
*/

-- =============================================================================
-- Create Dimension: gold.dim_customers
-- ==========================================================================
IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;
GO
create view Gold.dim_customers as    
        Select
          row_number() over(order by ci.cst_key) customer_key -- Surrogate key
          ,ci.cst_id customer_id
          ,ci.cst_key customer_number
          ,ci.cst_firstname first_name
          ,ci.cst_lastname last_name
          ,lo.cntry country
          ,ci.cst_marital_status marital_status
          ,Case
            when ci.cst_gndr != 'n/a' then ci.cst_gndr -- CRM is the primary source for gender
            else isnull(bd.gen,'n/a')
           End gender
          ,bd.bdate birthdate
          ,ci.cst_create_date create_date
      From silver.crm_cust_info ci
      left join silver.erp_cust_az12 bd
      on ci.cst_key = bd.cid
      left join silver.erp_loc_a101 lo
      on ci.cst_key = lo.cid
GO
-- =============================================================================
-- Create Dimension: gold.dim_products
-- =============================================================================
IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
    DROP VIEW gold.dim_products;
GO
create view gold.dim_products as
        	Select
        		row_number() over(order by prd_id) product_key,
        		pn.prd_id product_id,
        		pn.prd_key product_number,
        		pn.prd_nm product_name,
        		pn.cat_id category_id,
        		pc.cat category,
        		pc.subcat subcategory,
        		pc.maintenance,
        		pn.prd_cost cost,
        		pn.prd_line product_line,
        		pn.prd_start_dt start_date
        	from silver.crm_prd_info pn
        	left join silver.erp_px_cat_g1v2 pc
        	on pn.cat_id = pc.id
        	where pn.prd_end_dt is null

-- =============================================================================
-- Create Fact Table: gold.fact_sales
-- =============================================================================
IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales;
GO
create view gold.fact_sales as
          	Select 
          		s.sls_ord_num order_number,
          		p.product_key,
          		c.customer_key,
          		s.sls_order_dt order_date,
          		s.sls_ship_dt shipping_date,
          		s.sls_due_dt due_date,
          		s.sls_sales sales,
          		s.sls_quantity quantity,
          		s.sls_price price
          	from silver.crm_sales_details s
          	left join gold.dim_customers c
          	on s.sls_cust_id = c.customer_id
          	left join gold.dim_products p 
          	on s.sls_prd_key = p.product_number
GO

