/* 1.1 Create Database */ 
CREATE DATABASE IF NOT EXISTS amazon;

/* Use Database */
use amazon;

/* 1.2 Create table amazon */
CREATE TABLE IF NOT EXISTS amazon(
Invoice_ID VARCHAR(50),
    Branch VARCHAR(50),
    City VARCHAR(50),
    Customer VARCHAR(50),
    Gender VARCHAR(10),
    Product_line VARCHAR(50),
    Unit_price DECIMAL(10,2),
    Quantity INT,
    Tax_5_percent DECIMAL(10,4),
    Total DECIMAL(10,4),
    Date DATE,
    Time TIME,
    Payment VARCHAR(50),
    cogs DECIMAL(10,2),
    gross_margin_percent DECIMAL(10,9),
    gross_income DECIMAL(10,4),
    Rating DECIMAL(3,1)
);

/* Load data from csv file to table amazon */
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Amazon.csv'
INTO TABLE amazon
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@Invoice_ID,@Branch,@City,@Customer,@Gender,@Product_line,@Unit_price,@Quantity,@Tax_5_percent,@Total,@Date,@Time,@Payment,@cogs,@gross_margin_percent,@gross_income,@Rating)
SET Invoice_ID = @Invoice_ID,
	Branch = @Branch,
    City = @City,
    Customer = @Customer,
    Gender = @Gender,
    Product_line = @Product_line,
    Unit_price = @Unit_price,
    Quantity = @Quantity,
    Tax_5_percent = @Tax_5_percent,
    Total = @Total,
	Date = STR_TO_DATE(@Date, '%d-%m-%Y'),
    Time = @Time,
    Payment = @Payment,
    cogs = @cogs,
    gross_margin_percent = @gross_margin_percent,
    gross_income = @gross_income,
    Rating = @Rating;

SELECT * FROM amazon;

/* 1.3 There are no null values in the database. */

/* 2.1 Add a new column named timeofday to give insight of sales in the Morning, Afternoon and Evening. */
ALTER TABLE amazon ADD COLUMN timeofday VARCHAR(50); 

UPDATE amazon SET timeofday = 
CASE WHEN Time BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
WHEN Time BETWEEN '12:01:00' AND '16:00:00' THEN 'Afternoon'
ELSE 'Evening'
END;

SELECT * FROM amazon;

/* 2.2 Add a new column named dayname that contains the extracted days of the week on which the given transaction took place (Mon, Tue, Wed, Thur, Fri). */
ALTER TABLE amazon ADD COLUMN dayname VARCHAR(10);

UPDATE amazon SET dayname = DAYNAME(Date);

SELECT * FROM amazon;

/* 2.3 Add a new column named monthname that contains the extracted months of the year on which the given transaction took place (Jan, Feb, Mar). */
ALTER TABLE amazon ADD COLUMN monthname VARCHAR(10);

UPDATE amazon SET monthname = MONTHNAME(Date);

SELECT * FROM amazon;

/* Q1.What is the count of distinct cities in the dataset? */
SELECT COUNT(DISTINCT City) AS count_of_distinct_city
FROM amazon;

/* Q2.For each branch, what is the corresponding city? */
SELECT DISTINCT Branch, City
FROM amazon;

/* Q3.What is the count of distinct product lines in the dataset? */
SELECT COUNT(DISTINCT Product_line) AS count_of_distinct_productLine 
FROM amazon;

/* Q4.Which payment method occurs most frequently? */
SELECT Payment, COUNT(Invoice_ID) AS Transactions
FROM amazon
GROUP BY Payment
ORDER BY Transactions DESC LIMIT 1;

/* Q5.Which product line has the highest sales? */
SELECT Product_line,SUM(Quantity * Unit_price) AS sales
FROM amazon
GROUP BY Product_line
ORDER BY sales DESC LIMIT 1;

/* Q6.How much revenue is generated each month? */
SELECT monthname,SUM(Total) AS total_revenue
FROM amazon
GROUP BY monthname;

/* Q7.In which month did the cost of goods sold reach its peak? */
SELECT monthname,SUM(cogs) AS cost_of_goods_sold
FROM amazon
GROUP BY monthname
ORDER BY cost_of_goods_sold DESC LIMIT 1;

/* Q8.Which product line generated the highest revenue? */
SELECT Product_line,SUM(Total) AS total_revenue
FROM amazon
GROUP BY Product_line
ORDER BY total_revenue DESC LIMIT 1;

/* Q9.In which city was the highest revenue recorded? */
SELECT City,SUM(Total) AS total_revenue
FROM amazon
GROUP BY City
ORDER BY total_revenue DESC LIMIT 1;

/* Q10.Which product line incurred the highest Value Added Tax? */
SELECT Product_line,SUM(Tax_5_percent) AS Value_Added_Tax
FROM amazon
GROUP BY Product_line
ORDER BY Value_Added_Tax DESC LIMIT 1;

/* Q11.For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad." */
WITH ProductSales AS (
    SELECT Product_line, SUM(Quantity * Unit_price) AS Sales
    FROM amazon
    GROUP BY Product_line
),
AverageSales AS (
    SELECT AVG(Sales) AS Avg_Sales
    FROM ProductSales
)
SELECT P.Product_line,P.Sales, CASE
WHEN P.Sales > (SELECT Avg_Sales FROM AverageSales) THEN 'Good'
ELSE 'Bad'
END AS SalesPerformance
FROM ProductSales P;

