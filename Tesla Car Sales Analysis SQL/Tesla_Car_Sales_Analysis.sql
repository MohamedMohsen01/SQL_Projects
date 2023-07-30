
--First, I cleaned the data in Excel and adjusted the date format.

USE TeslaSales

-- Adding a new column as a primary key called 'id'
ALTER TABLE CarSales
ADD id INT IDENTITY(1,1) NOT NULL PRIMARY KEY;

-- Altering Model column and making sure the column is not null
ALTER TABLE CarSales
ALTER COLUMN Model VARCHAR(50) NOT NULL;

-- Ensuring the Period column is not null and is of DATE data type
ALTER TABLE CarSales
ALTER COLUMN Period DATE NOT NULL;

-- Ensuring the Country column is not null
ALTER TABLE CarSales
ALTER COLUMN Country VARCHAR(50) NOT NULL;

-- Ensuring the Purchase_type column is not null
ALTER TABLE CarSales
ALTER COLUMN Purchase_type VARCHAR(50) NOT NULL;

-- Ensuring the Version column is not null
ALTER TABLE CarSales
ALTER COLUMN Version VARCHAR(50) NOT NULL;

-- Ensuring the Price column is not null and using DECIMAL data type for currency values
ALTER TABLE CarSales
ALTER COLUMN Revenue DECIMAL(10,2) NOT NULL;

-- Ensure the Gross_Profit column is not null and use DECIMAL data type for currency values
ALTER TABLE CarSales
ALTER COLUMN Gross_Profit DECIMAL(10,3) NOT NULL;


-- Adding a new column called "month_name" column
SELECT
	Period,
	DATENAME(MONTH, Period) AS month_name
FROM CarSales;

ALTER TABLE CarSales ADD month_name VARCHAR(10);

UPDATE CarSales
SET month_name = DATENAME(MONTH, Period);


-- Retrieving all the columns and rows from the table
SELECT *
FROM CarSales;


--What is the total number of sales transactions in our dataset?
SELECT COUNT(*) AS no_total_sal
FROM CarSales;	


--So let's see what date range are we dealing with in this dataset?
SELECT MIN(Period) AS Min_Period, MAX(Period) AS Max_Period
FROM CarSales;		--2016-01-01 -> 2017-12-01


--Let's do outliers detection and see if there's any outliers in the car prices or gross profits
  SELECT 
  MAX(Revenue) AS max_price,
  MIN(Revenue) AS min_price,
  MAX(Gross_Profit) AS max_profit,
  MIN(Gross_Profit) AS min_profit
FROM CarSales;     --There are no outliers since the numbers look normal.


-- Ok, determining the number of unique car models in the data.
SELECT 
	COUNT(DISTINCT Model) AS no_of_models
FROM CarSales;		--There are indeed only the 2 models				


--Let�s see if there is a difference in sales between these two car models (all time).  
SELECT 
	Model, 
	SUM(Revenue) AS Total_Sales
FROM CarSales
GROUP BY Model
ORDER BY Total_Sales DESC;	  
--'Model X' generated $669,792,500.00 more revenue than 'Model S'. 
--This difference in revenue is indeed significant and indicates that 'Model X' outperformed 'Model S' in terms of revenue generation during that specific 2-year timeframe.


--Which model has the highest total gross profit (all time)? 
SELECT 
	Model, 
	SUM(Gross_Profit) AS Total_Profit
FROM CarSales
GROUP BY Model
ORDER BY Total_Profit DESC;	  --'Model X' has the highest total profit with $1,039,560,332.87.			


--Let's analyze the annual total revenue generated by each of these car models in the year 2016:
SELECT 
	Model, 
	SUM(Revenue) AS Total_Sales
FROM CarSales
WHERE Period BETWEEN '2016-01-01' AND '2016-12-01'
GROUP BY Model
ORDER BY Total_Sales DESC;      --"Model X" generated $365,458,900.00 more revenue than "Model S" in 2016.


--Let's examine the total revenue generated by each of these car models in the year 2017.
SELECT 
	Model, 
	SUM(Revenue) AS Total_Sales
FROM CarSales
WHERE Period BETWEEN '2017-01-01' AND '2017-12-01'
GROUP BY Model
ORDER BY Total_Sales DESC;   --"Model X" generated $304,333,600.00 more revenue than "Model S" in 2017.
--So now we know our top performers and worst performers in this date range. 


--What is our best performing model (all time)?
SELECT 
	Model, 
	SUM(Revenue) AS Total_Sales
FROM CarSales
GROUP BY Model
ORDER BY Total_Sales DESC;   --Our best performing model is "Model X" with total_sales = $3,555,430,000.00


