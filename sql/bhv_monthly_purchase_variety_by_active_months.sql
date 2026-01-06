- --CREATE TABLE bhv_monthly_purchase_variety_by_active_months AS 
  WITH cte1 AS (  
  	SELECT  
  		"CustomerID",  
  		DATE_TRUNC('month', "InvoiceDate") AS "Date",  
  		COUNT(DISTINCT "InvoiceNo") AS "Invoice count",  
  		COUNT(DISTINCT "Stockcode") AS "Stockcode Variety"  
  	FROM bhv_online_retail_clean  
  	GROUP BY "CustomerID", "Date"  
  ),  
  cte2 AS (  
  	SELECT   
  		"CustomerID",  
  		COUNT("Date") AS "Active Months",  
  		SUM("Invoice count") as "Sum of Monthly Invoices",  
  		SUM("Stockcode Variety") AS "Sum of Monthly Distinct Purchases"  
  	FROM cte1  
  	GROUP BY "CustomerID"  
  	ORDER BY "CustomerID"  
  )  
  SELECT   
  	'1' AS "Active Months",  
  	COUNT("CustomerID") AS "Customer count",  
  	ROUND(AVG("Sum of Monthly Invoices"), 2) as "Avg Monthly Invoices",  
  	ROUND(AVG("Sum of Monthly Distinct Purchases"), 2) AS "Avg monthly variety",  
  	1 AS "SortOrder"  
  FROM cte2  
  WHERE "Active Months" = 1  
  UNION ALL  
  SELECT   
  	'2-4' AS "Active Months",  
  	COUNT("CustomerID") AS "Customer count",  
  	ROUND(AVG("Sum of Monthly Invoices"), 2) as "Avg Monthly Invoices",  
  	ROUND(AVG("Sum of Monthly Distinct Purchases" / "Active Months"), 2) AS "Avg monthly variety",  
  	2 AS "SortOrder"  
  FROM cte2  
  WHERE "Active Months" > 1 AND "Active Months" <= 4  
  UNION ALL  
  SELECT   
  	'5-7' AS "Active Months",  
  	COUNT("CustomerID") AS "Customer count",  
  	ROUND(AVG("Sum of Monthly Invoices"), 2) as "Avg Monthly Invoices",  
  	ROUND(AVG("Sum of Monthly Distinct Purchases" / "Active Months"), 2) AS "Avg monthly variety",  
  	3 AS "SortOrder"  
  FROM cte2  
  WHERE "Active Months" > 4 AND "Active Months" <= 7  
  UNION ALL  
  SELECT   
  	'8-10' AS "Active Months",  
  	COUNT("CustomerID") AS "Customer count",  
  	ROUND(AVG("Sum of Monthly Invoices"), 2) as "Avg Monthly Invoices",  
  	ROUND(AVG("Sum of Monthly Distinct Purchases" / "Active Months"), 2) AS "Avg monthly variety",  
  	4 AS "SortOrder"  
  FROM cte2  
  WHERE "Active Months" > 7 AND "Active Months" <= 10  
  UNION ALL  
  SELECT   
  	'11-13' AS "Active Months",  
  	COUNT("CustomerID") AS "Customer count",  
  	ROUND(AVG("Sum of Monthly Invoices"), 2) as "Avg Monthly Invoices",  
  	ROUND(AVG("Sum of Monthly Distinct Purchases" / "Active Months"), 2) AS "Avg monthly variety",  
  	5 AS "SortOrder"  
  FROM cte2  
  WHERE "Active Months" > 10 AND "Active Months" <= 13  
  ;
