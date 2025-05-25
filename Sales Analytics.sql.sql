-- 1.Which regions have the most active customers?

WITH region_customer_counts AS (
SELECT 
R.Region_Name,
count(*) AS active_customers
FROM regions  R
JOIN customers1  C  ON R.Region_ID=C.Region_ID
WHERE  C.Status='active'
GROUP BY R.Region_Name
)
SELECT Region_Name,
active_customers,
DENSE_RANK ()OVER (ORDER  BY active_customers DESC  )AS Region_Rank
FROM region_customer_counts;



-- 2.How many customers signed up per month?

SELECT 
    CONVERT(varchar(7), signupdate, 120) AS Month,  -- Format: YYYY-MM
    COUNT(*) AS Signups
FROM 
    Customers1
GROUP BY 
    CONVERT(varchar(7), signupdate, 120)
ORDER BY 
    Month;

-- 3.What percentage of customers are inactive or deleted?

WITH total_customers AS (
    SELECT Status,
      COUNT(*)  AS status_count,
      CONCAT(ROUND (COUNT(*)*100 /(SELECT COUNT(*) FROM customers1),0),'%') AS percentage
   FROM customers1
   GROUP BY Status
)
SELECT *
FROM total_customers
WHERE Status IN ('Inactive','deleted');

-- 4.What is the distribution of customers by status and region?

WITH region_status_counts AS (
SELECT 
    r.Region_Name,
    c.Status,
    COUNT(c.Customer_ID)AS status_count
FROM 
    customers1 c 
JOIN 
    regions r ON r.Region_ID=c.Region_ID
GROUP BY c.Status,r.Region_Name
),
region_totals AS (
SELECT 
Region_Name,
SUM(status_count) AS total_in_region
FROM  
    region_status_counts
GROUP BY  Region_Name
)        
 SELECT  
    rt.Region_Name,
    rs.Status, 
    rs.status_count,
    rt.total_in_region
FROM  
   region_status_counts rs
JOIN  
   region_totals rt ON rs.Region_Name=rt.Region_Name
ORDER BY rt.Region_Name,rs.Status;

-- 5.What is the monthly sales trend?

SELECT DATE_FORMAT(o.Order_Date,'%Y-%m')AS MONTH,SUM(od.Quantity*od.Unit_Price)AS Revenue
FROM orders O
JOIN order_details od ON od.Order_ID=o.Order_ID
GROUP BY MONTH ORDER BY MONTH ;


WITH product_sales_cte AS  (
   SELECT
      DATE_FORMAT(o.Order_Date,'%Y-%m') AS Month ,
      od.Product_ID,
      SUM(od.Unit_Price*od.quantity)AS Revenue
   FROM order_details od
   JOIN orders o ON o.Order_ID=od.Order_ID
   GROUP BY DATE_FORMAT(o.Order_Date,'%Y-%m'),od.Product_ID
)
   SELECT 
       ps.MONTH,
       p.Product_Name,
       ps.Revenue,
       DENSE_RANK () OVER (ORDER BY ps.Revenue DESC ) AS rank_sales
   FROM product_sales_cte AS  ps
   JOIN products  p ON p.Product_ID=ps.Product_ID;

-- 6.How can we identify and rank the top-performing products by monthly revenue using window functions?

WITH ProductSalesByMonth AS (
    SELECT
        DATE_FORMAT(o.Order_Date, '%Y-%m') AS Sales_Month,
        od.Product_ID,
        SUM(od.Unit_Price * od.Quantity) AS Monthly_Revenue
    FROM order_details od
    JOIN orders o ON o.Order_ID = od.Order_ID
    GROUP BY DATE_FORMAT(o.Order_Date, '%Y-%m'), od.Product_ID
),
RankedProductSales AS (
    SELECT
        ps.Sales_Month,
        ps.Product_ID,
        ps.Monthly_Revenue,
        DENSE_RANK() OVER (PARTITION BY ps.Sales_Month ORDER BY ps.Monthly_Revenue DESC) AS Revenue_Rank
    FROM ProductSalesByMonth ps
)
SELECT
    rps.Sales_Month,
    p.Product_Name,
    rps.Monthly_Revenue,
    rps.Revenue_Rank
FROM RankedProductSales rps
JOIN products p ON p.Product_ID = rps.Product_ID
ORDER BY rps.Sales_Month, rps.Revenue_Rank;


-- 7.What is the total revenue by region?

WITH RegionalRevenue AS (
    SELECT
        r.Region_Name,
        SUM(od.Unit_Price * od.Quantity) AS Total_Revenue
    FROM customers1 c
    JOIN orders o ON o.Customer_ID = c.Customer_ID
    JOIN order_details od ON od.Order_ID = o.Order_ID
    JOIN regions r ON c.Region_ID = r.Region_ID
    GROUP BY r.Region_Name
)
SELECT 
    Region_Name,
    Total_Revenue,
    DENSE_RANK () OVER (ORDER BY Total_Revenue DESC )
FROM RegionalRevenue;

-- 8.Which months had the highest and lowest sales?

