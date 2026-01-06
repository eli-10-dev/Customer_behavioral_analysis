- Data type changes
  collapsed:: true
	- Invoiceno data type
	  collapsed:: true
		- Upon importing the dataset to Dbeaver I encountered the issue of invoiceno having a target data type of INT.
		- I changed the target type in the data mapping section to VARCHAR to account for Invoice numbers with mixed letters in them.
	- InvoiceDate data type
	  collapsed:: true
		- InvoiceDate initially had a data type of VARCHAR(50).
		- I changed the data type to TIMESTAMP so that it would be stored as a date for proper aggregation or sorting in the analysis.
		- Query
			- ALTER TABLE bhv_online_retail_stage1
			  ALTER COLUMN "InvoiceDate" TYPE TIMESTAMP
			  USING "InvoiceDate"::TIMESTAMP
			  ;
- Standardizing values
  collapsed:: true
	- I created a stage1 version of the dataset, this will be used in the process of data cleaning.
	- I created this version with trimmed and uppercase changed to all TEXT/VARCHAR columns for standardized values.
	- Query
		- CREATE TABLE bhv_online_retail_stage1 AS
		  id:: 6958fdd3-27c5-4e29-9e10-5896c341bf85
		  SELECT 
		  	TRIM(UPPER(invoiceno)) AS "InvoiceNo",
		  	TRIM(UPPER(stockcode)) AS "Stockcode",
		  	UPPER("Description") AS "Description",
		  	"Quantity",
		  	"InvoiceDate",
		  	"UnitPrice",
		  	"CustomerID",
		  	TRIM(UPPER(country)) AS "Country"
		  FROM bhv_online_retail_raw
		  ;
- Null Values
  collapsed:: true
	- All of the rows with NULL CustomerIDs have been dropped from the clean dataset.
	- CustomerIDs is important for customer-level analysis, therefore rows with NULL values for their CustomerIDs cannot be used and won't be contributing to the analysis.
	- Dataset's rows are reduced from 541,909 to 406,829.
	- Query
	  collapsed:: true
		- DELETE FROM bvh_online_retail_stage1
		  WHERE "CustomerID" IS NULL;
- Invalid Invalid
  collapsed:: true
	- All of the rows with InvoiceNo starting with 'C' are cancelled invoices.
	- The cancelled InvoiceNos had negative values for Quantity and will be removed to solely check the transactions of customers that were completed.
	- Dataset's rows are reduced from 406,829 to 397,924.
	- Query
		- DELETE FROM bhv_online_retail_stage1
		  WHERE "InvoiceNo" LIKE 'C%';
- Duplicates
	- The key columns for determining duplicates are InvoiceNo, InvoiceDate, Stockcode, UnitPrice, Quantity, and CustomerID.
	- Rows that contained the same values for the aforementioned columns shall be removed to avoid misrepresenting customer activity levels.
	- Dataset's rows are reduced from 397,924 to 392,730.
	- Query
	  collapsed:: true
		- CREATE TABLE bhv_online_retail_clean AS	SELECT
		  		"InvoiceNo",
		  		"InvoiceDate",
		  		"Stockcode",
		  		"UnitPrice",
		  		"Quantity",
		  		"CustomerID",
		  		MIN("Description") AS "Description",
		  		MIN("Country") AS "Country"
		  	FROM bhv_online_retail_stage1
		  	GROUP BY 
		  		"InvoiceNo",
		  		"InvoiceDate",
		  		"Stockcode",
		  		"UnitPrice",
		  		"Quantity",
		  		"CustomerID"
		  	ORDER BY "InvoiceDate"