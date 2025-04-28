-- =====================================
--            CAFE SALES EDA
-- =====================================
-- OBJECTIVE:
-- Identify the top-selling items of the cafe
-- Understand the cafe’s performance and sales trends
-- Analyze operations based on payment methods and order locations

-- DISCLAIMER: 
-- Some data still have missing or null values even after cleaning and cannot be populated to avoid inaccuracies.

-- Creating a shortcut view
CREATE VIEW csc AS SELECT * FROM cafe_sales_cleaned;

-- 1. BASIC OVERVIEW
-- How many transactions are in the dataset?
SELECT COUNT(*)
FROM cafe_sales_cleaned;

-- RESULT: There were a total of 10k transactions

-- How many unique items were sold?
SELECT COUNT(DISTINCT "Item")
FROM csc
WHERE "Item" IS NOT NULL;

-- RESULT: There were 8 unique items sold.

-- What is the total revenue?
SELECT SUM("Total Spent")
FROM csc;

-- RESULT: The cafe earned around $89k total revenue.

-- What is the average revenue per transaction?
SELECT ROUND(AVG("Total Spent"),2) AS avg_transaction
FROM csc;

-- RESULT: The average revenue per transaction was $8.93.
-- This suggests that the cafe is moderately priced, offering affordable options where customers likely purchase drinks and pastries or food 
-- to enjoy and relax.

-- What is the average quantity per transaction?
SELECT ROUND(AVG("Quantity")) AS avg_transaction
FROM csc;

-- RESULT: The average quantity per transaction was 3.
-- This likely implies that customers often buy in small groups, possibly for friends or shared orders
-- or combo-style eating preferences.

-- 2. SALES PERFORMANCE
-- What are the top 5 best-selling items by quantity?
SELECT "Item", ROUND(SUM("Quantity")) AS quantity
FROM csc
WHERE "Quantity" IS NOT NULL
GROUP BY "Item"
ORDER BY quantity DESC
LIMIT 5;

-- RESULT: The top 5 best-selling items were coffee, salad, tea, cookie, and juice.
-- This suggests that most customers tend to prefer drinks like coffee, tea, and juice, with salad surprisingly ranking second.
-- Coffee remains the best-selling item.

-- Which items generated the highest total revenue?
SELECT "Item", ROUND(SUM("Total Spent")) AS total_revenue
FROM csc
WHERE "Item" IS NOT NULL
GROUP BY "Item"
ORDER BY total_revenue DESC;

-- RESULT: Salad has the highest total revenue.
-- The high revenue suggests that its higher price point ($5.00) contributed to this. It is followed by sandwich ($4.00) and smoothie ($4.00), 
-- both of which are also priced relatively high compared to other items, with cookie being the lowest-priced item ($1.00).

-- What is the average total spent per unit of each item?
SELECT 
  "Item", 
  ROUND(SUM("Total Spent") / SUM("Quantity"), 2) AS avg_revenue_per_unit
FROM csc
WHERE "Item" IS NOT NULL
GROUP BY "Item"
ORDER BY avg_revenue_per_unit DESC;

-- RESULT: The average total spent per item closely matches their original prices.
-- This suggests that most customers likely purchase just one unit of each item per transaction.

-- Which items have the lowest sales or revenue?
SELECT "Item", ROUND(SUM("Total Spent")) AS total_revenue
FROM csc
WHERE "Item" IS NOT NULL
GROUP BY "Item"
ORDER BY total_revenue;

-- RESULT: Cookie, tea, and coffee generate the lowest total revenue, likely due to their lower individual prices despite being popular.

-- 3. TIME-BASED TRENDS
-- Daily Sales
SELECT 
  "Transaction Date"::DATE AS daily,
  ROUND(SUM("Total Spent"), 2) AS daily_sales
FROM csc
WHERE "Transaction Date" IS NOT NULL
GROUP BY daily
ORDER BY daily;

-- RESULT: Daily sales range from over $100 to over $300.

-- Weekly Sales
SELECT 
  DATE_TRUNC('week', "Transaction Date")::DATE AS week_start,
  ROUND(SUM("Total Spent"), 2) AS weekly_sales
