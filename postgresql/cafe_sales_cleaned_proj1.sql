-- =========================
-- EXPLORATORY DATA ANALYSIS (EDA) STEPS
-- =========================
-- creating a shortcut name bc im lazy
CREATE VIEW ccs AS 
SELECT * FROM cleaned_cafe_sales;

-- 1. Exploring Tables and Columns
--    - List all tables in the database.
-- this is assuming one whole database has different tables for ex. Cafe Database with cafe sales table, cafe customers table, etc.
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public';

--    - Check the structure of a specific table (column names, data types).
SELECT * 
FROM information_schema.columns
WHERE table_name = 'cleaned_cafe_sales'
ORDER BY ordinal_position;

--    - Identify missing or null values in key columns.
-- from chatgpt
SELECT 
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE "Payment Method" IS NULL) AS null_payment_rows,
    COUNT(*) FILTER (WHERE "Location" = 'UNKNOWN') AS unknown_location_rows,
    COUNT(*) FILTER (WHERE "Transaction Date" IS NULL) AS null_transaction_dates
FROM cleaned_cafe_sales;

SELECT "Item",COUNT(*) AS number_of_nulls,
		SUM(COUNT(*)) OVER(ORDER BY COUNT(*)) AS running_total
FROM cleaned_cafe_sales
WHERE "Payment Method" IS NULL
GROUP BY "Item";
-- INSIGHT: coffee has the most unknown payment method while juice has the least

SELECT "Item",COUNT(*) AS number_of_nulls,
		SUM(COUNT(*)) OVER(ORDER BY COUNT(*)) AS running_total
FROM cleaned_cafe_sales
WHERE "Location" = 'UNKNOWN'
GROUP BY "Item";
-- INSIGHT: coffee has the most unknown location type while sandwich has the least

SELECT "Item",COUNT(*) AS number_of_nulls,
		SUM(COUNT(*)) OVER(ORDER BY COUNT(*)) AS running_total
FROM cleaned_cafe_sales
WHERE "Transaction Date" IS NULL
GROUP BY "Item";
-- INSIGHT: tea has the most unknown transaction date while coffee has the least

-- 2. Exploring Dimensions (Categories, Groups, Unique Values)
--    - Find unique values in categorical columns (e.g., vehicle types: bikes, cars).
SELECT DISTINCT "Item"
FROM cleaned_cafe_sales;

-- INSIGHT: unique values - cake, salad, tea, coffee, juice, smoothie, cookie, and sandwich

SELECT DISTINCT "Payment Method"
FROM cleaned_cafe_sales;

-- INSIGHT: unique values - credit card, cash, digital wallet, null

SELECT DISTINCT "Location"
FROM cleaned_cafe_sales;

-- INSIGHT: unique values - takeaway, In-store, UNKNOWN

SELECT "Item", COUNT(*) AS number_of_occurrences
FROM cleaned_cafe_sales
GROUP BY "Item"
ORDER BY number_of_occurrences DESC;
-- INSIGHT: coffee is the most bought item while smoothie is the least

SELECT "Payment Method", COUNT(*) AS number_of_occurrences
FROM cleaned_cafe_sales
GROUP BY "Payment Method"
ORDER BY number_of_occurrences DESC;
-- INSIGHT: most are null values but digital wallet is the most used as payment method following credit card and cash

SELECT "Location", COUNT(*) AS number_of_occurrences
FROM cleaned_cafe_sales
GROUP BY "Location"
ORDER BY number_of_occurrences DESC;
-- INSIGHT: most location are unknown but takeaway is the most type of location or order or wtv followed by in-store

-- 3. Exploring Dates
--    - Identify the earliest and latest dates.
--    - Determine the time span covered in the dataset.
SELECT MIN("Transaction Date") AS earliest, MAX("Transaction Date") AS latest, 
			(MAX("Transaction Date") - MIN("Transaction Date")) AS timespan_in_days,
			(MAX("Transaction Date") - MIN("Transaction Date"))/30 AS timespan_in_months,
			(MAX("Transaction Date") - MIN("Transaction Date"))/365 AS timespan_in_years
FROM cleaned_cafe_sales;

-- INSIGHT: earliest date is from jan 1, 2023 with dec 31 being the latest. 
-- only have one year gap, but based on the result, just one day short.

