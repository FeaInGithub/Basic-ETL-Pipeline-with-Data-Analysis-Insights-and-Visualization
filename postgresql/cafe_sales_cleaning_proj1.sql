-- =====================================
--        CAFE SALES DATA CLEANING
-- =====================================
DROP TABLE IF EXISTS cafe_sales;

-- Creating the table and initially importing all fields as text due to inconsistent data formatting
CREATE TABLE cafe_sales (
    "Transaction ID" TEXT,
    "Item" TEXT,
    "Quantity" TEXT, 
    "Price Per Unit" TEXT, 
    "Total Spent" TEXT,
    "Payment Method" TEXT,
    "Location" TEXT,
    "Transaction Date" TEXT
);

COPY cafe_sales FROM 'E:\Data Analysis\Dataset\dirty_cafe_sales.csv' DELIMITER ',' CSV HEADER;

-- Creating a backup copy of the original dataset
CREATE TABLE cafe_sales_copy AS SELECT * FROM cafe_sales;

-- Creating a view for simplified querying
CREATE VIEW cs AS SELECT * FROM cafe_sales_copy;

-- >> CHECKING FOR COLUMNS WITH INAPPRORIATE VALUES

-- Checking for inappropriate values in multiple columns
SELECT "Transaction ID", "Item", "Quantity", "Price Per Unit", "Total Spent", "Payment Method", "Location", "Transaction Date"
FROM cs
WHERE "Transaction ID" IN ('UNKNOWN', 'ERROR') 
   OR "Item" IN ('UNKNOWN', 'ERROR')
   OR "Quantity" IN ('UNKNOWN', 'ERROR')
   OR "Price Per Unit" IN ('UNKNOWN', 'ERROR')
   OR "Total Spent" IN ('UNKNOWN', 'ERROR')
   OR "Payment Method" IN ('UNKNOWN', 'ERROR')
   OR "Location" IN ('UNKNOWN', 'ERROR')
   OR "Transaction Date" IN ('UNKNOWN', 'ERROR');

-- Changing 'UNKNOWN' and 'ERROR' values to NULL
UPDATE cs
SET 
    "Transaction ID" = CASE WHEN "Transaction ID" IN ('UNKNOWN', 'ERROR') THEN NULL ELSE "Transaction ID" END,
    "Item" = CASE WHEN "Item" IN ('UNKNOWN', 'ERROR') THEN NULL ELSE "Item" END,
    "Quantity" = CASE WHEN "Quantity" IN ('UNKNOWN', 'ERROR') THEN NULL ELSE "Quantity" END,
    "Price Per Unit" = CASE WHEN "Price Per Unit" IN ('UNKNOWN', 'ERROR') THEN NULL ELSE "Price Per Unit" END,
    "Total Spent" = CASE WHEN "Total Spent" IN ('UNKNOWN', 'ERROR') THEN NULL ELSE "Total Spent" END,
    "Payment Method" = CASE WHEN "Payment Method" IN ('UNKNOWN', 'ERROR') THEN NULL ELSE "Payment Method" END,
    "Location" = CASE WHEN "Location" IN ('UNKNOWN', 'ERROR') THEN NULL ELSE "Location" END,
    "Transaction Date" = CASE WHEN "Transaction Date" IN ('UNKNOWN', 'ERROR') THEN NULL ELSE "Transaction Date" END
WHERE 
    "Transaction ID" IN ('UNKNOWN', 'ERROR') 
    OR "Item" IN ('UNKNOWN', 'ERROR') 
    OR "Quantity" IN ('UNKNOWN', 'ERROR') 
    OR "Price Per Unit" IN ('UNKNOWN', 'ERROR') 
    OR "Total Spent" IN ('UNKNOWN', 'ERROR') 
    OR "Payment Method" IN ('UNKNOWN', 'ERROR') 
    OR "Location" IN ('UNKNOWN', 'ERROR') 
    OR "Transaction Date" IN ('UNKNOWN', 'ERROR');

-- Checking for unique values in each column
SELECT DISTINCT "Transaction ID" FROM cs;
SELECT DISTINCT "Item" FROM cs;
SELECT DISTINCT "Quantity" FROM cs;
SELECT DISTINCT "Price Per Unit" FROM cs;
SELECT DISTINCT "Total Spent" FROM cs;
SELECT DISTINCT "Payment Method" FROM cs;
SELECT DISTINCT "Location" FROM cs;
SELECT DISTINCT "Transaction Date" FROM cs;

-- RESULT: No more inappropriate values

-- >> ALTERING DATA TYPES FROM TEXT SINCE INAPPROPRIATE VALUES WERE REMOVED