FROM csc
WHERE "Transaction Date" IS NOT NULL
GROUP BY week_start
ORDER BY week_start;

-- RESULT: Weekly sales range from over $130 to over $1800.

-- Monthly Sales
SELECT 
  EXTRACT(YEAR FROM "Transaction Date") AS year,
  EXTRACT(MONTH FROM "Transaction Date") AS month,
  ROUND(SUM("Total Spent"), 2) AS monthly_sales
FROM csc
WHERE "Transaction Date" IS NOT NULL
GROUP BY year, month
ORDER BY year, month;

-- RESULT: Monthly sales range from over $6600 to over $7300.
-- The results suggest that the cafe earned a moderate total revenue daily, weekly, and monthly, making it a reputable business.

-- On which days does the cafe earn the most revenue?
SELECT 
  TO_CHAR("Transaction Date"::DATE, 'FMDay') AS day_of_week,
  ROUND(SUM("Total Spent"), 2) AS total_revenue
FROM csc
WHERE "Transaction Date" IS NOT NULL
GROUP BY day_of_week
ORDER BY total_revenue DESC;
 
-- RESULT: Thursday, Friday, and Sunday generated the most revenue.
-- This suggests that more people tend to visit the cafe toward the end of the week, possibly as a way to unwind or
-- because they've saved up more by that time.
-- Sunday, often considered a family day, might see increased visits from families dining out together.

-- How do sales vary between weekdays and weekends?
SELECT
  CASE 
    WHEN EXTRACT(DOW FROM "Transaction Date") IN (0, 6) THEN 'Weekend'
    ELSE 'Weekday'
  END AS day_type,
  ROUND(SUM("Total Spent"), 2) AS total_revenue,
  CONCAT(ROUND((SUM("Total Spent") / (SELECT SUM("Total Spent") FROM csc WHERE "Transaction Date" IS NOT NULL)) * 100, 2),'%') AS percentage_of_total
FROM csc
WHERE "Transaction Date" IS NOT NULL
GROUP BY day_type
ORDER BY total_revenue DESC;

-- RESULT: Weekdays generate 71.35% more revenue than weekends. 
-- This suggests that people are more likely to visit the cafe on weekdays, 
-- possibly during breaks at work or school, when there is typically more foot traffic outside compared to weekends.

-- 4. ORDER TYPE ANALYSIS
-- How many transactions were dine-in vs takeout?
SELECT "Location", COUNT(*) AS transaction_count
FROM csc
WHERE "Location" IN ('Takeaway', 'In-store')
GROUP BY "Location"
ORDER BY transaction_count DESC;

-- RESULT: Most transactions were takeaway (3022), closely followed by in-store (3017).
-- This suggests that the cafe experiences a nearly equal number of dine-in and takeaway customers, indicating a consistently busy environment.
-- It may also imply, speculatively, that some customers opt for takeaway due to limited seating availability.

-- How does total spent differ between dine-in and takeout?
SELECT "Location", ROUND(SUM("Total Spent")) AS total_spent
FROM csc
WHERE "Location" IN ('Takeaway', 'In-store')
GROUP BY "Location"
ORDER BY total_spent DESC;

-- RESULT: The total amount spent is slightly higher for in-store transactions compared to takeaway, though the difference isn't much.
-- This may suggest that either more orders are placed in-store, or that customers dining in tend to purchase higher-priced items.

-- What are the most popular items for dine-in and for takeout?
SELECT "Location", "Item", COUNT(*) AS item_counts
FROM csc
WHERE "Location" IS NOT NULL AND "Item" IS NOT NULL
GROUP BY "Location", "Item"
ORDER BY item_counts DESC;

-- RESULT: The most popular item for in-store is Salad, while for Takeaway, it’s Cookie. Coffee ranks second in popularity for Takeaway.
-- This suggests that Salad and Cookie are particularly popular and may be considered favorites in the cafe.
-- The cafe might also be popular for takeaway coffee, possibly indicating that customers enjoy drinking coffee while on the go.

