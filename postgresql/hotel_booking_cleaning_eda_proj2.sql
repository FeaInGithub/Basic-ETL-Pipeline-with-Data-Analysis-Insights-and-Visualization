-- =====================================
--          HOTEL BOOKINGS EDA
-- =====================================
-- OBJECTIVE:
-- - Identify and compare trends between City and Resort hotels (bookings, cancellations, customer demographics)
-- - Analyze guest behavior and booking patterns to assess performance
-- - Evaluate potential reputation-impacting factors (e.g., cancellation rates, lead time, origin)

DROP TABLE IF EXISTS hotel_bookings;

-- Creating the hotel_bookings table with TEXT for all columns first
CREATE TABLE hotel_bookings (
    hotel TEXT,
    is_canceled TEXT,
    lead_time TEXT,    
    arrival_date_year TEXT,
    arrival_date_month TEXT,    
    arrival_date_week_number TEXT,    
    arrival_date_day_of_month TEXT,
    stays_in_weekend_nights TEXT,
    stays_in_week_nights TEXT,    
    adults TEXT,
    children TEXT, 
    babies TEXT,
    meal TEXT,
    country TEXT,
    market_segment TEXT,
    distribution_channel TEXT,
    is_repeated_guest TEXT, 
    previous_cancellations TEXT,
    previous_bookings_not_canceled TEXT,    
    reserved_room_type TEXT,
    assigned_room_type TEXT,
    booking_changes TEXT,
    deposit_type TEXT,
    agent TEXT,
    company TEXT, 
    days_in_waiting_list TEXT,
    customer_type TEXT,
    adr TEXT,
    required_car_parking_spaces TEXT,
    total_of_special_requests TEXT,
    reservation_status TEXT,
    reservation_status_date TEXT
);

COPY hotel_bookings FROM 'E:/Data Analysis/Dataset/hotel_bookings.csv' 
DELIMITER ',' CSV HEADER;

-- Verifying the data import
SELECT *
FROM hotel_bookings;

-- CREATING A COPY OF THE TABLE
DROP TABLE IF EXISTS hotel_bookings_copy;

-- Creating a duplicate of the hotel_bookings table
CREATE TABLE hotel_bookings_copy AS 
SELECT * FROM hotel_bookings;

-- CREATING A VIEW AS A SHORTCUT TO THE COPY
DROP VIEW IF EXISTS hbc;

CREATE VIEW hbc AS
SELECT * 
FROM hotel_bookings_copy;

-- Querying the view (shortcut) for data
SELECT *
FROM hbc;

-- >> DATA CLEANING
-- Replacing 'NA' and 'NULL' strings with actual NULLs for proper type casting later
-- Data was imported as TEXT, so cleanup is needed before conversion

SELECT DISTINCT reservation_status_date -- was done manually and found those need to be converted and updated them as follows
FROM hbc
WHERE reservation_status_date = 'NULL';

UPDATE hbc
SET children = NULL
WHERE children = 'NA';

UPDATE hbc
SET agent = NULL
WHERE agent = 'NULL';

UPDATE hbc
SET company = NULL
WHERE company = 'NULL';

SELECT *
FROM hbc;

-- dropping the view bc it cannot be altered
DROP VIEW hbc;

SELECT *
FROM hotel_bookings_copy;

-- altering data types from TEXT
ALTER TABLE hotel_bookings_copy
ALTER COLUMN hotel SET DATA TYPE VARCHAR(25);

ALTER TABLE hotel_bookings_copy
ALTER COLUMN is_canceled SET DATA TYPE INT
USING is_canceled::INTEGER;

ALTER TABLE hotel_bookings_copy
ALTER COLUMN lead_time SET DATA TYPE INT
USING lead_time::INTEGER;

ALTER TABLE hotel_bookings_copy
ALTER COLUMN arrival_date_year SET DATA TYPE INT
USING arrival_date_year::INTEGER;

ALTER TABLE hotel_bookings_copy
ADD CONSTRAINT arrival_date_year_constraints CHECK (arrival_date_year BETWEEN 1000 AND 9999);

ALTER TABLE hotel_bookings_copy
ALTER COLUMN arrival_date_month SET DATA TYPE VARCHAR(25);

ALTER TABLE hotel_bookings_copy
ALTER COLUMN arrival_date_week_number SET DATA TYPE INT
USING arrival_date_week_number::INTEGER;

ALTER TABLE hotel_bookings_copy
ALTER COLUMN arrival_date_day_of_month SET DATA TYPE INT
USING arrival_date_day_of_month::INTEGER;

ALTER TABLE hotel_bookings_copy
ALTER COLUMN stays_in_weekend_nights SET DATA TYPE INT
USING stays_in_weekend_nights::INTEGER;

