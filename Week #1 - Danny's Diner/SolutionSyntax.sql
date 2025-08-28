        				/* ------------------------------
        				   Case Study #1 - Danny's Diner
        				   ------------------------------*/


-- Creator: Sagar Mallikarjun Savalgi
-- Tool used: MS SQL Server


-- 1. What is the total amount each customer spent at the restaurant?

	SELECT
		customer_id,
		SUM(price) AS TotalSales
	FROM	
		dannys_diner.sales s INNER JOIN  dannys_diner.menu m ON s.product_id=m.product_id
	GROUP BY
		customer_id;


-- 2. How many days has each customer visited the restaurant?

	SELECT 
		customer_id,
		COUNT(DISTINCT order_date) AS vist_days
	FROM
		dannys_diner.sales
	GROUP BY
		customer_id;


-- 3. What was the first item from the menu purchased by each customer?

	WITH orders_cte AS (
		SELECT 
			customer_id,
			order_date,
			product_name,
			ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY order_date asc) AS rnk
		FROM 
			dannys_diner.sales s INNER JOIN dannys_diner.menu m ON s.product_id=m.product_id 
			)
		SELECT 
			customer_id,
			product_name
		FROM 
			orders_cte
		WHERE rnk = 1;			


-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
	
	SELECT TOP 1
		product_name,
		COUNT(1) AS popular_product
	FROM
		dannys_diner.sales s INNER JOIN dannys_diner.menu m ON s.product_id=m.product_id 
	GROUP BY 
		product_name 
	ORDER BY 
		popular_product desc;


-- 5. Which item was the most popular for each customer?

	SELECT
		customer_id,
		product_name,
		purchase
	FROM
		(
		SELECT
		 	customer_id,
		  	COUNT(product_name) AS purchase,
		 	product_name,
		   	RANK() OVER(PARTITION BY customer_id ORDER BY COUNT(product_name) desc) AS rnk
		FROM
			dannys_diner.sales s INNER JOIN dannys_diner.menu m ON s.product_id=m.product_id 
		GROUP BY
			customer_id,
			product_name
		) dt
	WHERE 
		rnk = 1;


-- 6. Which item was purchased first by the customer after they became a member?
	
	SELECT
		*
		FROM
		(
		SELECT 
			customer_id,
			order_date,
			product_id,
			product_name,
			join_date,
			mem_status,
			RANK() OVER(PARTITION BY customer_id ORDER BY order_date asc) AS first_product
		FROM
			(
			SELECT 
				s.customer_id,
				order_date,
				s.product_id,
				product_name,
				join_date,
				CASE
					WHEN order_date<join_date THEN 'null' ELSE 'member' 
					END AS mem_status
		
			FROM 
				dannys_diner.sales s INNER JOIN dannys_diner.members m ON s.customer_id = m.customer_id
				INNER JOIN dannys_diner.menu me ON me.product_id = s.product_id
				) dt
		WHERE
			dt.mem_status = 'member'
			) dt2
		WHERE 
			first_product = 1;

					   			 
-- 7. Which item was purchased just before the customer became a member?

	WITH preMember_cte AS
		(
		SELECT
			s.customer_id,
			product_name,
			join_date,
			order_date,
			RANK() OVER(PARTITION BY s.customer_id ORDER BY order_date desc) AS rk
		FROM
			dannys_diner.sales s INNER JOIN dannys_diner.members m ON s.customer_id = m.customer_id
			INNER JOIN dannys_diner.menu me ON me.product_id = s.product_id
		WHERE
			join_date>order_date
		)
	SELECT
		customer_id,
		product_name,
		join_date,
		order_date
	FROM
		preMember_cte
	WHERE 
		rk=1;


-- 8. What is the total items and amount spent for each member before they became a member?

	SELECT
		s.customer_id,
		COUNT(product_name) AS item_count,
		SUM(price) AS totalPrice
		
	FROM
		dannys_diner.sales s INNER JOIN dannys_diner.members m ON s.customer_id = m.customer_id
		INNER JOIN dannys_diner.menu me ON me.product_id = s.product_id
	WHERE
		join_date>order_date
	GROUP BY 
		s.customer_id;


-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - 
--	   how many points would each customer have?

	WITH points_cte AS
	(
		SELECT
			customer_id,
			s.product_id,
			price,
			CASE
				WHEN product_name != 'sushi' THEN price*10
				WHEN product_name = 'sushi' THEN price*10*2
				END AS points
		FROM
			dannys_diner.sales s INNER JOIN dannys_diner.menu m ON s.product_id = m.product_id
	)
	SELECT 
		customer_id,
		SUM(points) AS pointsEarned
	FROM
		points_cte
	GROUP BY
		customer_id;
		

-- 10. In the first week after a customer joins the program (including their join date) 
--	   they earn 2x points on all items, not just sushi - 
--	   how many points do customer A and B have at the end of January?

	WITH bufferPeriod_cte AS 
	(
	SELECT
		s.customer_id,
		join_date,
		DATEADD(DD,6,join_date) AS week_from_joind,
		order_date,
		product_name,
		price	
	FROM
		dannys_diner.sales s INNER JOIN dannys_diner.members m ON s.customer_id = m.customer_id
		INNER JOIN dannys_diner.menu me ON me.product_id = s.product_id
	)
	SELECT
		customer_id,
		SUM(
		CASE
			WHEN order_date BETWEEN join_date AND week_from_joind THEN price*10*2 
			WHEN product_name != 'sushi' THEN price*10
			WHEN product_name = 'sushi' THEN price*10*2
		END ) AS totalPoints_Jan
			
	FROM
		bufferPeriod_cte
	WHERE
		MONTH(order_date) = 01
	GROUP BY
		customer_id
	ORDER BY
		customer_id asc








/*	-----------------------------------
			BONUS QUESTIONS
	-----------------------------------
*/

--	JOIN ALL THE THINGS

SELECT
	s.customer_id,
	order_date,
	product_name,
	price,
	CASE
		WHEN join_date>order_date THEN 'N' 
		WHEN join_date IS NULL THEN 'N'
		ELSE 'Y' END AS members
FROM	
	dannys_diner.sales s INNER JOIN dannys_diner.menu m ON s.product_id=m.product_id
	LEFT JOIN dannys_diner.members mem ON s.customer_id=mem.customer_id

--	Rank All The Things

	WITH ranking_cte AS 
	(
	SELECT
		s.customer_id,
		order_date,
		product_name,
		price,
		CASE
			WHEN join_date>order_date THEN 'N' 
			WHEN join_date IS NULL THEN 'N'
			ELSE 'Y' 
		END AS members
		FROM	
		dannys_diner.sales s INNER JOIN dannys_diner.menu m ON s.product_id=m.product_id
		LEFT JOIN dannys_diner.members mem ON s.customer_id=mem.customer_id
	)
	SELECT
		customer_id,
		order_date,
		product_name,
		price,
		members,
		CASE
			WHEN members='Y' 
			THEN RANK() OVER(PARTITION BY customer_id,members ORDER BY order_date) ELSE NULL
		END AS ranking
	FROM 
		ranking_cte