/* Q12.Identify the branch that exceeded the average number of products sold. */
WITH BranchTotalSales AS(
	SELECT Branch,SUM(Quantity) AS Total_Sales
    FROM amazon
    GROUP BY Branch
),
AverageProductsSold AS(
	SELECT AVG(Total_Sales) AS Avg_Sales
    FROM BranchTotalSales
)
SELECT B.Branch,B.Total_Sales
FROM BranchTotalSales B
WHERE B.Total_Sales > (SELECT Avg_Sales FROM AverageProductsSold);    

/* Q13.Which product line is most frequently associated with each gender? */
WITH ProductLineGender AS(
    SELECT Gender,Product_line,COUNT(Gender) AS count
    FROM amazon
    GROUP BY Gender,Product_line
),
MaxCountGender AS(
    SELECT Gender,MAX(count) AS MaxCount
    FROM ProductLineGender
    GROUP BY Gender
)
SELECT ProductLineGender.Gender, ProductLineGender.Product_line, ProductLineGender.count
FROM ProductLineGender
JOIN MaxCountGender ON ProductLineGender.Gender = MaxCountGender.Gender 
AND ProductLineGender.count = MaxCountGender.MaxCount;
 
 /* Q14.Calculate the average rating for each product line. */
SELECT Product_line, ROUND(AVG(Rating), 2) AS Average_Rating
FROM amazon
GROUP BY Product_line;

/* Q15.Count the sales occurrences for each time of day on every weekday. */
SELECT dayname,timeofday,COUNT(*) AS sales_occurences
FROM amazon
GROUP BY dayname,timeofday
ORDER BY FIELD(dayname,'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'),
FIELD(timeofday,'Morning','Afternoon','Evening');

/* Q16.Identify the customer type contributing the highest revenue. */
SELECT Customer,SUM(Total) AS total_revenue
FROM amazon
GROUP BY Customer
ORDER BY total_revenue DESC LIMIT 1;

/* Q17.Determine the city with the highest VAT percentage. */
SELECT City,SUM(Tax_5_percent) AS VAT_percentage
FROM amazon
GROUP BY City
ORDER BY VAT_percentage DESC LIMIT 1;

/* Q18.Identify the customer type with the highest VAT payments. */
SELECT Customer,SUM(Tax_5_percent) AS VAT_payments
FROM amazon
GROUP BY Customer 
ORDER BY VAT_payments DESC LIMIT 1;

/* Q19.What is the count of distinct customer types in the dataset? */
SELECT COUNT(DISTINCT Customer) AS count_of_customer_types
FROM amazon;

/* Q20.What is the count of distinct payment methods in the dataset? */
SELECT COUNT(DISTINCT Payment) AS count_of_payment_methods
FROM amazon;

/* Q21.Which customer type occurs most frequently? */
SELECT Customer,COUNT(Invoice_ID) AS transactions
FROM amazon
GROUP BY Customer 
ORDER BY transactions DESC LIMIT 1;

/* Q22.Identify the customer type with the highest purchase frequency. */
SELECT Customer,COUNT(Quantity) AS purchase
FROM amazon
GROUP BY Customer 
ORDER BY purchase DESC LIMIT 1;

/* Q23.Determine the predominant gender among customers. */
SELECT Gender,COUNT(*) AS count
FROM amazon
GROUP BY Gender
ORDER BY count DESC LIMIT 1;

/* Q24.Examine the distribution of genders within each branch. */
SELECT Branch,Gender,COUNT(*) AS Gender_Count
FROM amazon
GROUP BY Branch,Gender
ORDER BY Branch,Gender_Count DESC;

/* Q25.Identify the time of day when customers provide the most ratings. */
SELECT timeofday,AVG(Rating) AS Rating_count
FROM amazon
GROUP BY timeofday
ORDER BY Rating_count DESC LIMIT 1;

/* Q26.Determine the time of day with the highest customer ratings for each branch. */
WITH Ratings AS(
    SELECT Branch,timeofday,AVG(Rating) AS Avg_Rating
    FROM amazon
    GROUP BY Branch,timeofday
)
SELECT Branch,timeofday,Avg_Rating
FROM Ratings
WHERE (Branch,Avg_Rating) IN (
    SELECT Branch,MAX(Avg_Rating)
    FROM Ratings
    GROUP BY Branch
)
ORDER BY Branch;

/* Q27.Identify the day of the week with the highest average ratings. */
SELECT dayname,AVG(Rating) AS Avg_Rating
FROM amazon
GROUP BY dayname 
ORDER BY Avg_Rating DESC LIMIT 1;

/* Q28.Determine the day of the week with the highest average ratings for each branch. */
WITH Ratings AS(
    SELECT Branch,dayname,AVG(Rating) AS Avg_Rating
    FROM amazon
    GROUP BY Branch,dayname
)
SELECT Branch,dayname,Avg_Rating
FROM Ratings
WHERE (Branch,Avg_Rating) IN (
    SELECT Branch,MAX(Avg_Rating)
    FROM Ratings
    GROUP BY Branch
)
ORDER BY Branch;