--Let's analyze the performance of each car version within the best-performing model.
SELECT Model, Version, SUM(Revenue) AS total_sales
FROM CarSales
WHERE Model = 'Model X'
GROUP BY Model, Version
ORDER BY total_sales DESC;	  --"P90D" car version generated $2,490,470,000.00 in revenue, while "90D" generated $1,064,960,000.00.


--Let's see the performance of each car version within the worst-performing model.
SELECT Model, Version, SUM(Revenue) AS total_sales 
FROM CarSales
WHERE Model = 'Model S'
GROUP BY Model, Version
ORDER BY total_sales DESC;	 --It appears that the "75 RWD" is the top-selling car version in "Model S", while "90D AWD" is the least popular.


--Which car version with the highest and lowest all-time sales.
SELECT Version, SUM(Revenue) AS total_sales
FROM CarSales
GROUP BY Version
ORDER BY SUM(Revenue) DESC;  --"P90D" has the highest sales with $2,490,470,000.00, while "90D AWD" has the lowest with $393,916,700.00.


-- Which car version is generating the highest total gross profit (all time)?
SELECT 
	TOP 1 Version, 
		SUM(Gross_Profit) AS Total_Profit
FROM CarSales
GROUP BY Version
ORDER BY Total_Profit DESC;	 --"P90D" generates the highest total gross profit among versions.


--Which car version is the most popular among buyers?
SELECT 
	Version, 
	COUNT(*) AS no_of_versions 
FROM CarSales
GROUP BY Version 
ORDER BY no_of_versions DESC;  -- So we see that "P90D" is the most popular among buyers with 33,655 cars sold, while "90D AWD" is the least popular with 4,441 cars sold.


--Let's see how many country are in our dataset:
SELECT DISTINCT Country 
FROM CarSales        --There are three countries: US, Germany, and Australia.


--What is the total gross profit and sales for each country?
SELECT 
	Country, 
	SUM(Gross_Profit) AS Total_Gross_Profit, 
	SUM(Revenue) AS Total_Sales
FROM CarSales
GROUP BY Country
ORDER BY Total_Gross_Profit DESC;	 				
--			   Gross_Profit	       Revenue
--US	      1523726361.090	4778070100.00
--Germany	  274277000.165	    1284433000.00
--Australia	  80356233.012	    378564400.00		 
																	

--Which country had the highest demand for Tesla cars?
SELECT 
	Country, 
	COUNT(*) AS no_demand_cars
FROM CarSales
GROUP BY Country
ORDER BY no_demand_cars DESC;	 --"US" had the highest demand for Tesla cars with 63,469 cars, followed by "Germany" with 16,956 cars.


--How does the average gross profit vary across different car versions for each country?
SELECT 
	Country, 
	Version, 
	AVG(Gross_Profit) AS Avg_Gross_Profit
FROM CarSales
GROUP BY Country, Version
ORDER BY Country, Avg_Gross_Profit DESC;


-- What is The most sold car model in each country?
SELECT Country, Model
FROM (SELECT Country, Revenue, Model, ROW_NUMBER() OVER(PARTITION BY Country ORDER BY SUM(Revenue) DESC) AS RN
		FROM CarSales
		GROUP BY Country, Revenue, Model) as NewTable
WHERE RN = 1;     --"Model X" is the most popular among countries


-- what is the most sold car version in each country?
SELECT Country, Version
FROM (
  SELECT Country, Version, 
         ROW_NUMBER() OVER (PARTITION BY Country ORDER BY COUNT(*) DESC) AS RN
  FROM CarSales
  GROUP BY Country, Version
) AS sales_version
WHERE RN = 1;	--"P90D" is the most sold car version in each country


-- what is the most expensive car version in each country?
SELECT Country, Version
FROM (
  SELECT Country, Version, 
         ROW_NUMBER() OVER (PARTITION BY Country ORDER BY Revenue DESC) AS RN
  FROM CarSales
  GROUP BY Country, Version, Revenue
) AS sales_version
WHERE RN = 1;	 --"90D AWD" is the most expensive car version in each country


-- what is the highest car version price in each country?
SELECT Country, Revenue
FROM (
  SELECT Country, Revenue, 
         ROW_NUMBER() OVER (PARTITION BY Country ORDER BY Revenue DESC) AS RN
  FROM CarSales
  GROUP BY Country, Revenue
) AS sales_version
WHERE RN = 1;     --The '90D AWD' car version reached the highest price of $88,700.00 individually in all three countries..


--How many car models were sold in the US in 2016?
SELECT 
	Model, 
	COUNT(Model) AS us_no_models