WITH monthly_sales AS (
SELECT 
    DATE_FORMAT(o.Order_Date,'%Y-%m')AS  Sales_Month,
    SUM(od.Unit_Price * od.Quantity) AS Total_Sales
  FROM order_details  od
  JOIN  orders o ON o.Order_ID=od.Order_ID
  GROUP BY Sales_Month 
  ),
RankedSales AS (
   SELECT 
       Sales_Month ,
       Total_Sales,
       RANK () OVER ( ORDER BY Total_Sales DESC ) AS Max_Rank,
       RANK () OVER ( ORDER BY Total_Sales ASC ) AS Min_Rank
   FROM monthly_sales  
   )
SELECT 
      Max_Rank,Min_Rank,
      CASE 
      	WHEN Max_Rank = 1 THEN 'Highest Sales Month'
      	WHEN Min_Rank = 1 THEN 'Lowest Sales Month'
      END AS Sales_Category
FROM RankedSales
WHERE Max_Rank = 1 OR Min_Rank = 1;

-- 9.What are the top 10 best-selling products by quantity?

SELECT 
       p.Product_Name,
       SUM(od.quantity)AS Quantity 
FROM
       order_details od
JOIN products p  ON  p.Product_ID=od.Product_ID
GROUP BY
      p.Product_Name
ORDER BY
      Quantity DESC
LIMIT 10;

-- 10.What are the top 10 products by revenue?

SELECT 
     p.Product_Name,
     SUM(od.quantity*od.Unit_Price)AS Revenue
  FROM 
      order_details od
  JOIN  
     products p  ON  p.Product_ID=od.Product_ID
 GROUP BY 
      p.Product_Name
 ORDER BY
     Revenue DESC 
 LIMIT 10;

-- 11.What is the stock availability by category?

WITH category_stock AS (
SELECT 
      Category,
      SUM(Stock_Quantity)AS stock_availability
FROM 
        products
GROUP BY
        Category
)
SELECT 
       Category,
       stock_availability,
       DENSE_RANK () OVER (ORDER BY stock_availability DESC ) AS stock_rank
FROM 
        category_stock;

-- 12.How many orders were placed each month?
-- Monthly Order Volume Report

SELECT   
       DATE_FORMAT(Order_Date,'%Y-%m')AS MONTH,
       COUNT(*)AS order_count
FROM
        orders
GROUP BY 
        MONTH 
ORDER BY 
        MONTH ASC ;

-- 13.What percentage of orders are pending, shipped, or cancelled?

SELECT Order_Status,
      CONCAT(
      ROUND(count(*)*100/(SELECT count(*)FROM orders),2),'%')AS percentage_of_orders
FROM
      orders 
GROUP BY Order_Status;

-- 14.What is the average order value over time?

WITH order_cte AS (
   SELECT 
        o.order_id,
        DATE_FORMAT(Order_Date,'%Y-%M')AS MONTH ,
        SUM(od.Quantity*od.Unit_Price)AS OrderTotal 
    FROM 
         orders o
   JOIN order_details od ON od.order_id=o.order_id
   GROUP BY DATE_FORMAT(Order_Date,'%Y-%M'),o.order_id
 )
 SELECT 
       MONTH,
       ROUND(AVG(OrderTotal ),2)AS avg_monthly_order_value
FROM  order_cte
 GROUP BY `MONTH`
 ORDER BY MONTH ;


-- 15.Which customers have placed the most orders?

SELECT 
       o.customer_id,
       c.First_Name,
       c.Last_Name,
        COUNT(Order_ID) AS order_count,
        DENSE_RANK () OVER (ORDER BY COUNT(Order_ID) DESC ) AS rank_order_count
FROM orders o 
JOIN customers1 c ON c.Customer_ID=o.Customer_ID
GROUP BY   c.First_Name,c.Last_Name,c.customer_id;


-- 16.Which regions have customers with high average order value?

WITH  order_cte AS (
    SELECT
         c.Region_ID,
         r.Region_Name,
         o.Order_ID,
         SUM(od.Quantity * od.Unit_Price) AS OrderTotal
  FROM orders o
  JOIN customers c ON o.Customer_ID = c.Customer_ID
  JOIN order_details od ON od.Order_ID = o.Order_ID
  JOIN Regions AS r ON r.Region_ID = c.Region_ID
  GROUP BY c.Region_ID,o.Order_ID,r.Region_Name
   )
   SELECT 
         Region_ID,
         Region_Name,
         ROUND(AVG(OrderTotal),2)AS Average_Order_Value
   FROM  order_cte 
   GROUP BY Region_ID,Region_Name
   ORDER BY  Average_Order_Value  DESC  ;

   
-- 17.Identify customers who signed up more than 6 months ago and have no orders.

WITH customer_cte AS (
    SELECT 
         c.Customer_ID,
         First_Name,
         Last_Name,
         Signup_Date
 FROM customers1 c
 LEFT JOIN orders o ON o.Customer_ID=c.Customer_ID
 WHERE o.Customer_ID IS NULL
 )
 SELECT 
       Customer_ID,
       First_Name,
         Last_Name,
         DATE_FORMAT(Signup_Date,'%Y-%m') AS Signup_Month
 FROM customer_cte
 WHERE Signup_Date <=CURDATE() - INTERVAL 6 MONTH 
 ORDER BY Signup_Date ;