ALTER TABLE hotel_bookings_copy
ALTER COLUMN stays_in_week_nights SET DATA TYPE INT
USING stays_in_week_nights::INTEGER;

ALTER TABLE hotel_bookings_copy
ALTER COLUMN adults SET DATA TYPE INT
USING adults::INTEGER;

ALTER TABLE hotel_bookings_copy
ALTER COLUMN children SET DATA TYPE INT
USING children::INTEGER;

ALTER TABLE hotel_bookings_copy
ALTER COLUMN babies SET DATA TYPE INT
USING babies::INTEGER;

ALTER TABLE hotel_bookings_copy
ALTER COLUMN meal SET DATA TYPE VARCHAR(10);

ALTER TABLE hotel_bookings_copy
ALTER COLUMN country SET DATA TYPE VARCHAR(25);

ALTER TABLE hotel_bookings_copy
ALTER COLUMN market_segment SET DATA TYPE VARCHAR(50);

ALTER TABLE hotel_bookings_copy
ALTER COLUMN distribution_channel SET DATA TYPE VARCHAR(50);

ALTER TABLE hotel_bookings_copy
ALTER COLUMN is_repeated_guest SET DATA TYPE INT
USING is_repeated_guest::INTEGER;

ALTER TABLE hotel_bookings_copy
ALTER COLUMN previous_cancellations SET DATA TYPE INT
USING previous_cancellations::INTEGER;

ALTER TABLE hotel_bookings_copy
ALTER COLUMN previous_bookings_not_canceled SET DATA TYPE INT
USING previous_bookings_not_canceled::INTEGER;

ALTER TABLE hotel_bookings_copy
ALTER COLUMN reserved_room_type SET DATA TYPE VARCHAR(2);

ALTER TABLE hotel_bookings_copy
ALTER COLUMN assigned_room_type SET DATA TYPE VARCHAR(2);

ALTER TABLE hotel_bookings_copy
ALTER COLUMN booking_changes SET DATA TYPE INT
USING booking_changes::INTEGER;

ALTER TABLE hotel_bookings_copy
ALTER COLUMN deposit_type SET DATA TYPE VARCHAR(25);

ALTER TABLE hotel_bookings_copy
ALTER COLUMN company SET DATA TYPE INT
USING company::INTEGER;

ALTER TABLE hotel_bookings_copy
ALTER COLUMN days_in_waiting_list SET DATA TYPE INT
USING days_in_waiting_list::INTEGER;

ALTER TABLE hotel_bookings_copy
ALTER COLUMN customer_type SET DATA TYPE VARCHAR(25);

ALTER TABLE hotel_bookings_copy
ALTER COLUMN adr SET DATA TYPE NUMERIC(6,2)
USING adr::NUMERIC(6,2);

ALTER TABLE hotel_bookings_copy
ALTER COLUMN required_car_parking_spaces SET DATA TYPE INT
USING required_car_parking_spaces::INTEGER;

ALTER TABLE hotel_bookings_copy
ALTER COLUMN total_of_special_requests SET DATA TYPE INT
USING total_of_special_requests::INTEGER;

ALTER TABLE hotel_bookings_copy
ALTER COLUMN reservation_status SET DATA TYPE VARCHAR(25);

ALTER TABLE hotel_bookings_copy
ALTER COLUMN reservation_status_date SET DATA TYPE DATE
USING reservation_status_date::DATE;

-- 1. DATA OVERVIEW & CLEANING
-- How many rows are in the dataset?
SELECT COUNT(*) AS row_count
FROM hotel_bookings_copy;

-- How many columns are in the dataset?
SELECT COUNT(*) AS column
FROM information_schema.columns 
WHERE table_name = 'hotel_bookings_copy';

-- NOTE: There were a total of 119345 rows and 32 columns

-- Are there any missing values? If so, which columns have them and how many?

