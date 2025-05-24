
📊 Dynamic SQL Query to Count NULLs in All Columns of customers1 Table
  
DECLARE @TableName NVARCHAR(128) = 'customers1';
DECLARE @SchemaName NVARCHAR(128) = 'dbo';
DECLARE @SQL NVARCHAR(MAX) = '';

SELECT @SQL = STRING_AGG(
    'SUM(CASE WHEN [' + COLUMN_NAME + '] IS NULL THEN 1 ELSE 0 END) AS missing_' + COLUMN_NAME,
    ', '
)
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = @TableName
  AND TABLE_SCHEMA = @SchemaName;

SET @SQL = 'SELECT ' + @SQL + ' FROM [' + @SchemaName + '].[' + @TableName + ']';
EXEC sp_executesql @SQL;

--2.Finding duplicate records based on First_Name and Last_Name.
WITH duplicate_cte AS (
SELECT *,
ROW_NUMBER () OVER (PARTITION BY First_Name,Last_Name ORDER BY  Customer_ID)AS row_num
FROM customers1)
SELECT*FROM duplicate_cte
WHERE row_num>1;

SELECT email FROM customers1
WHERE email NOT REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$';

SELECT phone FROM customers1;

SELECT phone,
REGEXP_REPLACE(phone,'^(\\+1|001)-?','')
FROM customers1;

UPDATE customers1 
SET phone=regexp_replace(phone,'^(\\+1|001)-?','')
WHERE phone REGEXP '^(\\+1|001)';

ALTER TABLE customers1 ADD COLUMN Extension varchar(20);


UPDATE  customers1
SET 
  extension = SUBSTRING_INDEX(phone, 'x', -1),
  phone = SUBSTRING_INDEX(phone, 'x', 1)
WHERE LOWER(phone) LIKE '%x%';

SELECT phone,
REGEXP_REPLACE(phone ,'[^0-9]','')
FROM customers1;


SELECT phone,
CONCAT(
LEFT(phone,3),'-',
MID(phone,4,3),'-',
right(phone,4))
FROM customers1;


UPDATE customers1
SET phone = CONCAT(
    LEFT(REGEXP_REPLACE(phone, '[^0-9]', ''), 3), '-',
    MID(REGEXP_REPLACE(phone, '[^0-9]', ''), 4, 3), '-',
    RIGHT(REGEXP_REPLACE(phone, '[^0-9]', ''), 4)
)
WHERE LENGTH(REGEXP_REPLACE(phone, '[^0-9]', '')) = 10;



UPDATE customers1
SET notes=coalesce(NULLIF(trim(notes),''));