FROM CarSales
WHERE (Country = 'US') AND (Period between '2016-01-01' AND '2016-12-01')              
GROUP BY Model;	  
-- USA car sales in 2016:
-- "Model X" was sold 17,553 times.
-- "Model S" was sold 14,592 times.


--How many car models were sold in the US in 2017?
SELECT 
	Model, 
	COUNT(Model) AS us_no_models
FROM CarSales
WHERE (Country = 'US') AND (Period BETWEEN '2017-01-01' AND '2017-12-01')              
GROUP BY Model;	
-- USA car sales in 2017:
-- "Model X" was sold 17,238 times.
-- "Model S" was sold 14,086 times.



--IS there a difference in sales between the first and second quarter of the year 2016 and 2017. 
SELECT 
	SUM(Revenue) AS quarter_Revenue
FROM CarSales
WHERE Period between '2016-01-01' AND '2016-06-01';


SELECT 
	SUM(Revenue) AS quarter_revenue
FROM CarSales
WHERE Period between '2017-01-01' AND '2017-06-01';  --not a big difference in total sales in the first and second quarter of the year 2016 and 2017.


--Let�s see if there is a difference in sales between these two car models in the first and second quarter of the year 2016 and 2017.  
SELECT Model,
	SUM(Revenue) AS quarter_Revenue
FROM CarSales
WHERE Period between '2016-01-01' AND '2016-06-01'
GROUP BY Model;


SELECT Model,
	SUM(Revenue) AS quarter_revenue
FROM CarSales
WHERE Period between '2017-01-01' AND '2017-06-01'
GROUP BY Model;
-- There is a notable difference in sales between the two car models in the first and second quarters of 2016, but the difference is less pronounced for the same quarters in 2017.


-- What is the total revenue for each month (all time)?
SELECT month_name, sum(Revenue) as monthly_revenue
FROM CarSales
GROUP BY month_name 
ORDER BY monthly_revenue DESC;  --"July" had the highest revenue with 564,770,000.00 and "January" is the lowest revenue.


-- what is the monthly gross profit for each month (all time)?
SELECT month_name, sum(Gross_Profit) as monthly_Profit
FROM CarSales
GROUP BY month_name 
ORDER BY monthly_Profit DESC;


-- What is the total revenue for each month in 2016?
SELECT month_name, sum(Revenue) as month_revenue
FROM CarSales
WHERE Period between '2016-01-01' AND '2016-12-01'
GROUP BY month_name 
ORDER BY month_revenue DESC;  --"April" had the highest revenue with $283,424,700.00 and "January" was the lowest revenue with $244,933,300.00


-- What is the total revenue for each month in 2016?
SELECT month_name, sum(Revenue) as month_revenue
FROM CarSales
WHERE Period between '2017-01-01' AND '2017-12-01'
GROUP BY month_name 
ORDER BY month_revenue DESC;  --"July" has the highest revenue with $282,845,500.00 and "October" is the lowest revenue with $244,003,900.00


--How many unique car models were sold in the Australia?
SELECT 
	Model, 
	COUNT(DISTINCT Model) AS AU_no_models
FROM CarSales
WHERE (Country = 'Australia')
GROUP BY Model;	  


--What was the total gross profit generated from all sales in Germany?
SELECT 
	Country, 
	ROUND(SUM(Gross_Profit),3) AS Ger_total_prof
FROM CarSales
WHERE Country = 'Germany'
GROUP BY Country;


--What is the average Revenue of all cars sold in the US?
SELECT 
	Country, 
	ROUND(AVG(Revenue),3) AS US_avg_Price
FROM CarSales 
WHERE Country = 'US'
Group BY Country;	 --The "US" has an average Revenue of all cars sold with $75281.950


 --What is the total gross profit generated from each car version in the US?
SELECT 
	Version, 
	SUM(Gross_Profit) AS US_totalprofit
FROM CarSales
WHERE Country = 'US'
GROUP BY Version;	


--Which car model had the highest price in the US?
SELECT 
	Model, 
	ROUND(SUM(Revenue), 2) AS US_total_price
FROM CarSales
WHERE Country = 'US'
GROUP BY Model
ORDER BY US_total_price DESC;	 --"Model X" had the highest price in the US with $2,635,476,000.00											


--How many sales transactions were made for each car version in the US?
SELECT 
	Version, 
	COUNT(*) AS no_sal_trans
FROM CarSales
WHERE Country = 'US'
GROUP BY Version;	


--Which car model had the highest revenue in Australia?
SELECT 
	Model, 
	ROUND(SUM(Revenue), 2) AS AU_total_revenue
FROM CarSales
WHERE Country = 'Australia'
GROUP BY Model
ORDER BY AU_total_revenue DESC;	  --"Model X" had the highest price in Australia with $205,742,000.00


