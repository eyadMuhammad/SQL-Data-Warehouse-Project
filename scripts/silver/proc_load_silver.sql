/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to 
    populate the 'silver' schema tables from the 'bronze' schema.
	Actions Performed:
		- Truncates Silver tables.
		- Inserts transformed and cleansed data from Bronze into Silver tables.
		
Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC Silver.load_silver;
===============================================================================
*/

Create OR Alter Procedure silver.load_silver AS
BEGIN
     DECLARE @start_time Datetime, @end_time Datetime, @batch_start_time Datetime, @batch_end_time Datetime; 
    BEGIN TRY
        SET @batch_start_time = GETDATE();
        Print '================================================';
        Print 'Loading Silver Layer';
        Print '================================================';

		Print '------------------------------------------------';
		Print 'Loading CRM Tables';
		Print '------------------------------------------------';

        -- Loading silver.crm_cust_info
        SET @start_time = GETDATE();
        Print '>> Truncating Table: silver.crm_cust_info';
		    Truncate Table silver.crm_cust_info;
		    Print '>> Inserting Data Into: silver.crm_cust_info';
		    Insert into silver.crm_cust_info (
			    cst_id, 
			    cst_key, 
			    cst_firstname, 
			    cst_lastname, 
			    cst_marital_status, 
			    cst_gndr,
			    cst_create_date
		    )
     Select  
           cst_id
          ,cst_key
          ,trim(cst_firstname) cst_firstname
          ,trim(cst_lastname) cst_lastname
          ,Case  
                when upper(trim(cst_marital_status)) = 'S' Then 'Single'
                when upper(trim(cst_marital_status)) = 'M' Then 'Married'
                else 'n/a'
           End cst_marital_status
          ,Case  
                when upper(trim(cst_gndr)) = 'M' Then 'Male'
                when upper(trim(cst_gndr)) = 'F' Then 'Female'
                else 'n/a'
           End cst_gndr
          ,cst_create_date
      From (
          Select *,row_number() over (partition by cst_id order by cst_create_date desc) flag
          From bronze.crm_cust_info
          where cst_id is not null
      )t
      where flag =1
      SET @end_time = GETDATE();
        Print '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        Print '>> -------------';
  
      --------------------------------------------------------------------------------------------------------------------------
      -- Loading silver.crm_prd_info
        SET @start_time = GETDATE();
        Print '>> Truncating Table: silver.crm_prd_info';
		    Truncate Table silver.crm_prd_info;
		    Print '>> Inserting Data Into: silver.crm_prd_info';
		    Insert into silver.crm_prd_info (
			    prd_id,
			    cat_id,
			    prd_key,
			    prd_nm,
			    prd_cost,
			    prd_line,
			    prd_start_dt,
			    prd_end_dt
		    )
      Select  
           prd_id 
          ,replace(substring(prd_key,1,5),'-','_') cat_id --Extract category id for joining tables later
          ,substring(prd_key,7,len(prd_key)) prd_key --Extract product key
          ,prd_nm
          ,isnull(prd_cost,0) prd_cost
          ,case 
                when upper(trim(prd_line)) ='R' then 'Road'
                when upper(trim(prd_line)) ='S' then 'Other Sales'
                when upper(trim(prd_line)) ='T' then 'Touring'
                when upper(trim(prd_line)) ='M' then 'Mountain'
                else 'n/a'
            End prd_line --Map product line codes to more understandable values
          ,cast(prd_start_dt as date) prd_start_dt
          ,cast(lead(prd_start_dt) over (partition by prd_key order by prd_start_dt )-1 as date) prd_end_dt
          From bronze.crm_prd_info --calculate end date as one day before the next start date for the same key
          SET @end_time = GETDATE();
            Print '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
            Print '>> -------------';
  

      --------------------------------------------------------------------------------------------------------------------------
       -- Loading crm_sales_details
        SET @start_time = GETDATE();
        Print '>> Truncating Table: silver.crm_sales_details';
		    Truncate Table silver.crm_sales_details;
		    Print '>> Inserting Data Into: silver.crm_sales_details';
		    Insert Into silver.crm_sales_details (
			    sls_ord_num,
			    sls_prd_key,
			    sls_cust_id,
			    sls_order_dt,
			    sls_ship_dt,
			    sls_due_dt,
			    sls_sales,
			    sls_quantity,
			    sls_price
		    )
        Select 
           sls_ord_num
          ,sls_prd_key
          ,sls_cust_id
          ,case 
                when len(sls_order_dt) != 8 or sls_order_dt =0 Then null
                else cast(cast(sls_order_dt as varchar) as date)
          end sls_order_dt
          ,case 
                when len(sls_ship_dt) != 8 or sls_ship_dt =0 Then null
                else cast(cast(sls_ship_dt as varchar) as date)
          end sls_ship_dt
          ,case 
                when len(sls_due_dt) != 8 or sls_due_dt =0 Then null
                else cast(cast(sls_due_dt as varchar) as date)
           end sls_due_dt 
          ,case 
            when sls_sales is null or sls_sales <=0 or sls_sales != sls_quantity * abs(sls_price)
                Then sls_quantity * abs(sls_price)
            else sls_sales
          end sls_sales
          ,sls_quantity
          ,case 
            when sls_price is null or sls_price <=0 
                Then sls_sales / nullif(sls_quantity,0)
            else sls_price
          end sls_price      
          From bronze.crm_sales_details
          SET @end_time = GETDATE();
            Print '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
            Print '>> -------------';

        --------------------------------------------------------------------------------------------------------------------------
        -- Loading erp_cust_az12
        SET @start_time = GETDATE();
        Print '>> Truncating Table: silver.erp_cust_az12';
		    Truncate Table silver.erp_cust_az12;
		    Print '>> Inserting Data Into: silver.erp_cust_az12';
		    Insert into silver.erp_cust_az12 (
			    cid,
			    bdate,
			    gen
		    )
        Select
            case 
                when cid like 'NAS%' Then substring (cid,4,len(cid)) 
                else cid
            end cid
          ,case
                when bdate >getdate() Then null
                else bdate
            end bdate
          ,case
                when upper(trim(gen)) in ('Male','M') Then 'Male'
                when upper(trim(gen)) in ('Female','F') Then 'Female'
                else 'n/a'
            end gen
      From bronze.erp_cust_az12
      SET @end_time = GETDATE();
        Print '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        Print '>> -------------';

          --------------------------------------------------------------------------------------------------------------------------
        Print '------------------------------------------------';
		Print 'Loading ERP Tables';
		Print '------------------------------------------------';

        -- Loading erp_loc_a101
           SET @start_time = GETDATE();
            Print '>> Truncating Table: silver.erp_loc_a101';
		    Truncate Table silver.erp_loc_a101;
		    Print '>> Inserting Data Into: silver.erp_loc_a101';
		    Insert into silver.erp_loc_a101 (
			    cid,
			    cntry
		    )
          Select 
            replace(cid,'-','') cid
            ,case 
                when trim(cntry) in ('US' , 'United States','USA') then 'United States'
                when trim(cntry) in ('DE' , 'Germany') then 'Germany'
                when trim(cntry) = '' or cntry is null then 'n/a'
                else trim(cntry)
            end cntry
        From bronze.erp_loc_a101
        	 SET @end_time = GETDATE();
             Print '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
             Print '>> -------------';
	
          --------------------------------------------------------------------------------------------------------------------------
          -- Loading erp_px_cat_g1v2
		SET @start_time = GETDATE();
        Print '>> Truncating Table: silver.erp_px_cat_g1v2';
		    Truncate Table silver.erp_px_cat_g1v2;
		    Print '>> Inserting Data Into: silver.erp_px_cat_g1v2';
		    Insert into silver.erp_px_cat_g1v2 (
			    id,
			    cat,
			    subcat,
			    maintenance
		    )
		    Select
			    id,
			    cat,
			    subcat,
			    maintenance
		    From bronze.erp_px_cat_g1v2;
            SET @end_time = GETDATE();
		    Print '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
            Print '>> -------------';
            SET @batch_end_time = GETDATE();
		Print '=========================================='
		Print 'Loading Silver Layer is Completed';
        Print '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
		Print '=========================================='
		
	END TRY
    BEGIN CATCH
		Print '======================================';
		Print 'Error while loading The silver layer';
		print 'Error message'+ error_message();
		print 'Error Number' + cast(error_number() as nvarchar);
		Print '======================================';
	  END CATCH
END
