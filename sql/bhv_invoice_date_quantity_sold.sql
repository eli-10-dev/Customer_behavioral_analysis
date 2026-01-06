SELECT
	EXTRACT(MONTH FROM "InvoiceDate") AS "Month",
	COUNT(DISTINCT "InvoiceNo") AS "Invoice Count",
	SUM("Quantity") AS "Quantity"
FROM bhv_online_retail_clean
GROUP BY "Month"
ORDER BY "Month"
;
