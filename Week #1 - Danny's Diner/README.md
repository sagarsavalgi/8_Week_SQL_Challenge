# 🍜 Case Study #1 - Danny's Diner
<p align="center">
<img src="https://github.com/sagarsavalgi/8_Week_SQL_Challenge/blob/main/IMG/%231-thumbnail.png" align="center" width="400" height="400" >
  
## 📕 Table of Contents
* [Business Task](https://github.com/sagarsavalgi/8_Week_SQL_Challenge/tree/main/Week%20%231%20-%20Danny's%20Diner#%EF%B8%8F-business-task)
* [Entity Relationship Diagram](https://github.com/sagarsavalgi/8_Week_SQL_Challenge/tree/main/Week%20%231%20-%20Danny's%20Diner#-entity-relationship-diagram
)
* [Case Study Questions](https://github.com/sagarsavalgi/8_Week_SQL_Challenge/tree/main/Week%20%231%20-%20Danny's%20Diner#-case-study-questions)
* [Bonus Questions](https://github.com/sagarsavalgi/8_Week_SQL_Challenge/tree/main/Week%20%231%20-%20Danny's%20Diner#%EF%B8%8F-bonus-questions)
* [My Solution](https://github.com/sagarsavalgi/8_Week_SQL_Challenge/tree/main/Week%20%231%20-%20Danny's%20Diner#-my-solution)

---
## 🛠️ Business Task
Danny wants to use the data to answer a few simple questions about his customers, especially about their visiting patterns, how much money they’ve spent and also which menu items are their favourite. Having this deeper connection with his customers will help him deliver a better and more personalised experience for his loyal customers.

---
## 🔐 Entity Relationship Diagram
<p align="center">
<img src="https://github.com/sagarsavalgi/8_Week_SQL_Challenge/blob/main/IMG/%231%20ERD.png" align="center" width="500" height="250" >

---
## ❓ Case Study Questions
1. What is the total amount each customer spent at the restaurant?
2. How many days has each customer visited the restaurant?
3. What was the first item from the menu purchased by each customer?
4. What is the most purchased item on the menu and how many times was it purchased by all customers?
5. Which item was the most popular for each customer?
6. Which item was purchased first by the customer after they became a member?
7. Which item was purchased just before the customer became a member?
8. What is the total items and amount spent for each member before they became a member?
9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, 
  not just sushi - how many points do customer A and B have at the end of January?

---
## 🗒️ Bonus Questions
* Join All The Things - Create a table that has these columns: customer_id, order_date, product_name, price, member (Y/N).
* Rank All The Things - Based on the table above, add one column: ranking.  

---
## 🚀 My Solution
*View the complete syntax [HERE](https://github.com/sagarsavalgi/8_Week_SQL_Challenge/blob/main/Week%20%231%20-%20Danny's%20Diner/SolutionSyntax.sql)*
  
### Q1. What is the total amount each customer spent at the restaurant?
```TSQL
	SELECT
            customer_id,
            SUM(price) AS TotalSales
	FROM	
            dannys_diner.sales s INNER JOIN  dannys_diner.menu m ON s.product_id=m.product_id
	GROUP BY
            customer_id;
```
|customer_id|	TotalSales|
|---|---|
|A|	76|
|B| 74|
|C|	36|

  
---
### Q2. How many days has each customer visited the restaurant?
```TSQL
	SELECT 
            customer_id,
            COUNT(DISTINCT order_date) AS vist_days
	FROM
            dannys_diner.sales
	GROUP BY
            customer_id;
```
|customer_id	|vist_days|
|---|---|
|A|	4|
|B	|6|
|C| 2|

  
---
### Q3. What was the first item from the menu purchased by each customer?
```TSQL
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
            WHERE
                rnk = 1;

```
|customer_id|	product_name|
|---|---|
|A|	sushi|
|B|	curry|
|C|	ramen|
  
  
---
### Q4. What is the most purchased item on the menu and how many times was it purchased by all customers?
```TSQL
            SELECT TOP 1
                product_name,
                COUNT(1) AS popular_product
            FROM
                dannys_diner.sales s INNER JOIN dannys_diner.menu m ON s.product_id=m.product_id 
            GROUP BY 
                product_name 
            ORDER BY 
                popular_product desc;

```
|product_name|	popular_product|
|---|---|
|ramen|	8|
  
  
---
### Q5. Which item was the most popular for each customer?
```TSQL

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
```
|customer_id|	product_name|	purchase|
|--------|--------|-------|
|A	|ramen	|3|
|B	|sushi	|2|
|B	|curry	|2|
|B	|ramen	|2|
|C	|ramen	|3|
  
  
---
### Q6. Which item was purchased first by the customer after they became a member?
```TSQL
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

```
|customer_id|	order_date|	product_id|	product_name|	join_date|	mem_status|	first_product|
|---|---|---|---|---|---|---|
|A|	2021-01-07|	2|	curry|	2021-01-07|	member	|1|
|B	|2021-01-11	|1	|sushi	|2021-01-09	|member	|1|


---
### Q7. Which item was purchased just before the customer became a member?
```TSQL
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

```  
|customer_id|	product_name|	join_date|	order_date|
|---|---|---|---|
|A|	sushi|	2021-01-07|	2021-01-01|
|A	|curry	|2021-01-07	|2021-01-01|
|B|	sushi|	2021-01-09	|2021-01-04|
                                  
---
### Q8. What is the total items and amount spent for each member before they became a member?
```TSQL
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
```
|customer_id|	item_count|	totalPrice|
|---|---|---|
|A|	2|	25|
|B	|3	|40|

  
---
### Q9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
Note: Only customers who are members receive points when purchasing items
```TSQL
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
```
|customer_id|	pointsEarned|
|---|---|
|A	|860|
|B	|940|
|C|	360|

--- 
### Q10. In the first week after a customer joins the program (including their join date), they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
```TSQL
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
            customer_id asc;

```
  |customer_id|	totalPoints_Jan|
  |---|---|
|A|	1370|
|B|	820|   
                              
---
## Bonus Questions

### Join All The Things 
```TSQL

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
        LEFT JOIN dannys_diner.members mem ON s.customer_id=mem.customer_id;

```
|Customer_id|	order_date|	product_name|	price|	members|
|---|---|---|---|---|
|A|	2021-01-01|	sushi|	10|	N|
|A|	2021-01-01|	curry	|15|	N|
|A|	2021-01-07|	curry|	15|	Y|
|A|	2021-01-10|	ramen|	12|	Y|
|A|	2021-01-11|	ramen|	12|	Y|
|A|	2021-01-11|	ramen|	12|	Y|
|B| 2021-01-01|	curry|	15|	N|
|B|	2021-01-02|	curry|	15|	N|
|B|	2021-01-04|	sushi|	10|	N|
|B|	2021-01-11|	sushi|	10|	Y|
|B|	2021-01-16|	ramen|	12|	Y|
|B|	2021-02-01|	ramen|	12|	Y|
|C|	2021-01-01|	ramen|	12|	N|
|C|	2021-01-01|	ramen|	12|	N|
|C|	2021-01-07|	ramen|	12|	N|
---
### Rank All The Things

```TSQL
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
                    WHEN members='Y' THEN RANK() OVER(PARTITION BY customer_id,members ORDER BY order_date) ELSE NULL
                END AS ranking
            FROM 
                ranking_cte

```
| customer_id | order_date | product_name | price | members | ranking |
|-------------|------------|--------------|-------|---------|---------|
| A           | 2021-01-01 | sushi        | 10    | N       | NULL    |
| A           | 2021-01-01 | curry        | 15    | N       | NULL    |
| A           | 2021-01-07 | curry        | 15    | Y       | 1       |
| A           | 2021-01-10 | ramen        | 12    | Y       | 2       |
| A           | 2021-01-11 | ramen        | 12    | Y       | 3       |
| A           | 2021-01-11 | ramen        | 12    | Y       | 3       |
| B           | 2021-01-01 | curry        | 15    | N       | NULL    |
| B           | 2021-01-02 | curry        | 15    | N       | NULL    |
| B           | 2021-01-04 | sushi        | 10    | N       | NULL    |
| B           | 2021-01-11 | sushi        | 10    | Y       | 1       |
| B           | 2021-01-16 | ramen        | 12    | Y       | 2       |
| B           | 2021-02-01 | ramen        | 12    | Y       | 3       |
| C           | 2021-01-01 | ramen        | 12    | N       | NULL    |
| C           | 2021-01-01 | ramen        | 12    | N       | NULL    |
| C           | 2021-01-07 | ramen        | 12    | N       | NULL    |