-- 5. PAYMENT METHOD INSIGHTS
-- What are the most commonly used payment methods?
SELECT "Payment Method", COUNT(*) AS payment_method_counts
FROM csc
WHERE "Payment Method" IS NOT NULL
GROUP BY "Payment Method"
ORDER BY payment_method_counts DESC;

-- RESULT: The most commonly used payment method is Digital Wallet, followed closely by Credit Card and Cash. 
-- The difference in usage between these payment methods is relatively small.
-- This suggests that many customers prefer technology-based payment methods, with Digital Wallet leading the way.
-- However, the small difference between payment methods indicates that a portion of customers still prefer or rely on physical cash,
-- possibly due to convenience or personal preference.

-- How does the average total spent vary by payment method?
SELECT "Payment Method", ROUND(AVG("Total Spent"),2) AS avg_total_spent
FROM csc
WHERE "Payment Method" IS NOT NULL
GROUP BY "Payment Method"
ORDER BY avg_total_spent DESC;

-- RESULT: Cash has the highest average total spent, followed by credit cards and digital wallets.
-- While digital wallets are the most commonly used payment method, transactions made with cash tend to be of higher value.
-- This may suggest that customers spend more per transaction when using physical cash compared to digital or card payments, 
-- though further analysis may be needed to confirm this behavior.

-- Are certain items more popular with specific payment methods?
SELECT "Payment Method", "Item", COUNT(*) AS item_counts
FROM csc
WHERE "Payment Method" IS NOT NULL AND "Item" IS NOT NULL
GROUP BY "Payment Method", "Item"
ORDER BY item_counts DESC;

-- RESULT: Salad appears to be more popular among customers paying with cash and credit cards, 
-- while coffee is the most popular ordered item by those using digital wallets.
-- This might suggest a link between spending habits and preferred items based on payment method.

-- 6. ITEM-LEVEL INSIGHTS
-- What is the total quantity sold per item?
SELECT "Item", ROUND(SUM("Quantity")) AS total_quantity
FROM csc
WHERE "Item" IS NOT NULL
GROUP BY "Item"
ORDER BY total_quantity DESC;

-- RESULT: All item quantity were sold as 3k all. Coffee has the most sold.
-- This may suggest that coffee is the cafe's most sold item.

-- Which items are frequently purchased together?
SELECT 
  a."Item" AS Item1,
  b."Item" AS Item2,
  COUNT(*) AS Frequency
FROM csc a
JOIN csc b 
  ON a."Transaction ID" = b."Transaction ID"
  AND a."Item" < b."Item"
WHERE a."Item" IS NOT NULL AND b."Item" IS NOT NULL
GROUP BY a."Item", b."Item"
ORDER BY Frequency DESC;

-- RESULT: Based on current data, no transactions contain more than one item.
-- This limits our ability to analyze frequently purchased item pairs. 
-- The absence of multi-item transactions may be due to incomplete data.


-- 7. CUSTOMER BEHAVIOR
-- Are there repeated purchases of the same items across different days?
SELECT "Item", COUNT(DISTINCT CAST("Transaction Date" AS DATE)) AS days_purchased
FROM csc
WHERE "Item" IS NOT NULL AND "Transaction Date" IS NOT NULL
GROUP BY "Item"
HAVING COUNT(DISTINCT CAST("Transaction Date" AS DATE)) > 1
ORDER BY days_purchased DESC;

-- RESULT: Most items were purchased repeatedly across different days, but salad, coffee, and tea stand out as the top three. 
-- Salad and coffee are tied for first place in terms of repeated purchases. 
-- This suggests that the cafe's salad and coffee are the most popular and frequently bought items.

-- CONCLUSION:
-- Throughout the exploration, salad and coffee appear to be the best-selling items for this cafe, as they repeatedly show up in the top results.
-- The cafe is likely popular among workers, students, and groups, suggesting it is a busy spot, especially towards the end of the week and on Sundays.
-- Most of the orders were for takeout, though in-store orders are almost as frequent, indicating the cafe is likely busy with limited seating.
-- The cafe seems reputable and is likely earning a significant amount, with digital wallets appearing to be the most popular 
-- payment method, though cash and card payments are still fairly common.

-- =====================================
--         END OF CAFE SALES EDA
-- =====================================