-- 4. Exploring Measures (Numerical Analysis)
--    - Calculate summary statistics (sum, avg, min, max, etc.).
-- sum, avg, min, max of items, price per unit, total spent
--    - Identify outliers or large values that might skew the data.

SELECT SUM("Quantity") AS total_quantity,
	   ROUND(AVG("Quantity"), 2) AS avg_quantity,
	   MIN("Quantity") AS min_quantity,
	   PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY "Quantity") AS median_value_quantity,
	   MAX("Quantity") AS max_quantity,
	   SUM("Total Spent") AS total_total_spent,
	   ROUND(AVG("Total Spent"), 2) AS avg_total_spent,
	   MIN("Total Spent") AS min_total_spent,
	   PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY "Total Spent") AS median_value_total_spent,
	   MAX("Total Spent") AS max_total_spent,
	   SUM("Price Per Unit") AS total_price_per_unit,
	   MIN("Price Per Unit") AS min_price_per_unit,
	   PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY "Price Per Unit") AS median_value_price_per_unit,
	   MAX("Price Per Unit") AS max_price_per_unit
FROM ccs;

-- INSIGHT: total spent is slight right skewed

-- checking skewness
SELECT (3 * (AVG("Quantity") - PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY "Quantity"))) 
        / STDDEV("Quantity") AS skewness
FROM ccs;
-- INSIGHT: skewness is 0.04614482915951894 and has no outlier

--    - Generate summary reports for key metrics.

SELECT 'Total Quantity Sold' AS metric, ROUND(SUM("Quantity")) AS value
FROM ccs
UNION ALL 
SELECT 'Average Quantity Per Transaction', ROUND(AVG("Quantity"))
FROM ccs
UNION ALL 
SELECT 'Max Quantity Per Transaction', ROUND(MAX("Quantity"))
FROM ccs
UNION ALL 
SELECT 'Min Quantity Per Transaction', ROUND(MIN("Quantity"))
FROM ccs
UNION ALL 
SELECT 'Overall Spent', ROUND(SUM("Total Spent"))
FROM ccs
UNION ALL 
SELECT 'Avg Spent Per Transaction', ROUND(AVG("Total Spent"))
FROM ccs
UNION ALL 
SELECT 'Max Spent Per Transaction', ROUND(MAX("Total Spent"))
FROM ccs
UNION ALL 
SELECT 'Median Spent Per Transaction', PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY "Total Spent")
FROM ccs
UNION ALL 
SELECT 'Min Spent Per Transaction', ROUND(MIN("Total Spent"))
FROM ccs;

-- 5. Exploring Magnitude (Measures by Dimensions)
--    - Group numerical measures by dimensions (e.g., total number of bikes by country).
SELECT DISTINCT("Item"), ROUND(SUM("Quantity"),2) AS total_order
FROM ccs
GROUP BY "Item"
ORDER BY total_order DESC;


-- INSIGHT: Coffee has the highest total order with Smoothie the least

SELECT DISTINCT("Payment Method"), ROUND(COUNT("Payment Method") )total_count
FROM ccs
WHERE "Payment Method" IS NOT NULL
GROUP BY "Payment Method"
ORDER BY total_count DESC;

-- INSIGHT: Digital wallet is the most used while cash is the least

SELECT "Transaction Date", TO_CHAR("Transaction Date"::DATE, 'Mon') AS month_abbrev,
		ROUND(SUM("Quantity"),2) AS total_order, ROUND(SUM("Total Spent"),2) AS spent
FROM ccs
WHERE "Transaction Date" IS NOT NULL
GROUP BY "Transaction Date"
ORDER BY total_order DESC;

-- INSIGHT: July has the most sales across all item

SELECT TO_CHAR("Transaction Date"::DATE, 'Mon') AS month_abbrev,
       COUNT(*) AS month_total
FROM ccs
WHERE "Transaction Date" IS NOT NULL
GROUP BY TO_CHAR("Transaction Date"::DATE, 'Mon')
ORDER BY month_total DESC;

-- INSIGHT: October has the most transaction

SELECT "Location", COUNT("Transaction ID") AS total_transaction
FROM ccs
WHERE "Transaction ID" IS NOT NULL 
AND "Location" IS NOT NULL
AND "Location" != 'UNKNOWN'
GROUP BY "Location"
ORDER BY "Location" DESC;

-- Takeaway are the most location

--    - Compare results across different groups for insights.