-- Checking for missing values in each column
SELECT 'hotel' AS column_name, COUNT(*) FILTER (WHERE hotel = '' OR hotel IS NULL) AS empty_count FROM hotel_bookings_copy
UNION ALL
SELECT 'is_canceled', COUNT(*) FILTER (WHERE is_canceled IS NULL) FROM hotel_bookings_copy
UNION ALL
SELECT 'lead_time', COUNT(*) FILTER (WHERE lead_time IS NULL) FROM hotel_bookings_copy
UNION ALL
SELECT 'arrival_date_year', COUNT(*) FILTER (WHERE arrival_date_year IS NULL) FROM hotel_bookings_copy
UNION ALL
SELECT 'arrival_date_month', COUNT(*) FILTER (WHERE arrival_date_month = '' OR arrival_date_month IS NULL) FROM hotel_bookings_copy
UNION ALL
SELECT 'arrival_date_week_number', COUNT(*) FILTER (WHERE arrival_date_week_number IS NULL) FROM hotel_bookings_copy
UNION ALL
SELECT 'arrival_date_day_of_month', COUNT(*) FILTER (WHERE arrival_date_day_of_month IS NULL) FROM hotel_bookings_copy
UNION ALL
SELECT 'stays_in_weekend_nights', COUNT(*) FILTER (WHERE stays_in_weekend_nights IS NULL) FROM hotel_bookings_copy
UNION ALL
SELECT 'stays_in_week_nights', COUNT(*) FILTER (WHERE stays_in_week_nights IS NULL) FROM hotel_bookings_copy
UNION ALL
SELECT 'adults', COUNT(*) FILTER (WHERE adults IS NULL) FROM hotel_bookings_copy
UNION ALL
SELECT 'children', COUNT(*) FILTER (WHERE children IS NULL) FROM hotel_bookings_copy
UNION ALL
SELECT 'babies', COUNT(*) FILTER (WHERE babies IS NULL) FROM hotel_bookings_copy
UNION ALL
SELECT 'meal', COUNT(*) FILTER (WHERE meal = '' OR meal IS NULL) FROM hotel_bookings_copy
UNION ALL
SELECT 'country', COUNT(*) FILTER (WHERE country = '' OR country IS NULL) FROM hotel_bookings_copy
UNION ALL
SELECT 'market_segment', COUNT(*) FILTER (WHERE market_segment = '' OR market_segment IS NULL) FROM hotel_bookings_copy
UNION ALL
SELECT 'distribution_channel', COUNT(*) FILTER (WHERE distribution_channel = '' OR distribution_channel IS NULL) FROM hotel_bookings_copy
UNION ALL
SELECT 'is_repeated_guest', COUNT(*) FILTER (WHERE is_repeated_guest IS NULL) FROM hotel_bookings_copy
UNION ALL
SELECT 'previous_cancellations', COUNT(*) FILTER (WHERE previous_cancellations IS NULL) FROM hotel_bookings_copy
UNION ALL
SELECT 'previous_bookings_not_canceled', COUNT(*) FILTER (WHERE previous_bookings_not_canceled IS NULL) FROM hotel_bookings_copy
UNION ALL
SELECT 'reserved_room_type', COUNT(*) FILTER (WHERE reserved_room_type = '' OR reserved_room_type IS NULL) FROM hotel_bookings_copy
UNION ALL
SELECT 'assigned_room_type', COUNT(*) FILTER (WHERE assigned_room_type = '' OR assigned_room_type IS NULL) FROM hotel_bookings_copy
UNION ALL
SELECT 'booking_changes', COUNT(*) FILTER (WHERE booking_changes IS NULL) FROM hotel_bookings_copy
UNION ALL
SELECT 'deposit_type', COUNT(*) FILTER (WHERE deposit_type = '' OR deposit_type IS NULL) FROM hotel_bookings_copy
UNION ALL
SELECT 'agent', COUNT(*) FILTER (WHERE agent IS NULL) FROM hotel_bookings_copy
UNION ALL
SELECT 'company', COUNT(*) FILTER (WHERE company IS NULL) FROM hotel_bookings_copy
UNION ALL
SELECT 'days_in_waiting_list', COUNT(*) FILTER (WHERE days_in_waiting_list IS NULL) FROM hotel_bookings_copy
UNION ALL
SELECT 'customer_type', COUNT(*) FILTER (WHERE customer_type = '' OR customer_type IS NULL) FROM hotel_bookings_copy
UNION ALL
SELECT 'adr', COUNT(*) FILTER (WHERE adr IS NULL) FROM hotel_bookings_copy
UNION ALL
SELECT 'required_car_parking_spaces', COUNT(*) FILTER (WHERE required_car_parking_spaces IS NULL) FROM hotel_bookings_copy
UNION ALL
SELECT 'total_of_special_requests', COUNT(*) FILTER (WHERE total_of_special_requests IS NULL) FROM hotel_bookings_copy
UNION ALL
SELECT 'reservation_status', COUNT(*) FILTER (WHERE reservation_status = '' OR reservation_status IS NULL) FROM hotel_bookings_copy
UNION ALL
SELECT 'reservation_status_date', COUNT(*) FILTER (WHERE reservation_status_date IS NULL) FROM hotel_bookings_copy;

-- NOTE: company, agent, and children have nulls or missing values with more than 10k to 100k and less than 4

