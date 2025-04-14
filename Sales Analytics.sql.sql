
USE new_customer;

-- Which regions have the most active customers?

SELECT R.Region_Name,count(*) AS active_customers
FROM regions  R
JOIN customers1  C  ON R.Region_ID=C.Region_ID
WHERE  C.Status='active'
GROUP BY R.Region_Name
ORDER BY count(*) DESC;

-- How many customers signed up per month?

SELECT DATE_FORMAT(Signup_Date,'%Y-%m')AS MONTH ,count(*)
FROM customers1 
GROUP BY MONTH  ORDER BY MONTH;

-- What percentage of customers are inactive or deleted?

SELECT Status,count(*)AS total,
CONCAT(ROUND(count(*)*100/(SELECT count(*) FROM customers1),0),'%')AS percentage
FROM customers1
WHERE Status IN ('inactive','deleted')
GROUP BY status;

-- What is the distribution of customers by status and region?

SELECT R.Region_Name,c.status,count(*)
FROM customers1  C
JOIN regions  R ON R.Region_ID=C.Region_ID
GROUP BY R.Region_Name,c.status
ORDER BY R.Region_Name;

-- What is the monthly sales trend?

SELECT DATE_FORMAT(o.Order_Date,'%Y-%m')AS MONTH,SUM(od.Quantity*od.Unit_Price)AS Revenue
FROM orders O
JOIN order_details od ON od.Order_ID=o.Order_ID
GROUP BY MONTH ORDER BY MONTH ;


WITH product_sales_cte AS (
SELECT DATE_FORMAT(o.Order_Date,'%Y-%m')AS MONTH,p.Product_Name,
SUM(od.Quantity*od.Unit_Price)AS Revenue
FROM orders O
JOIN order_details od ON od.Order_ID=o.Order_ID
JOIN products p ON p.Product_ID=od.Product_ID
GROUP BY MONTH,p.Product_Name
ORDER BY MONTH),
Ranked_cte AS (
SELECT *,
ROW_NUMBER () OVER (PARTITION BY MONTH  ORDER BY Revenue DESC )AS row_num
FROM product_sales_cte )
SELECT *FROM Ranked_cte
WHERE row_num=1;


-- What is the total revenue by region?

SELECT r.Region_Name,SUM(Total_Amount)AS revenue
FROM orders o
JOIN Customers1 c ON c.Customer_ID=o.Customer_ID
JOIN regions r  ON r.Region_ID=c.Region_ID
GROUP BY r.Region_Name
ORDER BY revenue DESC ;

-- Which months had the highest and lowest sales?

SELECT DATE_FORMAT(Order_Date,'%Y-%m')AS MONTH ,SUM(Total_Amount)AS sales 
FROM orders
GROUP BY MONTH 
ORDER BY  sales DESC  LIMIT 1;

SELECT DATE_FORMAT(Order_Date,'%Y-%m')AS MONTH ,SUM(Total_Amount)AS sales 
FROM orders
GROUP BY MONTH 
ORDER BY  sales ASC LIMIT 1;

-- What are the top 10 best-selling products by quantity?

SELECT p.Product_Name,SUM(od.quantity)AS Quantity 
FROM order_details od
JOIN products p ON p.Product_ID=od.Product_ID
GROUP BY p.Product_Name
ORDER BY Quantity DESC LIMIT 10;

-- What are the top 10 products by revenue?

SELECT p.Product_Name,SUM(od.quantity*od.Unit_Price)AS Revenue
FROM order_details od
JOIN products p ON p.Product_ID=od.Product_ID
GROUP BY p.Product_Name
ORDER BY Quantity DESC LIMIT 10;

-- What is the stock availability by category?

SELECT Category,SUM(Stock_Quantity)AS  stock_availability
FROM products
GROUP BY category
ORDER BY stock_availability DESC ;

-- How many orders were placed each month?

SELECT  DATE_FORMAT(Order_Date,'%Y-%m')AS MONTH,COUNT(*)AS order_count
FROM orders
GROUP BY MONTH 
ORDER BY MONTH ASC ;

-- What percentage of orders are pending, shipped, or cancelled?

SELECT Order_Status,
CONCAT(ROUND(count(*)*100/(SELECT count(*)FROM orders),2),'%')AS percentage_of_orders
FROM orders 
GROUP BY Order_Status;

-- What is the average order value over time?

SELECT DATE_FORMAT(Order_Date, '%Y-%m') AS Month,
 round(AVG(OrderTotal),2) AS Average_Order_Value
FROM (
SELECT o.Order_Date,o.Order_ID,SUM(od.Quantity * od.Unit_Price) AS OrderTotal
FROM order_details od 
JOIN orders o  ON  od.Order_ID=o.Order_ID
GROUP BY o.Order_Date,o.Order_ID)AS OrderSums
GROUP BY Month
ORDER BY Month;

-- Which customers have placed the most orders?

SELECT c.customer_id,CONCAT(c.first_name,'  ', c.last_name)AS FULL_Name, COUNT(*) AS order_count
FROM customers1 c 
JOIN orders o ON c.Customer_ID=o.Customer_ID
GROUP BY c.customer_id,FULL_Name
ORDER BY order_count DESC LIMIT 10;


-- Which regions have customers with high average order value?

SELECT 
  r.Region_Name,
  AVG(OrderTotal) AS Average_Order_Value
FROM Regions AS r
JOIN customers AS c ON r.Region_ID = c.Region_ID
JOIN (
  SELECT 
    o.Order_ID,
    c.Region_ID,
    SUM(od.Quantity * od.Unit_Price) AS OrderTotal
  FROM orders o
  JOIN customers c ON o.Customer_ID = c.Customer_ID
  JOIN order_details od ON od.Order_ID = o.Order_ID
  GROUP BY o.Order_ID, c.Region_ID
) AS OrderSums ON OrderSums.Region_ID = r.Region_ID
GROUP BY r.Region_Name
ORDER BY Average_Order_Value DESC;

-- Identify customers who signed up more than 6 months ago and have no orders.

SELECT DATE_FORMAT(c.Signup_Date,'%Y-%m')AS MONTH,
c.customer_id ,CONCAT(c.first_name,'  ',c.last_name)AS FULL_Name
FROM customers1 c
JOIN orders o ON o.Customer_ID=c.Customer_ID
WHERE o.order_id IS NULL AND Signup_Date< CURDATE() -INTERVAL 6 MONTH
ORDER BY MONTH DESC ;

SELECT DATE_FORMAT(c.Signup_Date,'%Y-%m')AS MONTH,
c.customer_id,CONCAT(c.first_name,'  ',c.last_name)AS FULL_Name
FROM customers1 c
LEFt JOIN orders o ON o.Customer_ID=c.Customer_ID
WHERE o.order_id IS NULL AND Signup_Date< CURDATE() -INTERVAL 6 MONTH
ORDER BY MONTH DESC ;

SELECT customer_id ,first_name ,last_name FROM customers1  
WHERE Last_Name= 'dickerson'