-- Dropping the view since it will be affected
DROP VIEW IF EXISTS cs;

-- Altering data types for multiple columns
ALTER TABLE cafe_sales_copy
ALTER COLUMN "Transaction ID" SET DATA TYPE VARCHAR(25),
ALTER COLUMN "Item" SET DATA TYPE VARCHAR(25),
ALTER COLUMN "Payment Method" SET DATA TYPE VARCHAR(25),
ALTER COLUMN "Location" SET DATA TYPE VARCHAR(25);

ALTER TABLE cafe_sales_copy
ALTER COLUMN "Transaction Date" SET DATA TYPE DATE
USING "Transaction Date"::DATE;

-- Altering "Quantity" to INT and checking max value before altering Price Per Unit
ALTER TABLE cafe_sales_copy
ALTER COLUMN "Quantity" SET DATA TYPE INT
USING "Quantity"::INTEGER;

-- Checking the max value for Price Per Unit for numeric accuracy
SELECT MAX(CAST("Price Per Unit" AS DECIMAL)) AS Highest_Price_Per_Unit
FROM cafe_sales_copy;

-- Altering "Price Per Unit" to NUMERIC
ALTER TABLE cafe_sales_copy
ALTER COLUMN "Price Per Unit" SET DATA TYPE NUMERIC(3,2)
USING "Price Per Unit"::NUMERIC(3,2);

-- Checking the max value for Total Spent for numeric accuracy
SELECT MAX(CAST("Total Spent" AS DECIMAL)) AS Highest_Total_Spent
FROM cafe_sales_copy;

-- Altering "Total Spent" to NUMERIC
ALTER TABLE cafe_sales_copy
ALTER COLUMN "Total Spent" SET DATA TYPE NUMERIC(5,2)
USING "Total Spent"::NUMERIC(5,2);

-- Checking
SELECT *
FROM cafe_sales_copy;

-- Creating view again
CREATE VIEW cs AS SELECT * FROM cafe_sales_copy;

-- >> POPULATING NULL VALUES
-- Identifying the prices of each item first
SELECT DISTINCT "Item", "Price Per Unit"
FROM cs
WHERE "Item" IS NOT NULL 
AND "Price Per Unit" IS NOT NULL
ORDER BY "Price Per Unit";

-- NOTE: These prices will be used to populate missing (NULL) "Price Per Unit", "Item", and "Total Spent" values

-- Populating missing (NULL) "Item" values, but only those with unique prices.
-- A CTE is used to map prices to items before updating the table.
WITH price_lookup AS (
    SELECT "Item", "Price Per Unit",
        CASE
            WHEN "Price Per Unit" = 1.00 THEN 'Cookie'
            WHEN "Price Per Unit" = 1.50 THEN 'Tea'
            WHEN "Price Per Unit" = 2.00 THEN 'Coffee'
            WHEN "Price Per Unit" = 5.00 THEN 'Salad'
            ELSE NULL
        END AS item_price
    FROM cs
    WHERE "Item" IS NULL
    AND "Price Per Unit" NOT IN (3.00, 4.00) 
)
UPDATE cs
SET "Item" = price_lookup.item_price
FROM price_lookup
WHERE cs."Price Per Unit" = price_lookup."Price Per Unit"
AND cs."Item" IS NULL;

-- Populating missing (NULL) "Price Per Unit" values
-- A CTE is used to map prices to items before updating the table.
WITH price_lookup AS (
    SELECT "Item", "Price Per Unit",
        CASE
            WHEN "Item" = 'Cookie' THEN 1.00
            WHEN "Item" = 'Tea' THEN 1.50
            WHEN "Item" = 'Coffee' THEN 2.00
            WHEN "Item" = 'Cake' THEN 3.00
            WHEN "Item" = 'Juice' THEN 3.00
            WHEN "Item" = 'Smoothie' THEN 4.00
            WHEN "Item" = 'Sandwich' THEN 4.00
            WHEN "Item" = 'Salad' THEN 5.00
            ELSE NULL
        END AS item_price
    FROM cs
    WHERE "Price Per Unit" IS NULL
	AND "Item" IS NOT NULL
)
UPDATE cs
SET "Price Per Unit" = price_lookup.item_price
FROM price_lookup
WHERE cs."Item" = price_lookup."Item"
AND cs."Price Per Unit" IS NULL;

-- Checking 
SELECT "Item", "Price Per Unit"
FROM cs
WHERE "Price Per Unit" NOT IN (3.00, 4.00);

-- NOTE: Noting there are 4962 rows.

