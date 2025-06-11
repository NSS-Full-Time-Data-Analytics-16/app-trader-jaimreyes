--a. Develop some general recommendations about the price range, genre, content rating, or any other app characteristics that the company should target.

SELECT name, category, rating, review_count
FROM play_store_apps
UNION
SELECT name, primary_genre, rating, review_count::numeric
FROM app_store_apps

SELECT ROUND(AVG (price), 2)
FROM app_store_apps;
-- AVG. PRICE = $1.73 for apple

SELECT ROUND (AVG(price::money::numeric), 2)
FROM play_store_apps;
-- AVG. PRICE = $1.03 for google

SELECT ROUND(AVG(rating), 2)
FROM app_store_apps;
-- AVG. RATING = 3.53 for apple

SELECT ROUND(AVG(rating), 2)
FROM play_store_apps; 
-- AVG. RATING ON PLAY STORE APP = 4.19 for google

SELECT ROUND (AVG(price::money::numeric), 2)
FROM play_store_apps;

-- AVG. PRICE = $1.03
SELECT ROUND(AVG(rating), 2)
FROM app_store_apps;

-- AVG. RATING = 3.53
SELECT ROUND(AVG(rating), 2) 
FROM play_store_apps;
-- AVG. RATING ON PLAY STORE APP = 4.19

SELECT ROUND(AVG(review_count), 2)
FROM play_store_apps
-- AVERAGE REVIEW COUNT (PLAY_STORE_APPS) = 444152.90

SELECT ROUND (AVG(review_count::numeric), 2)
FROM app_store_apps;
-- AVERAGE REVIEW COUNT (APP_STORE_APPS) = 12892.91
----------------------------------------------------------------------------------SCRIPT--------------------------------------------------------------------
SELECT name, primary_genre, rating,
	CASE
		WHEN price = 0 THEN 'Free'
		WHEN price > 0 AND price < 5 THEN 'UNDER 5'
		WHEN price >= 5 AND price <=10 THEN '$5-10'
		WHEN price >=11 AND price <=20 THEN '$10-20'
		ELSE 'OVER 20'
	END AS price_category
FROM app_store_apps
WHERE rating > 3.5 AND review_count::numeric >= 12893
INTERSECT
SELECT name, genres AS primary_genre, rating,
	CASE
		WHEN price::money::numeric = 0 THEN 'Free'
		WHEN price::money::numeric > 0 AND price::money::numeric < 5 THEN 'UNDER 5'
		WHEN price::money::numeric >= 5 AND price::money::numeric <=10 THEN '$5-10'
		WHEN price::money::numeric >=11 AND price::money::numeric <=20 THEN '$10-20'
		ELSE 'OVER 20'
	END AS price_category
FROM play_store_apps
WHERE rating > 4.2 AND review_count >= 444153
ORDER BY rating;

-- How many apps are in each genre?
SELECT primary_genre, COUNT(*) AS app_count
FROM app_store_apps
GROUP BY primary_genre
ORDER BY app_count DESC
LIMIT 5;

-- "Games"	3862
-- "Entertainment"	535
-- "Education"	453
-- "Photo & Video"	349
-- "Utilities"	248

SELECT category, COUNT(*) AS app_count
FROM play_store_apps
GROUP BY category
ORDER BY app_count DESC
LIMIT 5;

-- "FAMILY"	1972
-- "GAME"	1144
-- "TOOLS"	843
-- "MEDICAL"	463
-- "BUSINESS"	460

SELECT content_rating, ROUND(AVG(rating), 2) AS avg_rating
FROM app_store_apps
GROUP BY content_rating
ORDER BY avg_rating DESC;
--Avg rating for apple 
-- "9+" 	- 3.77
-- "12+"    - 3.57
-- "4+"     -3.57
-- "17+"    -2.76

SELECT content_rating, ROUND(AVG(rating), 2) AS avg_rating
FROM play_store_apps
GROUP BY content_rating
ORDER BY avg_rating DESC;
-- "Adults only 18+"4.30
-- "Everyone 10+"	4.26
-- "Teen"			4.23
-- "Everyone"		4.19
-- "Mature 17+"		4.12
-- "Unrated"		4.10

--b. Develop a Top 10 List of the apps that App Trader should buy based on profitability/return on investment as the sole priority. COST and PROFIT 
--INVESTMENT (intial cost is $25,000) + recurring investment ($1000)  + profit (10000 month)