-- Are there any duplicate rows in the dataset?
WITH find_duplicate AS (
    SELECT 
        hotel,
        reservation_status_date,
        is_canceled,
        lead_time,
        arrival_date_year,
        adults,
        children,
        babies,
        is_repeated_guest,
        previous_cancellations,
        previous_bookings_not_canceled,
        booking_changes,
        company,
        days_in_waiting_list,
        adr,
        required_car_parking_spaces,
        total_of_special_requests,
        arrival_date_week_number,
        arrival_date_day_of_month,
        stays_in_weekend_nights,
        stays_in_week_nights,
        arrival_date_month,
        agent,
        reservation_status,
        reserved_room_type,
        assigned_room_type,
        customer_type,
        deposit_type,
        meal,
        country,
        market_segment,
        distribution_channel,
        ROW_NUMBER() OVER (
            PARTITION BY 
                hotel,
                reservation_status_date,
                is_canceled,
                lead_time,
                arrival_date_year,
                adults,
                children,
                babies,
                is_repeated_guest,
                previous_cancellations,
                previous_bookings_not_canceled,
                booking_changes,
                company,
                days_in_waiting_list,
                adr,
                required_car_parking_spaces,
                total_of_special_requests,
                arrival_date_week_number,
                arrival_date_day_of_month,
                stays_in_weekend_nights,
                stays_in_week_nights,
                arrival_date_month,
                agent,
                reservation_status,
                reserved_room_type,
                assigned_room_type,
                customer_type,
                deposit_type,
                meal,
                country,
                market_segment,
                distribution_channel
            ORDER BY hotel
        ) AS row_num
    FROM hbc
)
SELECT *
FROM find_duplicate
WHERE row_num > 1;

-- NOTE: There are 31,966 duplicates

-- Checking if true duplicates. Total rows minus unique rows equals the duplicates.
SELECT 
    COUNT(*) AS total_rows,
    COUNT(DISTINCT CONCAT_WS('|', 
        hotel,
        reservation_status_date,
        is_canceled,
        lead_time,
        arrival_date_year,
        adults,
        children,
        babies,
        is_repeated_guest,
        previous_cancellations,
        previous_bookings_not_canceled,
        booking_changes,
        company,
        days_in_waiting_list,
        adr,
        required_car_parking_spaces,
        total_of_special_requests,
        arrival_date_week_number,
        arrival_date_day_of_month,
        stays_in_weekend_nights,
        stays_in_week_nights,
        arrival_date_month,
        agent,
        reservation_status,
        reserved_room_type,
        assigned_room_type,
        customer_type,
        deposit_type,
        meal,
        country,
        market_segment,
        distribution_channel
    )) AS unique_rows
FROM hbc;

-- NOTE: 119,345 (total rows) - 87,379 (unique rows) = 31,966 duplicates.

-- Creating a backup for the original values (row_num = 1)
CREATE TABLE hbc_deduped AS
WITH ranked AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY 
                   hotel,
                   reservation_status_date,
                   is_canceled,
                   lead_time,
                   arrival_date_year,
                   adults,
                   children,
                   babies,
                   is_repeated_guest,
                   previous_cancellations,
                   previous_bookings_not_canceled,
                   booking_changes,
                   company,
                   days_in_waiting_list,
                   adr,
                   required_car_parking_spaces,
                   total_of_special_requests,
                   arrival_date_week_number,
                   arrival_date_day_of_month,
                   stays_in_weekend_nights,
                   stays_in_week_nights,
                   arrival_date_month,
                   agent,
                   reservation_status,
                   reserved_room_type,
                   assigned_room_type,
                   customer_type,
                   deposit_type,
                   meal,
                   country,
                   market_segment,
                   distribution_channel
               ORDER BY hotel
           ) AS row_num
    FROM hbc
)
SELECT *
FROM ranked
WHERE row_num = 1;

-- CREATING ANOTHER TABLE TO DELETE THE DUPLICATES WHERE ROW_NUM COL is added
CREATE TABLE hotel_bookings_copy2 AS
SELECT * FROM hotel_bookings_copy;

-- Adding the row_num col
ALTER TABLE hotel_bookings_copy2
ADD COLUMN row_num INT;

TRUNCATE hotel_bookings_copy2;

