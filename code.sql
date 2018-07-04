-- Style survey Funnel 
 
 SELECT *
 FROM survey
 LIMIT 10;
 
 -- Survey table has question, user_id, and response columns 
 
 SELECT question, 
 		COUNT(DISTINCT user_id) AS num_responses
 FROM survey
 GROUP BY 1;
 
 SELECT question, 
 	response, 
  	COUNT(*) AS num_responses 
 FROM survey
 GROUP BY 1,2
 ORDER BY 1, 3 DESC;
 
 -- Number of responses per question - Q1:500, Q2:475, Q3:380, Q4:361, Q5:270
 
WITH question_responses AS(
 SELECT question, 
   COUNT(DISTINCT user_id) AS num_responses
 FROM survey
 GROUP BY 1), 
total_responses AS(
 SELECT MAX(num_responses) AS total
 FROM question_responses), 
combined AS(
 SELECT *
 FROM question_responses
 CROSS JOIN total_responses)
SELECT question, 
	(1.0 * num_responses / total) * 100 AS percent_answered
FROM combined;

-- Completion rates per quesiton - Q1:100%, Q2:95%, Q3:76%, Q4:72.2%, Q5:54%

SELECT * FROM quiz LIMIT 5;

-- Quiz table has user_id, style, fit, shape, and color columns 

SELECT * FROM home_try_on LIMIT 5;

-- Home_try_on table has user_id, address, and number_of_pairs columns

SELECT * FROM purchase LIMIT 5;

-- Purchase table has user_id, product_id, style, model_name, color, and price columns 

SELECT DISTINCT q.user_id, 
	h.user_id IS NOT NULL AS is_home_try_on,
  h.number_of_pairs, 
  p.user_id IS NOT NULL AS is_purchased
FROM quiz q
LEFT JOIN home_try_on h
	ON q.user_id = h.user_id
LEFT JOIN purchase p
	ON p.user_id = q.user_id
LIMIT 10;
       
-- Conversion rates, overall 49.5%, quiz to home is 75%, home to purchase is 66%

WITH funnel AS ( 
  SELECT DISTINCT q.user_id, 
	h.user_id IS NOT NULL AS is_home_try_on,
  h.number_of_pairs, 
  p.user_id IS NOT NULL AS is_purchased
FROM quiz q
LEFT JOIN home_try_on h
	ON q.user_id = h.user_id
LEFT JOIN purchase p
	ON p.user_id = q.user_id)
SELECT 1.0 * SUM(is_purchased)/ COUNT(user_id) * 	100 AS total_conversion, 
	1.0 * SUM(is_home_try_on) / COUNT(user_id) * 100 AS quiz_to_home,
	1.0 * SUM(is_purchased) / SUM(is_home_try_on) * 	100 AS home_to_purchase
FROM funnel;

-- Conversion rates w/ number of pairs: 3 pairs 53%, 5 pairs 79%

WITH funnel AS ( 
  SELECT DISTINCT q.user_id, 
		h.user_id IS NOT NULL AS is_home_try_on,
  	h.number_of_pairs, 
  	p.user_id IS NOT NULL AS is_purchased
	FROM quiz q
	LEFT JOIN home_try_on h
		ON q.user_id = h.user_id
	LEFT JOIN purchase p
		ON p.user_id = q.user_id), 
three_pairs AS (
	SELECT *
	FROM funnel
	WHERE number_of_pairs = '3 pairs'), 
five_pairs AS (
	SELECT *
	FROM funnel
	WHERE number_of_pairs = '5 pairs'),
five_conversion AS (
	SELECT number_of_pairs, 
  	1.0 * SUM(is_purchased) /SUM(is_home_try_on) * 100 AS 	home_to_purchase
	FROM five_pairs), 
three_conversion AS (
	SELECT number_of_pairs, 
  	1.0 * SUM(is_purchased) /SUM(is_home_try_on) * 100 AS home_to_purchase
	FROM three_pairs), 
three_five_conversion AS (
	SELECT *
	FROM five_conversion
	UNION
	SELECT *
	FROM three_conversion)
SELECT number_of_pairs,
	ROUND(home_to_purchase,2) AS home_to_purchase
FROM three_five_conversion;

-- Most common results of the style quiz

SELECT style, COUNT(style) AS num_response
FROM quiz
GROUP BY 1
ORDER BY 2 DESC;

SELECT fit, COUNT(fit) AS num_response
FROM quiz
GROUP BY 1
ORDER BY 2 DESC;

SELECT shape, COUNT(shape) AS num_response
FROM quiz
GROUP BY 1
ORDER BY 2 DESC;

SELECT color, COUNT(color) AS num_response
FROM quiz
GROUP BY 1
ORDER BY 2 DESC;

-- Most common types of purchases 

SELECT style, model_name, color, COUNT(*) AS num_purchases, price
FROM purchase
GROUP BY 1,2,3
ORDER BY 4 DESC;

SELECT style, COUNT(*) AS num_purchases
FROM purchase
GROUP BY 1
ORDER BY 2 DESC;

SELECT model_name, COUNT(*) AS num_purchases
FROM purchase
GROUP BY 1
ORDER BY 2 DESC;

SELECT color, COUNT(*) AS num_purchases
FROM purchase
GROUP BY 1
ORDER BY 2 DESC;