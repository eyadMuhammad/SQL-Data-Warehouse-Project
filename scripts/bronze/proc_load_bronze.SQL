/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files. 
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the `BULK INSERT` command to load data from csv Files to bronze tables.

Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC bronze.load_bronze;
===============================================================================
*/
Create or alter procedure bronze.load_bronze AS
	BEGIN
	Declare @start_time datetime , @end_time datetime ,@start_patch datetime , @end_patch datetime
		BEGIN TRY

		Print '================================================';
		Print 'Loading Bronze Layer';
		Print '================================================';

		Print '------------------------------------------------';
		Print 'Loading CRM Tables';
		Print '------------------------------------------------';
		
		set @start_patch = getdate();
		set @start_time = getdate();
			Print '>>Truncating Table: bronze.crm_cust_info';
			Truncate Table bronze.crm_cust_info;

			Print '>>Inserting into Table: bronze.crm_cust_info';
			bulk insert bronze.crm_cust_info
			from 'D:\DataEngineering\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
			with (
				Firstrow=2 ,
				fieldterminator =',' ,
				tablock
				);
				set @end_time = getdate();
				print '>> load duration: ' + cast( datediff(second , @start_time , @end_time) as nvarchar) +' seconds'
				print '--------------'


				set @start_time = getdate();
			Print '>>Truncating Table: bronze.crm_prd_info';
			Truncate Table bronze.crm_prd_info;

			Print '>>Inserting into Table: bronze.crm_prd_info';
			bulk insert bronze.crm_prd_info
			from 'D:\DataEngineering\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
			with (
				Firstrow=2 ,
				fieldterminator =',' ,
				tablock
				);
				set @end_time = getdate();
				print '>> load duration: ' + cast( datediff(second , @start_time , @end_time) as nvarchar) +' seconds'
				print '--------------'


				set @start_time = getdate();
			Print '>>Truncating Table: bronze.crm_sales_details';
			Truncate Table bronze.crm_sales_details;

			Print '>>Inserting into Table: bronze.crm_sales_details';
			bulk insert bronze.crm_sales_details
			from 'D:\DataEngineering\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
			with (
				Firstrow=2 ,
				fieldterminator =',' ,
				tablock
				);
				set @end_time = getdate();
				print '>> load duration: ' + cast( datediff(second , @start_time , @end_time) as nvarchar) +' seconds'
				print '--------------'


			Print '------------------------------------------------';
			Print 'Loading ERP Tables';
			Print '------------------------------------------------';


			set @start_time = getdate();
			Print '>>Truncating Table: bronze.erp_cust_az12';
			Truncate Table bronze.erp_cust_az12;

			Print '>>Inserting into Table: bronze.erp_cust_az12';
			bulk insert bronze.erp_cust_az12
			from 'D:\DataEngineering\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
			with (
				Firstrow=2 ,
				fieldterminator =',' ,
				tablock
				);
				set @end_time = getdate();
				print '>> load duration: ' + cast( datediff(second , @start_time , @end_time) as nvarchar) +' seconds'
				print '--------------'


				set @start_time = getdate();
			Print '>>Truncating Table: bronze.erp_loc_a101';
			Truncate Table bronze.erp_loc_a101;

			Print '>>Inserting into Table: bronze.erp_loc_a101';
			bulk insert bronze.erp_loc_a101
			from 'D:\DataEngineering\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
			with (
				Firstrow=2 ,
				fieldterminator =',' ,
				tablock
				);
				set @end_time = getdate();
				print '>> load duration: ' + cast( datediff(second , @start_time , @end_time) as nvarchar) +' seconds'
				print '--------------'


				set @start_time = getdate();
			Print '>>Truncating Table: bronze.erp_px_cat_g1v2';
			Truncate Table bronze.erp_px_cat_g1v2;

			Print '>>Inserting into Table: bronze.erp_px_cat_g1v2';
			bulk insert bronze.erp_px_cat_g1v2
			from 'D:\DataEngineering\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
			with (
				Firstrow=2 ,
				fieldterminator =',' ,
				tablock
				);
				set @end_time = getdate();
				print '>> load duration: ' + cast( datediff(second , @start_time , @end_time) as nvarchar) +' seconds';
				print '--------------';

				set @end_patch=getdate();
				print'loading bronze layer is completed';
				print '>> Patch load duration: ' + cast( datediff(second , @start_patch , @end_patch) as nvarchar) +' seconds';
				print '--------------';
		END TRY
		BEGIN CATCH
		Print '======================================';
		Print 'Error while loading The bronze layer';
		print 'Error message'+ error_message();
		print 'Error Number' + cast(error_number() as nvarchar);
		Print '======================================';
		END CATCH
	END