INSERT INTO hotel_bookings_copy2 (
    hotel,
    reservation_status_date,
    is_canceled,
    lead_time,
    arrival_date_year,
    adults,
    children,
    babies,
    is_repeated_guest,
    previous_cancellations,
    previous_bookings_not_canceled,
    booking_changes,
    company,
    days_in_waiting_list,
    adr,
    required_car_parking_spaces,
    total_of_special_requests,
    arrival_date_week_number,
    arrival_date_day_of_month,
    stays_in_weekend_nights,
    stays_in_week_nights,
    arrival_date_month,
    agent,
    reservation_status,
    reserved_room_type,
    assigned_room_type,
    customer_type,
    deposit_type,
    meal,
    country,
    market_segment,
    distribution_channel,
    row_num
)
SELECT 
    hotel,
    reservation_status_date,
    is_canceled,
    lead_time,
    arrival_date_year,
    adults,
    children,
    babies,
    is_repeated_guest,
    previous_cancellations,
    previous_bookings_not_canceled,
    booking_changes,
    company,
    days_in_waiting_list,
    adr,
    required_car_parking_spaces,
    total_of_special_requests,
    arrival_date_week_number,
    arrival_date_day_of_month,
    stays_in_weekend_nights,
    stays_in_week_nights,
    arrival_date_month,
    agent,
    reservation_status,
    reserved_room_type,
    assigned_room_type,
    customer_type,
    deposit_type,
    meal,
    country,
    market_segment,
    distribution_channel,
    ROW_NUMBER() OVER (
        PARTITION BY 
            hotel,
            reservation_status_date,
            is_canceled,
            lead_time,
            arrival_date_year,
            adults,
            children,
            babies,
            is_repeated_guest,
            previous_cancellations,
            previous_bookings_not_canceled,
            booking_changes,
            company,
            days_in_waiting_list,
            adr,
            required_car_parking_spaces,
            total_of_special_requests,
            arrival_date_week_number,
            arrival_date_day_of_month,
            stays_in_weekend_nights,
            stays_in_week_nights,
            arrival_date_month,
            agent,
            reservation_status,
            reserved_room_type,
            assigned_room_type,
            customer_type,
            deposit_type,
            meal,
            country,
            market_segment,
            distribution_channel
        ORDER BY hotel
    ) AS row_num
FROM hbc;

-- checking for the duplicates
SELECT *
FROM hotel_bookings_copy2
WHERE row_num > 1;

-- deleting them
DELETE FROM hotel_bookings_copy2
WHERE row_num > 1;

-- Confirming the deletion of duplicates.
SELECT *
FROM hotel_bookings_copy2;

-- All duplicates have been deleted, so the 'row_num' column is no longer needed to identify duplicates.
ALTER TABLE hotel_bookings_copy2
DROP COLUMN row_num;

-- CREATING A NEW VIEW WITH THE DEDUPLICATED TABLE.
CREATE VIEW hbc2 AS
SELECT * FROM hotel_bookings_copy2;

-- Confirming the creation of the new view.
SELECT *
FROM hbc2;
 
-- What are the unique values in categorical columns like hotel, meal, market_segment, customer_type, etc.?
SELECT DISTINCT 'hotel' AS column_name, hotel AS unique_value
FROM hbc2
UNION ALL
SELECT DISTINCT 'reserved_room_type', reserved_room_type AS unique_value
FROM hbc2
UNION ALL
SELECT DISTINCT 'assigned_room_type', assigned_room_type AS unique_value
FROM hbc2
UNION ALL
SELECT DISTINCT 'customer_type', customer_type AS unique_value
FROM hbc2
UNION ALL
SELECT DISTINCT 'deposit_type', deposit_type AS unique_value
FROM hbc2
UNION ALL
SELECT DISTINCT 'meal', meal AS unique_value
FROM hbc2
UNION ALL
SELECT DISTINCT 'country', country AS unique_value
FROM hbc2
UNION ALL
SELECT DISTINCT 'market_segment', market_segment AS unique_value
FROM hbc2
UNION ALL
SELECT DISTINCT 'distribution_channel', distribution_channel AS unique_value
FROM hbc2
;
-- NOTE: There are two hotels: Resort and City Hotel. 
-- Three different deposit types: non-refundable, no deposit, and refundable.
-- Four customer types: group, transient, contract, and transient-party.
-- Five distribution channel types: undefined, corporate, direct, GDS, and TA/TO.
-- Various assigned room types: A-I, K, L, P.
-- Eight market segment types: corporate, online TA, direct, complementary, undefined, offline TA/TO, and aviation.
-- Various countries.
-- Various reserved room types: A-H, L, P.
-- Lastly, meal types: Undefined, FB, BB, SC, and HB.

-- 2. BOOKING TRENDS
-- What are the most and least common hotels booked?
SELECT DISTINCT hotel, COUNT(*) AS hotel_count
FROM hbc2
GROUP BY hotel
ORDER BY hotel_count DESC;

-- NOTE: The City Hotel is more frequently booked than the Resort Hotel.
-- This may suggest that more guests are coming from the city, or it could simply be more popular.

-- How does the number of bookings change over the years?
SELECT arrival_date_year, hotel, COUNT(hotel) AS bookings
FROM hbc2
GROUP BY arrival_date_year, hotel
ORDER BY arrival_date_year, hotel;

-- NOTE: The number of bookings for both Resort Hotel and City Hotel peaked in 2016, followed by a steady decline in 2017. 
-- However, the decline was more pronounced for the City Hotel compared to the Resort Hotel.

-- What are the most and least common arrival months?
SELECT arrival_date_month, COUNT(arrival_date_month) as total_month
FROM hbc2
GROUP BY arrival_date_month
ORDER BY total_month DESC;

-- INSIGHT: August has the most arrivals, while January has the least.

