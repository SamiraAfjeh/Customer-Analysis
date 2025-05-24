
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

--Finding duplicate records based on First_Name and Last_Name.
WITH duplicate_cte AS (
SELECT *,
ROW_NUMBER () OVER (PARTITION BY First_Name,Last_Name ORDER BY  Customer_ID)AS row_num
FROM customers1)
SELECT*FROM duplicate_cte
WHERE row_num>1;

-- This code filters out emails that do not follow a basic structure like a@b.com.
SELECT Email
FROM customers1
WHERE Email IS NOT NULL
  AND (
        Email NOT LIKE '%@%.%' OR
        CHARINDEX(' ', Email) > 0 OR
        Email LIKE '%..%' OR
        Email LIKE '%@%@%'
      );

🎯 Stored Procedure Name: usp_Clean_Customers1_Data
✅ Features:

Report duplicate records based on First_Name + Last_Name

Report invalid email addresses

Report invalid phone numbers

CREATE PROCEDURE usp_Clean_Customers1_Data
AS
BEGIN
    SET NOCOUNT ON;

    PRINT '----- Duplicate Records by First and Last Name -----';
    WITH duplicate_cte AS (
        SELECT *,
               ROW_NUMBER() OVER (PARTITION BY FirstName, LastName ORDER BY CustomerID) AS row_num
        FROM customers1
    )
    SELECT * 
    FROM duplicate_cte
    WHERE row_num > 1;

    PRINT '----- Invalid Email Addresses -----';
    SELECT Email, CustomerID
    FROM customers1
    WHERE Email IS NOT NULL
      AND (
            Email NOT LIKE '%@%.%' OR
            CHARINDEX(' ', Email) > 0 OR
            Email LIKE '%..%' OR
            Email LIKE '%@%@%' OR
            LEN(Email) < 5
          );

    PRINT '----- Invalid Phone Numbers (non-numeric or wrong length) -----';
    SELECT Phone, CustomerID
    FROM customers1
    WHERE Phone IS NOT NULL
      AND (
            LEN(Phone) <> 10 OR
            Phone LIKE '%[^0-9]%'  -- contains non-numeric characters
          );

    PRINT '----- Data Check Completed. -----';
END;

EXEC usp_Clean_Customers1_Data;









UPDATE customers1
SET notes=coalesce(NULLIF(trim(notes),''));

