-- Swiggy Restaurant Data Analysis
-- Database: SQLite
-- Dataset: Swiggy Restaurant Dataset

-- =====================================================
-- 1. DATASET OVERVIEW
-- =====================================================

-- Total number of restaurant records
SELECT COUNT(*) AS total_rows
FROM swiggy;

-- View table structure
PRAGMA table_info(swiggy);

-- View sample records
SELECT *
FROM swiggy
LIMIT 10;

-- =====================================================
-- 2. DATA CLEANING
-- =====================================================

-- Create a cleaned copy of the raw table
CREATE TABLE swiggy_cleaned AS
SELECT *
FROM swiggy;

-- Convert unavailable ratings to NULL
UPDATE swiggy_cleaned
SET rating = NULL
WHERE rating = 'NA';

-- Convert unavailable rating counts to NULL
UPDATE swiggy_cleaned
SET rating_count = NULL
WHERE rating_count = 'NA';

-- Create numeric rating column
ALTER TABLE swiggy_cleaned
ADD COLUMN rating_numeric REAL;

UPDATE swiggy_cleaned
SET rating_numeric = CAST(rating AS REAL)
WHERE rating IS NOT NULL;

-- Create numeric rating-count column
ALTER TABLE swiggy_cleaned
ADD COLUMN rating_count_numeric INTEGER;

UPDATE swiggy_cleaned
SET rating_count_numeric =
    CASE
        WHEN rating_count = '20+ ratings' THEN 20
        WHEN rating_count = '50+ ratings' THEN 50
        WHEN rating_count = '100+ ratings' THEN 100
        WHEN rating_count = '500+ ratings' THEN 500
        WHEN rating_count = '1K+ ratings' THEN 1000
        WHEN rating_count = '5K+ ratings' THEN 5000
        WHEN rating_count = '10K+ ratings' THEN 10000
        ELSE NULL
    END;

-- Create numeric cost column
ALTER TABLE swiggy_cleaned
ADD COLUMN cost_numeric REAL;

UPDATE swiggy_cleaned
SET cost_numeric = CAST(REPLACE(cost, '₹ ', '') AS REAL);

-- Convert unavailable costs to NULL
UPDATE swiggy_cleaned
SET cost_numeric = NULL
WHERE cost = 'NA';

-- Remove extreme cost outlier from analysis
UPDATE swiggy_cleaned
SET cost_numeric = NULL
WHERE cost_numeric > 10000;








-- =====================================================
-- Q1. TOP LOCATIONS BY RESTAURANT COUNT
-- =====================================================

SELECT
    city,
    COUNT(*) AS total_restaurants
FROM swiggy_cleaned
GROUP BY city
ORDER BY total_restaurants DESC
LIMIT 10;






-- =====================================================
-- Q2. MOST POPULAR CUISINE ENTRIES
-- =====================================================

SELECT
    cuisine,
    COUNT(*) AS total_restaurants
FROM swiggy_cleaned
GROUP BY cuisine
ORDER BY total_restaurants DESC
LIMIT 10;





-- =====================================================
-- Q3. RESTAURANT CHAINS WITH MOST BRANCHES
-- =====================================================

SELECT
    name,
    COUNT(*) AS branches
FROM swiggy_cleaned
GROUP BY name
ORDER BY branches DESC
LIMIT 10;





Which locations have the highest average restaurant rating?
-- =====================================================
-- Q4. HIGHEST-RATED LOCATIONS
-- =====================================================

SELECT
    city,
    ROUND(AVG(rating_numeric), 2) AS avg_rating,
    COUNT(rating_numeric) AS rated_restaurants
FROM swiggy_cleaned
WHERE rating_numeric IS NOT NULL
GROUP BY city
HAVING COUNT(rating_numeric) > 50
ORDER BY avg_rating DESC
LIMIT 5;



Which locations have the highest average cost for two?

-- =====================================================
-- Q5. AVERAGE COST FOR TWO BY LOCATION
-- =====================================================

SELECT
    city,
    ROUND(AVG(cost_numeric), 0) AS avg_cost
FROM swiggy_cleaned
WHERE cost_numeric IS NOT NULL
GROUP BY city
ORDER BY avg_cost DESC
LIMIT 10;


Which cuisine entries have the highest average ratings?
-- =====================================================
-- Q6. HIGHEST-RATED CUISINE ENTRIES
-- =====================================================

SELECT
    cuisine,
    ROUND(AVG(rating_numeric), 2) AS avg_rating,
    COUNT(*) AS restaurant_count
FROM swiggy_cleaned
WHERE rating_numeric IS NOT NULL
GROUP BY cuisine
HAVING COUNT(*) > 100
ORDER BY avg_rating DESC
LIMIT 10;




Which restaurants have both a rating of 4.5+ and at least 1,000 ratings?
-- =====================================================
-- Q7. HIGHLY RATED AND HIGHLY REVIEWED RESTAURANTS
-- =====================================================

SELECT
    name,
    city,
    rating_numeric,
    rating_count_numeric,
    cost_numeric
FROM swiggy_cleaned
WHERE rating_numeric >= 4.5
  AND rating_count_numeric >= 1000
ORDER BY rating_numeric DESC,
         rating_count_numeric DESC
LIMIT 20;



Which locations combine high restaurant ratings with their average cost for two?
-- =====================================================
-- Q8. RATING AND COST BUSINESS INSIGHT
-- =====================================================

SELECT
    city,
    ROUND(AVG(rating_numeric), 2) AS avg_rating,
    ROUND(AVG(cost_numeric), 0) AS avg_cost,
    COUNT(rating_numeric) AS rated_restaurants
FROM swiggy_cleaned
WHERE rating_numeric IS NOT NULL
  AND cost_numeric IS NOT NULL
GROUP BY city
HAVING COUNT(rating_numeric) > 30
ORDER BY avg_rating DESC,
         avg_cost ASC
LIMIT 10;


