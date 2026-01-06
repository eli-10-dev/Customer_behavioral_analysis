- Dataset Reference
  collapsed:: true
	- Dataset link:
	  https://www.kaggle.com/datasets/ulrikthygepedersen/online-retail-dataset?resource=download
- Dataset Overview
  collapsed:: true
	- The dataset contains 541,909 rows and 8 columns.
	- The dataset's columns are:
	  collapsed:: true
		- InvoiceNo
			- Invoice number. Nominal, a 6-digit integral number uniquely assigned to each transaction. If this code starts with letter 'c', it indicates a cancellation.
		- stockcode
			- Product (item) code. Nominal, a 5-digit integral number uniquely assigned to each distinct product.
		- Description
			- Product (item) name
		- Quantity
			- The quantities of each product (item) per transaction
		- InvoiceDate
			- Invice Date and time. Numeric, the day and time when each transaction was generated.
		- UnitPrice
			- Product price per unit in sterling.
		- CustomerID
			- Customer number. Nominal, a 5-digit integral number uniquely assigned to each customer.
		- country
	- The dataset contains retail between 12/01/2010 and 12/07/2011.
- Categorical Distribution
  collapsed:: true
	- Invoiceno
	  collapsed:: true
		- SELECT 
		  	COUNT(DISTINCT invoiceno) AS invoice_count
		  FROM bhv_online_retail_raw
		  ;
		- ![image.png](../assets/image_1767328790037_0.png)
	- stockcode
	  collapsed:: true
		- SELECT 
		  	COUNT(DISTINCT stockcode) AS stockcode_count
		  FROM bhv_online_retail_raw
		  ;
		- ![image.png](../assets/image_1767328840034_0.png)
	- CustomerID
		- SELECT 
		  	COUNT(DISTINCT "CustomerID") AS customer_count
		  FROM bhv_online_retail_raw
		  ;
		- ![image.png](../assets/image_1767328887136_0.png)
	- Country
	  collapsed:: true
		- SELECT DISTINCT "Country"
		  FROM bhv_online_retail_raw
		  ORDER BY "Country";
		- ![image.png](../assets/image_1767341078227_0.png){:height 687, :width 233}
		  ![image.png](../assets/image_1767341102354_0.png)
		- There are 36 categorized countries with one unspecified category.
- Data Integrity & Consistency Checks
  collapsed:: true
	- Note:
	  collapsed:: true
		- Every bullet under data checks were paired with the execution of respective cleaning sections in the online_retail_cleaning document. So every successive step done in this process is working with the dataset that is undergoing cleaning. So the invalid values check made use of the dataset without null values while the duplicates made is used on the dataset without the invalid values.
	- Data types
	  collapsed:: true
		- Invoiceno has a target type of INT.
		- InvoiceDate is of type VARCHAR.
	- Null values
	  collapsed:: true
		- SELECT
		    	COUNT(CASE WHEN "InvoiceNo" IS NULL OR TRIM("InvoiceNo") = '' THEN 1 ELSE NULL END) AS invoice_nulls,  
		    	COUNT(CASE WHEN  "Stockcode" IS NULL OR TRIM("Stockcode") = '' THEN 1 ELSE NULL END) AS stockcode_nulls,  
		    	COUNT(CASE WHEN  "Description" IS NULL OR TRIM("Description") = '' THEN 1 ELSE NULL END) AS desc_nulls,  
		    	COUNT(CASE WHEN "Quantity" IS NULL THEN 1 ELSE NULL END) AS quantity_nulls,  
		    	COUNT(CASE WHEN "InvoiceDate" IS NULL THEN 1 ELSE NULL END) AS invoice_date_nulls,  
		    	COUNT(CASE WHEN "UnitPrice" IS NULL THEN 1 ELSE NULL END) AS unit_price_nulls,  
		    	COUNT(CASE WHEN "CustomerID" IS NULL THEN 1 ELSE NULL END) AS customerid_nulls,  
		    	COUNT(CASE WHEN "Country" IS NULL OR TRIM("Country") = '' THEN 1 ELSE NULL END) AS country_nulls  
		    FROM bhv_online_retail_stage1;
		- ![image.png](../assets/image_1767333745309_0.png){:height 42, :width 463}
	- Invalid values
	  collapsed:: true
		- SELECT
		  	COUNT(CASE WHEN "Quantity" < 1 OR "UnitPrice"< 0 THEN 1 ELSE NULL END) AS invalid_count
		  FROM bhv_online_retail_stage1
		  ;
		- ![image.png](../assets/image_1767441081623_0.png)
		- SELECT COUNT(*) AS cancellations
		  FROM bhv_online_retail_stage1
		  WHERE "InvoiceNo" LIKE 'C%'
		  ;
		- ![image.png](../assets/image_1767344303362_0.png)
		- All cancelled transactions have a negative quantity; only quantity had invalid values, all values under UnitPrice were above 0. All other transactions have proper values
	- Distribution Overview
		- quantity
		  collapsed:: true
			- SELECT
			  	MIN("Quantity") AS MIN,  
			  	PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY "Quantity") AS p25,
			  	PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY "Quantity") AS median,
			  	PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY "Quantity") AS p75,
			  	MAX("Quantity") AS MAX
			  FROM bhv_online_retail_stage1
			  ;
			- ![image.png](../assets/image_1767588585813_0.png) {:height 38, :width 307}
		- unitprice
		  collapsed:: true
			- SELECT
			  	MIN("UnitPrice") AS MIN,  
			  	PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY "UnitPrice") AS p25,
			  	PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY "UnitPrice") AS median,
			  	PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY "UnitPrice") AS p75,
			  	MAX("UnitPrice") AS MAX
			  FROM bhv_online_retail_stage1
			  ;
			- ![image.png](../assets/image_1767346613683_0.png)
	- Duplicates
	  collapsed:: true
		- The key columns for determining duplicates are InvoiceNo, InvoiceDate, Stockcode, UnitPrice, Quantity, and CustomerID.
		- Number of distinct transactions
		  collapsed:: true
			- Query
			  collapsed:: true
				- WITH distinct_table AS (
				  	SELECT DISTINCT
				  		"InvoiceNo",
				  		"InvoiceDate",
				  		"Stockcode",
				  		"UnitPrice",
				  		"CustomerID",
				  		"Quantity",
				  		COUNT(*) AS distinction_count
				  	FROM bhv_online_retail_stage1
				  	GROUP BY "InvoiceNo", "Stockcode", "UnitPrice", "InvoiceDate", "CustomerID", "Quantity"
				  )
				  SELECT 
				  	COUNT(*)
				  FROM distinct_table
			- ![image.png](../assets/image_1767437223219_0.png)
		- Number of transactions with duplicates
		  collapsed:: true
			- Query
			  collapsed:: true
				- WITH distinct_table AS (
				  	SELECT DISTINCT
				  		"InvoiceNo",
				  		"InvoiceDate",
				  		"Stockcode",
				  		"UnitPrice",
				  		"CustomerID",
				  		"Quantity",
				  		COUNT(*) AS distinction_count
				  	FROM bhv_online_retail_stage1
				  	GROUP BY "InvoiceNo", "Stockcode", "UnitPrice", "InvoiceDate", "CustomerID", "Quantity"
				  )
				  SELECT 
				  	COUNT(*) AS duplicate_count
				  FROM distinct_table
				  WHERE distinction_count > 1
				  ;
			- ![image.png](../assets/image_1767437284026_0.png)