-- A. Trend Analysis
--    - How do sales/orders fluctuate across months?
SELECT 
    TO_CHAR("Transaction Date"::DATE, 'Mon') AS month_abbrev,
    COUNT(*) AS transaction_count,
    SUM("Total Spent") AS total_spent
FROM ccs
WHERE "Item" = 'Coffee'
AND "Transaction Date" IS NOT NULL
GROUP BY month_abbrev
ORDER BY transaction_count DESC;  

-- INSIGHT: highest sale and transaction of coffee were on October
-- spikes were pretty random: Mar, Jun to August, Oct, Dec
-- I guess we can say latest months of the year is the most time for coffee

-- SUMMARY REPORT
SELECT 
    TO_CHAR("Transaction Date"::DATE, 'Mon') AS month_abbrev,
    COUNT(*) AS transaction_count,
    SUM("Total Spent") AS total_spent
FROM ccs
WHERE "Item" = 'Coffee'
AND "Transaction Date" IS NOT NULL
AND (EXTRACT(MONTH FROM "Transaction Date") = 10
     OR EXTRACT(MONTH FROM "Transaction Date") = 9)
GROUP BY month_abbrev
ORDER BY transaction_count DESC;  

-- INSIGHT: October has the highest sales and transaction where september has the least

-- B. Correlation & Relationships
--    - Do certain payment methods dominate during high-sales months?

SELECT DISTINCT ON (TO_CHAR("Transaction Date", 'MM')) 
    TO_CHAR("Transaction Date", 'MM') AS month_num,  
    "Payment Method",  
    COUNT(*) AS transaction_count  
FROM ccs  
WHERE "Transaction Date" IS NOT NULL  
AND "Payment Method" IS NOT NULL  
GROUP BY "Payment Method", TO_CHAR("Transaction Date", 'MM')  
ORDER BY TO_CHAR("Transaction Date", 'MM'), transaction_count DESC;

-- REPORT
SELECT 
    COUNT(*) FILTER (WHERE "Payment Method" = 'Digital Wallet') AS digital_wallet_count,
    COUNT(*) FILTER (WHERE "Payment Method" = 'Credit Card') AS credit_card_count,
    COUNT(*) FILTER (WHERE "Payment Method" = 'Cash') AS cash_count
FROM (
    SELECT DISTINCT ON (TO_CHAR("Transaction Date", 'MM')) 
        TO_CHAR("Transaction Date", 'MM') AS month_num,  
        "Payment Method"
    FROM ccs  
    WHERE "Transaction Date" IS NOT NULL  
    AND "Payment Method" IS NOT NULL  
    GROUP BY "Payment Method", TO_CHAR("Transaction Date", 'MM')  
    ORDER BY TO_CHAR("Transaction Date", 'MM'), COUNT(*) DESC
) AS top_methods;

-- INSIGHT: digital wallet x credit card dominates

--    - Do locations with high transaction counts also have high revenue?
SELECT "Location",
		COUNT("Transaction ID") AS transaction_count,
		SUM("Total Spent") AS total_revenue
FROM ccs
WHERE "Location" != 'UNKNOWN'
GROUP BY "Location"
ORDER BY total_revenue DESC;

-- INSIGHT: even with high transaction count, revenue is not higher with it

--    - Are expensive items contributing more to total revenue, or is volume driving sales?
SELECT ROUND(AVG("Price Per Unit"),2) AS avg_price,
	   PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY "Price Per Unit") AS median_price,
	   SUM("Total Spent") FILTER(WHERE "Price Per Unit" >= 3.00) AS total_revenue_by_expensive_items,
	   ROUND(SUM("Total Spent"),2) AS total_revenue_by_volume
FROM ccs;
-- INSIGHT: the sales is driven by volume

-- C. Outliers & Anomalies
--    - Are there months with unusually high or low transactions? Why?
SELECT 
    TO_CHAR("Transaction Date", 'Mon') AS month_abbrev, 
    COUNT(*) AS all_transactions,
    EXTRACT(YEAR FROM "Transaction Date") AS year  -- Include year to check trends across years
FROM ccs
WHERE "Transaction Date" IS NOT NULL
GROUP BY month_abbrev, year
ORDER BY year, MIN("Transaction Date");
-- INSIGHT: October is unusually high. this was also the time where many sales are sold especially the coffee 

--    - Do some locations have significantly fewer transactions?