--What was the total sales generated from all sales in Australia?
SELECT ROUND(SUM(Revenue),3) AS AU_total_sal
FROM CarSales
WHERE Country = 'Australia'
GROUP BY Country;	--"Australia" had $378,564,400.00 total sales																												

	
--Lets see how many purchase type do we have in our dataset:
SELECT DISTINCT Purchase_type
FROM CarSales   --Cash purchase and Deposit


--Which purchase type is most commonly used by people?
SELECT 
	TOP 1 Purchase_type, 
	COUNT(*) AS no_of_purchases 
FROM CarSales
GROUP BY Purchase_type
ORDER BY no_of_purchases DESC;	 --"Deposit" is the most commonly purchase type with 45,976 number of purchases.						 	


--What is the distribution of purchase types for each car model?
SELECT 
	Model, 
	Purchase_type, 
	COUNT(*) AS Frequency
FROM CarSales
GROUP BY Model, Purchase_type
ORDER BY Model, Frequency DESC;							 


-- What is the total sales for each purchase type?
SELECT 
	Purchase_type, 
	SUM(Revenue) AS Total_Sales
FROM CarSales
GROUP BY Purchase_type
ORDER BY Total_Sales DESC;	--Total sales from 'Deposit' purchases amount to $3,465,841,400.00, while 'Cash purchases' account for $2,975,226,100.00.


-- What is the average gross profit for each purchase type?
SELECT 
	Purchase_type, 
	AVG(Gross_Profit) AS AVG_Total_Sales
FROM CarSales
GROUP BY Purchase_type
ORDER BY AVG_Total_Sales DESC;	
--Deposit	      22095.055110
--Cash purchase	  21771.944176


--Which country had the highest number of cash purchases?
SELECT 
	TOP 1 Country, 
	COUNT(*) AS cash_Purchase
FROM CarSales
WHERE Purchase_type = 'Cash purchase'
GROUP BY Country
ORDER BY cash_Purchase DESC;	--The United States (US) recorded the highest number of cash purchases, with a total of 28,788 transactions.


--Which country had the highest number of Deposit purchases?
SELECT 
	TOP 1 Country, 
	COUNT(*) AS depo_Purchase
FROM CarSales
WHERE Purchase_type = 'Deposit'
GROUP BY Country
ORDER BY depo_Purchase DESC;  --we also see that the United States (US) recorded the highest number of Deposit with 34,681 purchases transactions.


--Which purchase type is most commonly used in each country?
SELECT Country, Purchase_type
FROM (SELECT Country, Purchase_type, ROW_NUMBER() OVER(PARTITION BY Country ORDER BY count(*) DESC) AS RN
		FROM CarSales
		GROUP BY Country, Purchase_type) as NewTable
WHERE RN = 1;	--"Deposit" is the most commonly used purchase type in each country.


--What was the most common purchase type for 'Model S' in Germany?
SELECT 
	Model, 
	Purchase_type, 
	COUNT(Purchase_type) AS no_Pur_type
FROM CarSales
WHERE Country = 'Germany' AND Model = 'Model S'
GROUP BY Model, Purchase_type
ORDER BY no_Pur_type DESC;															
--Model S	Deposit	        3925
--Model S	Cash purchase	3595															

																    
--How does the average price vary for different purchase types in the US?
SELECT 
	Purchase_type, 
	ROUND(AVG(Revenue), 3) AS avg_sales
FROM CarSales
WHERE Country = 'US'
GROUP BY Purchase_type;				
-- 	the "Cash purchase" method showed an average price of $75,226.455, while the "Deposit" method had a slightly higher average price of $75,328.015.			


--Calculating the average car price and gross profit
--Calculating the standard deviation of price and gross profits
SELECT
  AVG(Revenue) AS Price_Mean,
  STDEV(Revenue) AS Price_StdDev,
  AVG(Gross_Profit) AS Profit_Mean,
  STDEV(Gross_Profit) AS Profit_StdDev
FROM CarSales;									


--Is there a correlation between car price and gross profit?
SELECT 
  (SUM(Revenue * Gross_Profit) - COUNT(*) * AVG(Revenue) * AVG(Gross_Profit)) /
  (COUNT(*) * STDEV(Revenue) * STDEV(Gross_Profit)) AS CorrelationCoefficient
FROM CarSales;

 /* Yes, there is a correlation between car price and gross profit.
 The correlation coefficient of 0.1201 between car price and gross profit suggests a relatively weak positive correlation between these two variables. 
 This means that there is a slight tendency for higher car prices to be associated with slightly higher gross profits, but the relationship is not very strong. 
 The value being positive indicates that when car prices increase, gross profits also tend to increase to some extent.*/