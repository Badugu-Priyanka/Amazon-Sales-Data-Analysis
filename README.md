# Amazon-Sales-Data-Analysis
Project Overview   
This project aims to analyze Amazon's sales data from three different branches (Mandalay, Yangon, and Naypyitaw) to identify key factors influencing sales performance.

Dataset Overview  
Source: Sales transactions from three Amazon branches.  
Size: 1000 rows, 17 columns.  
Key Columns: Invoice ID, Branch, City, Customer Type, Gender, Product Line, Unit Price, Quantity, Tax, Total, Date, Time, Payment Type, COGS, Gross Margin, Gross Income, Rating. 

Tools & Technologies Used  
SQL (MySQL Workbench) – For querying and data transformation.  
CSV Files – For data storage and import.  

Methodology  
Data Wrangling:
Created an Amazon sales table using SQL.  
Imported CSV data into MySQL Workbench.  
Built a database for structured analysis.  
Feature Engineering: 
Extracted weekday and month name from transaction dates.  
Categorized transactions by time of day (Morning, Afternoon, Evening).  
Data Analysis: 
Calculated average rating per product line.  
Identified best-selling times for each weekday.  
Determined highest revenue-contributing customer type.

Key Insights  
Certain product lines have higher average ratings.  
Sales patterns vary by time of day and weekday.  
A specific customer type contributes the highest revenue.  

How to Run the Project  
Install MySQL Workbench and set up a database.  
Import CSV file into MySQL.  
Run SQL queries from the analysis section to gain insights.  

Contributors - Badugu Priyanka  

License  
This project is for educational purposes. Feel free to modify and enhance it!  