-- What is the distribution of lead times?
-- Calculating the min, max, avg, and standard deviation of lead time
SELECT 
    MIN(lead_time) AS min_lead_time,
    MAX(lead_time) AS max_lead_time,
    ROUND(AVG(lead_time), 0) AS avg_lead_time,
    ROUND(STDDEV(lead_time), 0) AS stddev_lead_time
FROM hbc2;

-- Grouping by lead time ranges to see the distribution
SELECT 
    CASE
        WHEN lead_time BETWEEN 0 AND 7 THEN '0-7 days'
        WHEN lead_time BETWEEN 8 AND 14 THEN '8-14 days'
        WHEN lead_time BETWEEN 15 AND 30 THEN '15-30 days'
        WHEN lead_time BETWEEN 31 AND 60 THEN '31-60 days'
        WHEN lead_time > 60 THEN '60+ days'
        ELSE 'Unknown'
    END AS lead_time_range,
    COUNT(*) AS booking_count
FROM hbc2
WHERE reservation_status = 'Check-Out'
GROUP BY lead_time_range
ORDER BY booking_count DESC;

-- NOTE: Most successful bookings had lead times of over 60 days, followed by 0-7 days.
-- Fewer bookings occurred in the 8-14 days range, suggesting that a significant portion of guests either plan far in advance 
-- or make last-minute bookings.
-- Canceled or no-show bookings were not included in this analysis.

-- How do booking trends vary by market segment?
SELECT market_segment, COUNT(*) AS bookings_count
FROM hbc2
WHERE market_segment != 'Undefined'
GROUP BY market_segment
ORDER BY bookings_count DESC;

-- NOTE: Most bookings were made through the Online market segment, followed by Offline TA/TO (Travel Agencies/Tour Operators).
-- It seems that the Aviation segment contributed the least to bookings.
-- This suggests that online booking platforms might be more convenient or have a stronger marketing reach, making them more popular for customers.

-- Which distribution channels contribute the most bookings?
SELECT distribution_channel, COUNT(*) AS bookings
FROM hbc2
WHERE distribution_channel != 'Undefined'
GROUP BY distribution_channel
ORDER BY bookings DESC;

-- NOTE: The most bookings were distributed through TA/TO (Travel Agencies/Tour Operators) and Direct channels, 
-- which contributed the most bookings to the hotel.

-- 3. CANCELLATIONS
-- What percentage of bookings were canceled?
SELECT 
  is_canceled, 
  COUNT(*) AS bookings,
  CONCAT(ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM hbc2), 2), '%') AS percentage
FROM hbc2
WHERE is_canceled = 1
GROUP BY is_canceled
ORDER BY percentage DESC;

-- NOTE: 27.49% of the bookings were canceled

-- Is there a relationship between lead time and cancellations?
SELECT 
  CASE
    WHEN lead_time <= 7 THEN '0-7 days'
    WHEN lead_time <= 30 THEN '8-30 days'
    WHEN lead_time <= 90 THEN '31-90 days'
    ELSE '91+ days'
  END AS lead_time_group,
  COUNT(*) AS total_bookings
FROM hbc2
WHERE is_canceled = 1
GROUP BY lead_time_group
ORDER BY total_bookings DESC;

-- NOTE: Most cancellations occurred more than 91 days before arrival, with cancellations within 0-7 days being the least common.
-- This suggests that the longer the lead time, the more likely people are to cancel their bookings, 
-- possibly due to changing circumstances or evolving plans over time.

-- Do repeated guests cancel more or less frequently than first-time guests?
SELECT 
  CASE 
    WHEN is_repeated_guest = 1 THEN 'Repeated Guest' 
    ELSE 'First Time Guest' 
  END AS guest_type,
  COUNT(*) AS total_cancellations
FROM hbc2
WHERE is_canceled = 1
GROUP BY guest_type
ORDER BY total_cancellations DESC;

-- NOTE: First-time guests are more likely to cancel their bookings compared to repeated guests, with over 23,000 cancellations 
-- from first-time guests, while repeated guests accounted for only 261 cancellations.
-- This may suggest that first-time guests are less confident or less committed, possibly due to unfamiliarity with the hotel.

-- Are guests with prior cancellations more likely to cancel again?
SELECT 
  CASE 
    WHEN previous_cancellations > 0 THEN 'With Prior Cancellations'
    ELSE 'No Prior Cancellations' 
  END AS cancellation_group,
  COUNT(*) AS total_guests,
  SUM(previous_cancellations) AS total_prev_cancellations,
  CONCAT(ROUND(100 * SUM(previous_cancellations) / COUNT(*), 2), '%') AS cancellation_percentage
FROM hbc2
GROUP BY cancellation_group
ORDER BY cancellation_percentage DESC;

