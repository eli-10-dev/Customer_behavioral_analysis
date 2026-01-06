WITH purchase_variety_count AS (
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