WITH top_10_apps AS (SELECT DISTINCT name, apple.rating AS apple_rating, 
                     google.rating AS google_rating, 
                     apple.price AS a_price, 
                     google.price::money::numeric AS g_price
FROM app_store_apps AS apple
INNER JOIN play_store_apps AS google
USING (name)
WHERE apple.rating >= 4.5 
      AND google.rating >= 4.5
      AND apple.review_count::numeric >= 12893
      AND google.review_count >= 444153
      AND apple.price <= 0
      AND google.price::money::numeric <= 0)

SELECT name, 
       LEAST (apple_rating,google_rating) AS rating, 
       ROUND((LEAST(apple_rating, google_rating) * 2 + 1) * 4, 0)/4 as year,
       (ROUND((LEAST(apple_rating, google_rating) * 2 + 1) * 4, 0)/4 ) * 12 as month,
       ((ROUND((LEAST(apple_rating, google_rating) * 2 + 1) * 4, 0)/4 ) * 12 ) * 10000 as revenue,
       ((ROUND((LEAST(apple_rating, google_rating) * 2 + 1) * 4, 0)/4 ) * 12 ) * 10000 - 
       (((ROUND((LEAST(apple_rating, google_rating) * 2 + 1) * 4, 0)/4 ) * 12 )1000) -
       25000 as profit
FROM top_10_apps
ORDER BY profit DESC, rating DESC
LIMIT 10;

---------------------------------------------------------------------script-----------------------------------------------------------------------------------------------

	WITH top_10 AS (SELECT DISTINCT name, apple.rating AS apple_rating, 
                     google.rating AS google_rating, 
                     apple.price AS a_price, 
                     google.price::money::numeric AS g_price
FROM app_store_apps AS apple
INNER JOIN play_store_apps AS google
USING (name)
WHERE apple.price >= 0
      AND google.price::money::numeric >= 0 
	  AND apple.rating >= 4.5 
      AND google.rating >= 4.5
      AND apple.review_count::numeric >= 12893
      AND google.review_count >= 444153),
calculation AS (
	SELECT name, 
       LEAST (apple_rating,google_rating) AS rating, 
       ROUND((LEAST(apple_rating, google_rating) * 2 + 1) * 4, 0)/4::FLOAT as year
	FROM top_10
) 
SELECT *, 
	    year * 12 as month,
	   year * 12 * 10000 as revenue,
	   (year * 12 * 10000) -(year * 12)*1000 - 25000 AS profit  
FROM calculation
ORDER BY profit DESC, rating ASC
LIMIT 10;  

------------------------------------------------------------------------------------------------------------------------------------------------------------------------c. Develop a Top 4 list of the apps that App Trader should buy that are profitable but that also are thematically appropriate for the upcoming Fourth of July themed campaign.

WITH top_10 AS (SELECT DISTINCT name , apple.rating AS apple_rating, google.category AS google_genre ,apple.primary_genre AS apple_genre,
                     google.rating AS google_rating, 
                     apple.price AS a_price, 
                     google.price::money::numeric AS g_price
FROM app_store_apps AS apple
INNER JOIN play_store_apps AS google
USING (name)
WHERE apple.price >= 0
      AND google.price::money::numeric >= 0 
	  AND apple.rating >= 4.0 
      AND google.rating >= 4.0
      AND apple.review_count::numeric >= 12893
      AND google.review_count >= 444153
	  AND apple.primary_genre ILIKE 'Food & Drink' OR apple.primary_genre ILIKE 'Social Networking' OR apple.primary_genre ILIKE 'Weather' OR apple.primary_genre ILIKE 'Music'
	  AND google.category ILIKE 'Food and drink' OR google.category ILIKE '%Social%' OR google.category ILIKE 'video players'),
calculation AS (
	SELECT name, 
       LEAST (apple_rating,google_rating) AS rating, 
       ROUND((LEAST(apple_rating, google_rating) * 2 + 1) * 4, 0)/4::FLOAT as year
	FROM top_10
) 
SELECT *, 
	    year * 12 as month,
	   year * 12 * 10000 as revenue,
	   (year * 12 * 10000) -(year * 12)*1000 - 25000 AS profit  
FROM calculation
WHERE name ILIKE '%Yahoo%' OR name ILIKE 'groupme' OR name ILIKE 'Instagram' OR name ILIKE '%Dom%'
ORDER BY profit DESC, rating ASC