-- Populating missing (NULL) "Total Spent" values
-- Testing how "Total Spent" would be computed
SELECT "Quantity", "Price Per Unit",
       ("Quantity" * "Price Per Unit") AS total_spent
FROM cs
WHERE "Total Spent" IS NULL
AND "Quantity" IS NOT NULL
AND "Price Per Unit" IS NOT NULL;

-- Updating 
UPDATE cs
SET "Total Spent" = "Quantity" * "Price Per Unit"
WHERE "Total Spent" IS NULL
AND "Quantity" IS NOT NULL
AND "Price Per Unit" IS NOT NULL;

-- Analyzing the raw data for repopulation of other missing values
SELECT "Item", "Quantity", "Price Per Unit", "Total Spent"
FROM cs;

-- FINDINGS: Rows with missing Quantity and Total Spent can no longer be populated,
-- since one is needed to calculate the other (Total Spent = Quantity * Price Per Unit).

-- Analyzing missing Item values where the Price Per Unit is not ambiguous (i.e., not 3.00 or 4.00)
SELECT "Item", "Quantity", "Price Per Unit", "Total Spent"
FROM cs
WHERE "Item" IS NULL
AND "Price Per Unit" NOT IN (3.00, 4.00);

-- NOTE: There are no results for rows where "Item" is missing and "Price Per Unit" is not 3.00 or 4.00, since these entries have non-ambiguous price values.
-- However, rows with missing "Item" values and a "Price Per Unit" of 3.00 or 4.00 cannot be reliably populated, 
-- as these price points are associated with multiple items, making it impossible to determine the correct "Item" without further information.

-- Repopulating quantity missing values
-- Testing
SELECT "Item", "Quantity", "Price Per Unit", "Total Spent",
       CASE
           WHEN "Quantity" IS NULL 
                AND "Price Per Unit" IS NOT NULL 
                AND "Total Spent" IS NOT NULL
           THEN ROUND("Total Spent" / "Price Per Unit")
           ELSE "Quantity"
       END AS filled_quantity
FROM cs
ORDER BY "Item";

-- Updating
UPDATE cs
SET "Quantity" = CASE
			           WHEN "Quantity" IS NULL 
			                AND "Price Per Unit" IS NOT NULL 
			                AND "Total Spent" IS NOT NULL
			           THEN ROUND("Total Spent" / "Price Per Unit")
			           ELSE "Quantity"
			       END
WHERE "Quantity" IS NULL
AND "Price Per Unit" IS NOT NULL 
AND "Total Spent" IS NOT NULL;

-- Repopulating price per unit missing values
-- Testing
SELECT "Item", "Quantity", "Total Spent", 
       ROUND("Total Spent" / "Quantity", 2) AS "Calculated Price Per Unit"
FROM cs
WHERE "Price Per Unit" IS NULL
AND "Quantity" IS NOT NULL 
AND "Total Spent" IS NOT NULL;

-- Updating
UPDATE cs 
SET "Price Per Unit" = ROUND("Total Spent" / "Quantity", 2)
WHERE "Price Per Unit" IS NULL
AND "Quantity" IS NOT NULL 
AND "Total Spent" IS NOT NULL;

-- Repopulating item missing values 
UPDATE cs
SET "Item" = CASE
            WHEN "Price Per Unit" = 1.00 THEN 'Cookie'
            WHEN "Price Per Unit" = 1.50 THEN 'Tea'
            WHEN "Price Per Unit" = 2.00 THEN 'Coffee'
            WHEN "Price Per Unit" = 5.00 THEN 'Salad'
            ELSE NULL
        END
WHERE "Item" IS NULL
AND "Price Per Unit" NOT IN (3.00, 4.00);

-- Re-checking
SELECT "Item", "Quantity", "Price Per Unit", "Total Spent"
FROM cs
WHERE "Price Per Unit" NOT IN (3.00, 4.00)
AND (
    "Item" IS NULL
    OR "Quantity" IS NULL
    OR "Price Per Unit" IS NULL
    OR "Total Spent" IS NULL
);

-- RESULT: No further repopulation is needed, as the latest result (10 rows) showed missing values in both "Quantity" and "Total Spent," 
-- which cannot be computed.

-- Final Check
SELECT *
FROM cs;

-- CONCLUSION: Missing values in payment method, location, and transaction date are beyond available data and cannot be accurately populated.
-- Filling them may lead to inaccurate or misleading results.
-- Therefore, these fields are left as-is.

-- Creating cleaned version table
CREATE TABLE cafe_sales_cleaned AS SELECT * FROM cs;

-- =====================================
--  CAFE SALES DATA CLEANING COMPLETED
-- =====================================