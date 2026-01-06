- Total sales overview
  collapsed:: true
	- Total amount of products sold
	  collapsed:: true
		- Query
		  collapsed:: true
			- sales_sum_stockcode AS (
			  	SELECT
			  		"Stockcode",
			  		"UnitPrice",
			  		SUM("Quantity") AS quantity_sum,
			  		ROUND("UnitPrice"::NUMERIC * SUM("Quantity")::NUMERIC, 2) AS sales
			  	FROM bhv_online_retail_clean 
			  	GROUP BY "Stockcode", "UnitPrice"
			  	ORDER BY "Stockcode", SUM("Quantity") DESC
			  )
			  SELECT
			  	SUM(quantity_sum)
			  FROM sales_sum_stockcode
		- ![image.png](../assets/image_1767590631891_0.png)
	- Income Gained from sold products
	  collapsed:: true
		- Query
		  collapsed:: true
			- WITH 
			  sales_sum_stockcode AS (
			  	SELECT
			  		"Stockcode",
			  		"UnitPrice",
			  		SUM("Quantity") AS quantity_sum,
			  		ROUND("UnitPrice"::NUMERIC * SUM("Quantity")::NUMERIC, 2) AS sales
			  	FROM bhv_online_retail_clean 
			  	GROUP BY "Stockcode", "UnitPrice"
			  	ORDER BY "Stockcode", SUM("Quantity") DESC
			  ),
			  sales_table AS (
			  	SELECT
			  		"Stockcode",
			  		SUM(sales) AS total_sales
			  	FROM sales_sum_stockcode 
			  	GROUP BY "Stockcode"
			  	ORDER BY SUM(sales) DESC
			  )
			  SELECT 
			  	SUM(total_sales) AS total_sales
			  FROM sales_table
			  ;
		- ![image.png](../assets/image_1767590408146_0.png)
	- 5,165,583 products were sold which amount to 8,886,657.04 of revenue.
- When do customers buy from the store?
  collapsed:: true
	- Query
		- CREATE TABLE bhv_invoice_date_quantity_sold AS 
		  SELECT
		  	EXTRACT(MONTH FROM "InvoiceDate") AS "Month",
		  	COUNT(DISTINCT "InvoiceNo") AS "Invoice Count",
		  	SUM("Quantity") AS "Quantity"
		  FROM bhv_online_retail_clean
		  GROUP BY "Month"
		  ORDER BY "Month"
		  ;
	- ![image.png](../assets/image_1767622819598_0.png)
	- The first 8 months of the year was steady, it had little differences in the amount of invoices. The noticeable spikes were only found in March and May, the month after these two always saw a dip and then that will be maintained until August. The 'ber' months see an in increase in invoice count, to contextualize this, these months make up 46% of the total invoices and 47% of the quantity of products sold.
	- This suggests demand is relatively stable for most of the year, with a strong seasonal uplift toward the end of the year, making the ‘ber’ months a critical period for sales volume.
- What is the ratio of one-time buyers vs repeat buyers?
  collapsed:: true
	- Query
	  collapsed:: true
		- --CREATE TABLE bhv_buyer_activity AS 
		  WITH customer_data AS (
		  	SELECT
		  		"CustomerID",
		  		DATE_TRUNC('month', "InvoiceDate") AS "Year and Month",
		  		COUNT(DISTINCT "InvoiceNo") AS "Invoice count",
		  		SUM("Quantity") AS "Quantity",
		  		ROUND(SUM("Quantity"::NUMERIC * "UnitPrice"::NUMERIC), 2) AS "Sales"
		  	FROM bhv_online_retail_clean 
		  	GROUP BY "CustomerID", "Year and Month"
		  )
		  SELECT
		  	"CustomerID",
		  	COUNT("Year and Month") AS "Months Active",
		  	SUM("Invoice count") AS "Total Invoices",
		  	ROUND(SUM("Invoice count") / COUNT("Year and Month"), 2) AS "Avg active month invoices",
		  	SUM("Quantity") AS "Total quantity bought",
		  	ROUND(SUM("Quantity") / COUNT("Year and Month"), 2) AS "Avg active month purchases",
		  	SUM("Sales") AS "Monthly Spendings",
		  	ROUND(SUM("Sales") / COUNT("Year and Month"), 2) AS "Avg active round spendings",
		  	CASE WHEN COUNT("Year and Month") > 1 THEN TRUE ELSE FALSE END AS "Repeat Buyer Flag"
		  FROM customer_data
		  GROUP BY "CustomerID"
		  ;
	- ![image.png](../assets/image_1767622802908_0.png)
	- Query
	  collapsed:: true
		- CREATE TABLE bhv_repeat_buyer_distribution AS 
		  SELECT
		  	'1' AS "Months Active",
		  	COUNT(*) AS "Customer Count",
		  	1 AS "Sort Order"
		  FROM bhv_buyer_activity
		  WHERE "Months Active" = 1
		  UNION ALL
		  SELECT 
		  	'2-4' AS "Months Active",
		  	COUNT(*) AS "Customer Count",
		  	2 AS "Sort Order"
		  FROM bhv_buyer_activity
		  WHERE "Months Active" > 1 AND "Months Active" <= 4
		  UNION ALL
		  SELECT 
		  	'5-7' AS "Months Active",
		  	COUNT(*) AS "Customer Count",
		  	3 AS "Sort Order"
		  FROM bhv_buyer_activity
		  WHERE "Months Active" > 4 AND "Months Active" <= 7
		  UNION ALL
		  SELECT 
		  	'8-10' AS "Months Active",
		  	COUNT(*) AS "Customer Count",
		  	4 AS "Sort Order"
		  FROM bhv_buyer_activity
		  WHERE "Months Active" > 7 AND "Months Active" <= 10
		  UNION ALL
		  SELECT 
		  	'11-13' AS "Months Active",
		  	COUNT(*) AS "Customer Count",
		  	5 AS "Sort Order"
		  FROM bhv_buyer_activity
		  WHERE "Months Active" > 10 AND "Months Active" <= 13
		  ;
	- ![image.png](../assets/image_1767671993227_0.png)
	- ![image.png](../assets/image_1767673290340_0.png)
	- 62% of customers are repeat buyers, majority of these repeat buyers purchasing products for 2 to 4 months of the year, making up 42% of the total repeat buyers.
	- This indicates that repeat buyers mostly return for a short period of time, while only less than 22% are active for more than half the year.