-- NOTE: Guests with prior cancellations are more likely to cancel again, likely because they have already canceled before.
-- This suggests that some guests may be less committed, possibly due to busy schedules or other circumstances.

-- How do cancellation rates vary by deposit type?
SELECT 
  deposit_type,   
  COUNT(*) AS total_guests,
  SUM(previous_cancellations) AS total_prev_cancellations,
  CONCAT(ROUND(100 * SUM(previous_cancellations) / COUNT(*), 2), '%') AS cancellation_percentage
FROM hbc2
GROUP BY deposit_type;
-- NOTE: Guests with non-refundable deposit type are more likely to cancel, 
-- but due to the much larger number of guests in the 'No Deposit' category, this group accounts for a higher total number of cancellations.

-- 4. GUEST DEMOGRAPHICS
-- What are the top 10 countries guests come from?
SELECT country, COUNT(*) AS guests_count, 
		CONCAT(ROUND(100*COUNT(*) / (SELECT COUNT(*) FROM hbc2),2), '%') AS percentage
FROM hbc2
GROUP BY country 
ORDER BY guests_count DESC
LIMIT 10;

-- NOTE: The majority of guests came from Portugal (PRT), making up 31% of the total, followed by the United Kingdom (GBR) at 11%.
-- This suggests that most guests likely came from nearby regions, 
-- possibly due to geographical proximity or a higher number of travelers from those countries.

-- What is the average number of adults, children, and babies per booking?
SELECT 
    ROUND(AVG(adults), 2) AS avg_adult, 
    ROUND(AVG(children), 2) AS avg_children, 
    ROUND(AVG(babies), 2) AS avg_babies
FROM hbc2
WHERE reservation_status = 'Check-Out';

-- NOTE: The average number of adults per booking is 1.84, suggesting that most bookings are made by solo travelers or couples. 
-- The low averages for children (0.12) and babies (0.01) further indicate that City and Resort hotels may cater more to adult travelers, 
-- with families or bookings involving children and babies being much less frequent.

-- Are there more repeated guests or first-time guests?
SELECT 
    CASE 
        WHEN is_repeated_guest = 1 THEN 'Repeated Guest'
        ELSE 'First-time Guest'
    END AS guest_type,
    COUNT(*) AS guest_count,
    CONCAT(ROUND(100 * COUNT(*) / (SELECT COUNT(*) FROM hbc2), 2), '%') AS percentage
FROM hbc2
GROUP BY guest_type;

-- NOTE: There are significantly more first-time guests (96%) compared to repeated guests (3%). 
-- This suggests that the hotel may cater primarily to short-term visitors or travelers, rather than long-term residents.

-- What is the distribution of customer types?
SELECT customer_type, COUNT(*) AS guests,
	   CONCAT(ROUND(100*COUNT(*)/ (SELECT COUNT(*) FROM hbc2),2), '%') AS percentage
FROM hbc2
GROUP BY customer_type
ORDER BY guests DESC;

-- NOTE: The majority of guests are Transient customers (82%), indicating that the hotel primarily attracts short-term or individual travelers.
-- Transient-party guests make up 13%, suggesting that some guests travel in small groups.
-- The low percentage of Contract (3%) and Group (0%) guests suggests that the hotel is not heavily focused on long-term stays or large group bookings.
-- This distribution implies that the hotel is more likely designed for tourists, business travelers, or those looking for short-term accommodations rather than long-term residents or event-based group bookings.

-- 5. ROOM ANALYSIS
-- What are the most and least commonly reserved room types?
SELECT reserved_room_type, 
       COUNT(*) AS reserved_count,
       CONCAT(ROUND(100 * COUNT(*) / (SELECT COUNT(*) FROM hbc2), 2), '%') AS percentage
FROM hbc2
GROUP BY reserved_room_type
ORDER BY reserved_count DESC;

-- NOTE: Room type A is the most reserved, making up 64% of the bookings, while room type L is the least reserved. 
-- This suggests that guests prefer rooms located near exits or lobbies, which might offer greater convenience and accessibility.

-- How often do guests get assigned a different room type than the one they reserved?
SELECT 
    'Same Room Type' AS room_type,
    COUNT(*) AS room_count,
    CONCAT(ROUND(100 * COUNT(*) / (SELECT COUNT(*) FROM hbc2), 2), '%') AS percentage
FROM hbc2
WHERE reserved_room_type = assigned_room_type
UNION ALL
SELECT 
    'Different Room Type' AS room_type,
    COUNT(*) AS room_count,
    CONCAT(ROUND(100 * COUNT(*) / (SELECT COUNT(*) FROM hbc2), 2), '%') AS percentage
FROM hbc2
WHERE reserved_room_type != assigned_room_type;

-- NOTE: 84% of guests are assigned the room they reserved, while 16% are assigned a different room type.
-- This suggests that the majority of guests receive the room they booked, indicating a generally reliable room assignment process.

