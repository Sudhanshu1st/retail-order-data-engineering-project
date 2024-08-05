USE sample_database;

SELECT * FROM df_orders;

DROP Table df_orders;


CREATE TABLE df_orders (
    order_id INT PRIMARY KEY,
    order_date DATE,
    ship_mode VARCHAR(20),
    segment VARCHAR(20),
    country VARCHAR(20),
    city VARCHAR(20),
    state VARCHAR(20),
    postal_code VARCHAR(20),
    region VARCHAR(20),
    category VARCHAR(20),
    sub_category VARCHAR(20),
    product_id VARCHAR(20),
    quantity INT,
    discount DECIMAL(5, 2),
    sale_price DECIMAL(7, 2),
    profit DECIMAL(7, 2)
);


SELECT * FROM DF_ORDERS;




# Find top 10 highest revenue generating products

SELECT product_id, SUM(sale_price) AS sales
FROM df_orders
GROUP BY product_id
ORDER BY sales Desc LIMIT 10;


# Top 5 selling products in each regions
WITH CTE AS (
			SELECT region, product_id, SUM(sale_price) AS sales
			FROM df_orders
			GROUP BY region, product_id) 
SELECT * 
FROM (SELECT *,
	  ROW_NUMBER() OVER(PARTITION BY region ORDER BY sales DESC ) AS rn
	  FROM CTE) AS WNDOW
WHERE rn<=5;


# FIND MONTH OVER MONTH GROWTH COMPARISION FOR 2022 AND 2023 SALES eg: JAN 2022 V/S 2023
SELECT DISTINCT YEAR(ORDER_DATE) FROM DF_ORDERS;   #CHECKED THAT WE HAVE ONLY 2022 AND 2023 YEAR

WITH CTE AS (SELECT YEAR(ORDER_DATE) as order_year, 
				   MONTH(ORDER_DATE) as order_month, 
				   SUM(sale_price) as sales
			FROM DF_ORDERS
			GROUP BY order_year, order_month ) 
            
SELECT order_month,
	SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) as sales_2023,
    SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) as sales_2022       
FROM CTE 
GROUP BY order_month
ORDER BY order_month;

# FOR EACH CATEGORY WHICH MONTH HAD HIGHEST SALES

WITH CTE AS (SELECT category, 
			SUM(sale_price) as sales, 
            DATE_FORMAT(ORDER_DATE,'%Y%m') AS order_year_month
FROM df_orders
GROUP BY category, order_year_month)

SELECT * 
FROM (SELECT *, 
	RANK() OVER(PARTITION BY category ORDER BY sales DESC) AS rnk
	FROM CTE) A
WHERE rnk = 1;


# Which subcategory had highest growth by profit in 2023 compared to 2022

WITH CTE AS (SELECT sub_category, 
			YEAR(ORDER_DATE) as order_year, 
			SUM(sale_price) as sales
		FROM DF_ORDERS
		GROUP BY order_year, sub_category)
, CTE2 AS (
        SELECT sub_category, 
		SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) as sales_2023,
		SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) as sales_2022
	FROM CTE
	GROUP BY sub_category)
    
SELECT * ,
		ROUND((sales_2023 - sales_2022)*100/sales_2023, 2) as growth
FROM CTE2
