SELECT "Location", COUNT(*) as transactions,
		ROUND(COUNT(*) * 100 / SUM(COUNT(*)) OVER(), 2) as percentage
FROM ccs
WHERE "Location" != 'UNKNOWN'
GROUP BY "Location";

SELECT *
FROM ccs;

-- INSIGHT: yeah, takeaway is slight lower, very slight

--    - Are some payment methods underused despite high transaction volume?
SELECT "Payment Method", COUNT(*) as transactions,
		ROUND(COUNT(*) * 100 / SUM(COUNT(*)) OVER(), 2) as percentage
FROM ccs
WHERE "Payment Method" != 'UNKNOWN'
GROUP BY "Payment Method"
ORDER BY percentage DESC;

-- INSIGHT: cash might be the least use but no payment methods are underused

-- D. Customer Behavior & Preferences
--    - Which items are consistently selling well?
SELECT TO_CHAR("Transaction Date", 'YYYY-MM') AS month,  
       "Item",  
       COUNT(*) AS transactions,  
       ROUND(AVG("Total Spent")) AS avg_rev,  
       ROUND(SUM("Total Spent")) AS total_rev  
FROM ccs  
WHERE "Transaction Date" IS NOT NULL  
GROUP BY "Item", month  
ORDER BY month, transactions DESC;	

--    - Are there seasonal patterns in purchases (e.g., more coffee sales in colder months)?
-- let's just assume the country is philippines

SELECT TO_CHAR("Transaction Date", 'Mon') AS monthly,
       SUM("Quantity") AS total_quantity, 
       SUM("Total Spent") AS total_spent
FROM ccs
WHERE "Item" = 'Coffee'
AND "Transaction Date" IS NOT NULL
GROUP BY TO_CHAR("Transaction Date", 'Mon'), EXTRACT(MONTH FROM "Transaction Date")
ORDER BY total_spent DESC;

-- INSIGHT: no seasonal pattern. pretty random to me. i mean, when almost ber months, there's lots of orders especially oct and dec 
-- then there's jul, jun, and aug

--    - Do people spend more per transaction in some months than others?
-- INSIGHT: i just checked and my answer is this: pretty random to me. i mean, when almost ber months, there's lots of orders especially oct and dec 

-- E. Operational Efficiency
--    - Are there any inefficiencies in locations with high transactions but low total spending?

SELECT "Location", COUNT(*) AS total_transaction, SUM("Total Spent") AS total_spent, 
	    ROUND(AVG("Total Spent"),2) AS avg_spent, ROUND(AVG("Price Per Unit"),2) AS avg_price
FROM ccs
WHERE "Location" != 'UNKNOWN'
GROUP BY "Location", "Total Spent" 
ORDER BY total_transaction DESC;

-- INSIGHT: There are no inefficiency

--    - Generate reports based on grouped measures.

SELECT 'Item: Coffee' AS highest_value, ROUND(SUM("Quantity"),2) AS value
FROM ccs
WHERE "Item" = 'Coffee'
GROUP BY "Item"
UNION ALL
SELECT 'Payment Method: Digital Wallet' AS measures, ROUND(COUNT("Payment Method")) AS value
FROM ccs
WHERE "Payment Method" = 'Digital Wallet'
GROUP BY "Payment Method"
UNION ALL
SELECT 'Month: July Total Spent' AS measures, ROUND(SUM("Total Spent"),2) AS value
FROM ccs
WHERE EXTRACT(MONTH FROM "Transaction Date") = 7
UNION ALL
SELECT 'Month: October Transactions' AS measures, COUNT(*) AS value
FROM ccs
WHERE EXTRACT(MONTH FROM "Transaction Date") = 10
UNION ALL
SELECT 'Location: Takeaway Transactions' AS measures, COUNT("Transaction ID") AS value
FROM ccs
WHERE "Transaction ID" IS NOT NULL 
AND "Location" = 'Takeaway';

-- 6. Ranking Analysis
--    - Rank dimensions by key measures (e.g., top 5 countries by total sales).

SELECT "Item", 
       SUM("Total Spent") AS total_spent,
       RANK() OVER(ORDER BY SUM("Total Spent") DESC) AS rank_num
FROM ccs
GROUP BY "Item"
LIMIT 5;

SELECT "Item", SUM("Total Spent") AS total_spent
FROM ccs
GROUP BY "Item"
ORDER BY total_spent DESC
LIMIT 5;

-- I think I'm done here

