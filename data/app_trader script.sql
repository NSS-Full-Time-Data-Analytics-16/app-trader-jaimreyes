
--a. Develop some general recommendations about the price range, genre, content rating, or any other app characteristics that the company should target.

SELECT ROUND (AVG(price),2)::money AS avg_price, ROUND (AVG(rating),2) AS avg_rating, content_rating, primary_genre, p.category
FROM app_store_apps AS a
JOIN play_store_apps USING (name)
GROUP BY primary_genre, content_rating;

SELECT ROUND (AVG(price),2)::money,ROUND (AVG(rating),2) AS avg_rating
FROM app_store_apps

SELECT ROUND (AVG(price::money::numeric),2),ROUND (AVG(rating),2) AS avg_rating
FROM play_store_apps

SELECT *
FROM play_store_apps

SELECT *
FROM app_store_apps
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
ORDER BY primary_genre;


--b. Develop a Top 10 List of the apps that App Trader should buy based on profitability/return on investment as the sole priority. COST and PROFIT 
--INVESTMENT (intial cost is $25,000) + recurring investment ($1000)  + profit (10000 month)

WITH top_10_apps AS (SELECT DISTINCT name, apple.rating AS apple_rating, google.rating AS google_rating, apple.price AS a_price, google.price::money::numeric AS g_price
FROM app_store_apps AS apple
INNER JOIN play_store_apps AS google
USING (name)
WHERE apple.rating >= 4.5 
	  AND google.rating >= 4.5
	  AND apple.review_count::numeric >= 12893
	  AND google.review_count >= 444153
	  AND apple.price <= 0
	  AND google.price::money::numeric <= 0)

SELECT LEAST (apple_rating,google_rating) AS rating , name, LEAST (a_price,g_price) AS price, LEAST(apple_rating,google_rating)*2 + 1  AS longevity
FROM top_10_apps
ORDER BY rating DESC
LIMIT 10;




--c. Develop a Top 4 list of the apps that App Trader should buy that are profitable but that also are thematically appropriate for the upcoming Fourth of July themed campaign.

	