# Sales Analytics Portfolio Project

## Project Overview

This project is a complete, simulated **sales database** built for practicing and showcasing data skills. It contains realistic and intentionally messy data across multiple related tables, making it ideal for:

- Data cleaning
- SQL querying
- Dashboard creation
- Real-world data analysis scenarios

This dataset is perfect for portfolio projects, job interview practice, or hands-on learning.


---

## Project Structure

The dataset consists of five related CSV files:

`customers.csv` —List of customers with names, emails, phone numbers, region, signup date, status, and messy notes.

`products.csv` — Product catalog including product name, category, price, and stock quantity. 

`orders.csv` — Sales order summary including customer ID, order date, status, and total amount. 

 `order_details.csv` — Line items for each order including quantity and unit prices. 

`regions.csv` — Lookup table for region names linked to customers.

## Key Features

- **Dirty Data**: Includes missing values, blank spaces, inconsistent formats, and soft-deleted records.

**Relational Structure**: Tables are linked by keys (`CustomerID`, `OrderID`, `ProductID`, `RegionID`) and can be used for JOINs.

- **Realistic Simulation**: Data is generated with Faker for names, dates, and free-text notes.

- **Great for Practice**:
   - Data Cleaning (nulls, duplicates, trims)
   - SQL Queries (JOINs, filtering, aggregations)
  - Dashboarding (Excel, Power BI, Tableau)
  - Creating a full portfolio project

---

## Example Use Cases

- Identify inactive or fake customers
- Calculate monthly revenue trends
- Find most popular products per region
- Build a customer segmentation dashboard
- Clean up email and phone number formats

---

## Getting Started

1. Load the CSV files into your database or Excel.
2. Use SQL or Excel formulas to explore and clean the data.
3. Build dashboards and reports based on your insights.
4. Upload your code and visualizations to GitHub or your portfolio.

---

## Analytical Questions for Visualization

### Customer Analytics
- Which regions have the most active customers?
- How many customers signed up per month?
- What percentage of customers are inactive or deleted?
- What is the distribution of customers by status and region?

### Sales Performance
- What is the monthly sales trend over the last 12–24 months?
- What is the total revenue by region?
- Which months had the highest and lowest sales?

### Product Insights
- What are the top 10 best-selling products by quantity?
- What are the top 10 products by revenue?
- What is the stock availability by category?

### Order Analysis
- How many orders were placed each month?
- What percentage of orders are pending, shipped, or cancelled?
- What is the average order value over time?

### Customer Segmentation
- Which customers have placed the most orders?
- Which regions have customers with high average order value?
- Identify customers who signed up more than 6 months ago and have no orders.

### Data Quality Checks
- How many customers have missing or invalid emails?
- Which rows in the Notes column are blank or messy?
- Detect duplicate or inconsistent records across tables

---

## Advanced Ideas (Optional but Impressive)
- RFM Analysis: Segment customers by Recency, Frequency, Monetary value.
- Cohort Analysis: Track behavior of customers based on their signup month.
- Forecasting: Predict sales for the next 3 months using historical data.