-- Do booking changes correlate with room assignment changes?
SELECT 
    booking_changes, 
    COUNT(*) AS bookings_count, 
    CONCAT(ROUND(100 * COUNT(*) / (SELECT COUNT(*) FROM hbc2), 2), '%') AS percentage
FROM hbc2
WHERE reserved_room_type != assigned_room_type
GROUP BY booking_changes
ORDER BY bookings_count DESC;

-- NOTE: The majority of room assignment changes (10%) are linked to bookings with no booking changes. 
-- Only a small percentage (2%) are associated with bookings that had one booking change, 
-- and the percentages decrease as the number of booking changes increases. 
-- This suggests there is little to no correlation between booking changes and room assignment changes, 
-- as most room assignment changes occur with bookings that had no changes.

-- 6. SPECIAL REQUESTS & PARKING
-- What is the distribution of total special requests?
SELECT total_of_special_requests, COUNT(*) AS request_count,
	   CONCAT(ROUND(100 * COUNT(*) / (SELECT COUNT(*) FROM hbc2), 2), '%') AS percentage
FROM hbc2
GROUP BY total_of_special_requests
ORDER BY request_count DESC;

-- NOTE: About half of the guests make no special requests, while roughly 33% make only one. Only 36 guests made five special requests.
-- This suggests that most hotel guests are either satisfied with the default amenities or do not feel the need to make additional requests.

-- How many guests request parking spaces, and how does this vary across customer types?
SELECT customer_type, COUNT(*) AS guests, 
	   CONCAT(ROUND(100 * COUNT(*) / (SELECT COUNT(*) FROM hbc2), 2), '%') AS percentage
FROM hbc2
WHERE required_car_parking_spaces != 0
GROUP BY customer_type
ORDER BY guests DESC;

-- NOTE: About 7% of all guests are Transient customers who requested parking, the highest among all customer types. 
-- This is followed by Transient-Party. Group customers rarely request parking.
-- This may suggest that Transient-type guests are more likely to arrive by car, while Group bookings might involve transport provided by the organizer.

-- 7. REVENUE ANALYSIS
-- What is the average daily rate per hotel type?
SELECT hotel,
	   ROUND(AVG(adr),2) AS avg_daily_rate
FROM hbc2
GROUP BY hotel
ORDER BY avg_daily_rate DESC;

-- NOTE: City hotels have a higher average daily rate at 110.99, compared to resort hotels at 99.05.
-- This suggests that city accommodations tend to be priced higher, possibly due to greater demand or urban convenience.

-- How does adr change over months?
SELECT 
    TO_DATE(CONCAT(arrival_date_year, '-', arrival_date_month, '-01'), 'YYYY-Month-DD') AS month_date,
	arrival_date_month,
    ROUND(AVG(adr), 2) AS avg_adr
FROM hbc2
GROUP BY month_date, arrival_date_month
ORDER BY month_date;

-- NOTE: The ADR consistently spikes during July and August across all three years (2015-2017), 
-- with an additional increase in May and June from 2016 to 2017.
-- This indicates that the hotel experiences higher demand and room rates during the summer months, 
-- likely due to seasonal factors such as holidays or peak tourism periods.

-- Are guests with special requests more likely to pay a higher adr?
SELECT 
    CASE 
        WHEN total_of_special_requests != 0 THEN 'Guests with special requests'
        ELSE 'No special requests'
    END AS with_requests_or_not,
    ROUND(AVG(adr), 2) AS avg_adr
FROM hbc2
GROUP BY with_requests_or_not
ORDER BY avg_adr DESC;

-- NOTE: Guests with special requests tend to have a higher average ADR than those without special requests. 
-- This suggests that additional services or accommodations may have been added to their bookings, potentially increasing the overall cost.

-- How does adr differ across market segments?
SELECT market_segment, ROUND(AVG(adr),2) AS avg_adr
FROM hbc2
GROUP BY market_segment
ORDER BY avg_adr DESC;

-- NOTE: Online Travel Agents (OTAs), Direct bookings, and Aviation all have similar high ADRs, averaging over 100. 
-- Complementary bookings, which may be less popular, have the lowest ADR. This suggests that OTAs, Direct, and Aviation attract higher-paying customers,
-- while Complementary bookings may reflect less demand or lower pricing strategies.

-- CONCLUSION
-- The hotel is a reputable choice for short-term stays, attracting primarily solo travelers and couples. 
-- It shows flexibility in accommodating various customer types. 
-- The Average Daily Rate (ADR) remains relatively consistent throughout the year, 
-- with noticeable fluctuations during the summer months, likely due to seasonal demand. 
-- The hotel also caters to guests from a wide range of countries. 
-- Most customers appear to be satisfied with their assigned rooms.
