/* Quizz Funnel */
/* Task 1 - Inspect file */
SELECT * FROM survey LIMIT 10;
/* Survey table has 3 columns:
-question (TEXT)
-user_id (TEXT)
-response (TEXT) */

/* Task 2 - What is the number of responses for each question? */
SELECT question,
COUNT(DISTINCT user_id)
FROM survey
GROUP BY question
ORDER BY question;

/* Task 3 - Which question(s) of the quiz have a lower completion rates?
Question 5 (When was your last eye exam?) has the lowest completion rate (75%)
What do you think is the reason?
Potential customers might feel this is too private and don't want this to affect the outcome of the survey. */

/* Home Try-On funnel */
/* Task 4 - Inspect tables */
SELECT * FROM quiz LIMIT 5;
SELECT * FROM home_try_on LIMIT 5;
SELECT * FROM purchase LIMIT 5;
/* Quizz table has 5 columns:
-user_id (TEXT)
-style (TEXT)
-fit (TEXT)
-shape (TEXT)
-color (TEXT)
Home_try_on table has 3 columns:
-user_id (TEXT)
-number_of_pairs (TEXT)
-address (TEXT)
Purchase table has 6 columns:
-user_id (TEXT)
-product_id (INTEGER)
-style (TEXT)
-model_name (TEXT)
-color (TEXT)
-price (INTEGER) */

/* Task 5 - Join tables */
SELECT DISTINCT q.user_id,
   h.user_id IS NOT NULL AS 'is_home_try_on',
   h.number_of_pairs,
   p.user_id IS NOT NULL AS 'is_purchase'
FROM quiz q
LEFT JOIN home_try_on h
   ON q.user_id = h.user_id
LEFT JOIN purchase p
   ON p.user_id = q.user_id
LIMIT 10;

/* Task 6 - Data analysis */

/*  calculate overall conversion rates by aggregating across all rows */
WITH funnels AS (
  SELECT DISTINCT q.user_id,
    h.user_id IS NOT NULL AS is_home_try_on,
    h.number_of_pairs,
    p.user_id IS NOT NULL AS is_purchase
  FROM quiz q
  LEFT JOIN home_try_on h ON q.user_id = h.user_id
  LEFT JOIN purchase p ON q.user_id = p.user_id
)
SELECT COUNT(*) AS num_user,
  SUM(is_home_try_on) AS num_home_try_on,
  SUM(is_purchase) AS num_purchase,
  1.0 * SUM(is_home_try_on) / COUNT(*) AS quizz_to_home_try_on_rate,
  1.0 * SUM(is_purchase) / SUM(is_home_try_on) AS home_try_on_to_purchase_rate
FROM funnels;

/*  difference in purchase rates between customers who had 3 number_of_pairs with ones who had 5 */
SELECT DISTINCT q.user_id IS NOT NULL AS 'user_id',
  h.user_id IS NOT NULL AS 'is_home_try_on',
  h.number_of_pairs,
  p.user_id IS NOT NULL AS 'is_purchase',
  p.style AS 'purchase_style',
  p.model_name,
  p.price,
  COUNT(p.price) AS 'quantity_sold',
  SUM(p.price) AS '$_total_sold'
FROM quiz AS 'q'
LEFT JOIN home_try_on AS 'h'
  ON q.user_id = h.user_id
LEFT JOIN purchase AS 'p'
  ON q.user_id = p.user_id
GROUP BY 3, 5, 6, 7
HAVING h.number_of_pairs IS NOT NULL AND p.style NOT NULL;

/* most popular style in quizz */
SELECT style, COUNT(*) AS style_count
FROM quiz
GROUP BY style
ORDER BY style_count DESC;

/* most popular item in purchase */
SELECT product_id, style, model_name, price, COUNT(*) AS product_id_count
FROM purchase
GROUP BY product_id
ORDER BY product_id_count DESC
LIMIT 5;