- What is the variety of customer purchases?
  collapsed:: true
	- Customers' distinct Stockcode purchase
	  collapsed:: true
		- Percentiles
			- Query
				- SELECT
				  	MIN("Purchase Variety") AS min,
				  	PERCENTILE_CONT(0.1) WITHIN GROUP (ORDER BY "Purchase Variety") AS p10,
				  	PERCENTILE_CONT(0.2) WITHIN GROUP (ORDER BY "Purchase Variety") AS p20,
				  	PERCENTILE_CONT(0.3) WITHIN GROUP (ORDER BY "Purchase Variety") AS p30,
				  	PERCENTILE_CONT(0.4) WITHIN GROUP (ORDER BY "Purchase Variety") AS p40,
				  	PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY "Purchase Variety") AS median,
				  	PERCENTILE_CONT(0.6) WITHIN GROUP (ORDER BY "Purchase Variety") AS p60,
				  	PERCENTILE_CONT(0.7) WITHIN GROUP (ORDER BY "Purchase Variety") AS p70,
				  	PERCENTILE_CONT(0.8) WITHIN GROUP (ORDER BY "Purchase Variety") AS p80,
				  	PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY "Purchase Variety") AS p90,
				  	MAX("Purchase Variety") AS max
				  FROM bhv_buyer_purchase_variety
			- ![image.png](../assets/image_1767619172156_0.png)
	- Amount of Customers by Purchase Variety
		- Query
		  collapsed:: true
			- WITH purchase_variety_count AS (
			  	SELECT 
			  		"CustomerID",
			  		COUNT(DISTINCT "Stockcode") AS "Purchase Variety"
			  	FROM bhv_online_retail_clean
			  	GROUP BY "CustomerID"
			  )
			  SELECT 'Very Low' AS "Variety",
			  	COUNT(*) AS "Customer Count"
			  FROM purchase_variety_count
			  WHERE "Purchase Variety" < 7
			  UNION ALL
			  SELECT 'Low' AS "Variety",
			  	COUNT(*) AS "Customer Count"
			  FROM purchase_variety_count
			  WHERE "Purchase Variety" >= 7 AND "Purchase Variety" < 13 
			  UNION ALL	
			  SELECT 'Medium' AS "Variety",
			  	COUNT(*) AS "Customer Count"
			  FROM purchase_variety_count
			  WHERE "Purchase Variety" >= 13 AND "Purchase Variety" < 35 
			  UNION ALL	
			  SELECT 'High' AS "Variety",
			  	COUNT(*) AS "Customer Count"
			  FROM purchase_variety_count
			  WHERE "Purchase Variety" >= 35 AND "Purchase Variety" < 143 
			  UNION ALL	
			  SELECT 'Very High' AS "Variety",
			  	COUNT(*) AS "Customer Count"
			  FROM purchase_variety_count
			  WHERE "Purchase Variety" >= 143
			  ;
		- Data
			- ![image.png](../assets/image_1767671969154_0.png)
			- The bar graph above categorizes the variety of products that customers purchase: very low, low, medium, high, and very high. Among these categories, customers fall most in the high and then medium next. This shows that most customers purchase a wide array of products from the store.
- What is the variety of customer purchases by the Number of Active Months?
	- Purchase Variety for Repeat Buyers
	  collapsed:: true
		- Query
		  collapsed:: true
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
		- Data
			- ![image.png](../assets/image_1767688341702_0.png)
			- The table above shows the amount of customers per engagement level or number of months active and the average monthly variety of products that they purchase.
			- Among the repeat buyers, the most active customers were the most diverse in their product purchases despite being the least in customer count.
			- The least active customers, the one-time buyers placed 4th, higher than only the 2-4 month active customers in terms of their monthly average product variety.
			- While long-term customers higher monthly invoices but not product purchasing variety. Mid- to long-term customers show mixed purchasing patterns, whereas the most active customers demonstrate the highest average monthly product variety.
- Conclusion
  collapsed:: true
	- There is a strong seasonal trend, with customers purchase on the tail-end of the year, during the 'Ber' months.
	- The majority of the customers are repeat buyers, taking up 62% of the total customer base. Among these, roughly 42% are active for 2-4 months, while 22% are active for 5-13 months.
	- In terms of raw number of products purchased, most customers fall under the medium to high variety of purchases.
	- Customer engagement has a linear relationship with average monthly invoices, but showing varied results for the variety of product they purchase.