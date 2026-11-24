-- creating new database 
create database adventureworks_project;
use adventureworks_project;

-- check TABLE-1 {"fact_internet_sales"} table
describe factinternetsales;
select * from factinternetsales limit 5;
select count(*) from factinternetsales;
ALTER TABLE factinternetsales CHANGE `ï»¿ProductKey` ProductKey INT;

-- check TABLE-2 {"fact_internet_sales_new"} table
describe fact_internet_sales_new;
select * from fact_internet_sales_new limit 5;
select count(*) from fact_internet_sales_new;
ALTER TABLE fact_internet_sales_new CHANGE `ï»¿ProductKey` ProductKey INT;

-- check TABLE-3 {"dimcustomer"} table
select * from dimcustomer limit 5;
select count(*) from dimcustomer;
describe dimcustomer;
ALTER TABLE dimcustomer CHANGE `ï»¿CustomerKey` CustomerKey INT;


-- check TABLE-4 {"dimdate"} table
describe dimdate;
select * from dimdate limit 5;
select count(*) from dimdate;
alter table dimdate change `ï»¿DateKey` DateKey int;

-- check TABLE-5 {"dimproduct"} table
select * from dimproduct limit 5;
select count(*) from dimproduct;
SELECT COUNT(*) FROM dimproduct WHERE `Unit price` IS NOT NULL;
describe dimproduct;
ALTER TABLE dimproduct CHANGE `ï»¿ProductKey` ProductKey INT;  

SET SQL_SAFE_UPDATES = 0;
UPDATE dimproduct SET `Unit price` = NULL WHERE TRIM(`Unit price`) = '';
UPDATE dimproduct SET StandardCost = NULL WHERE TRIM(StandardCost) = '';
UPDATE dimproduct SET ProductSubcategoryKey = NULL WHERE TRIM(ProductSubcategoryKey) = '';

SELECT *
FROM dimproduct WHERE `Unit price` IS NOT NULL LIMIT 5;

ALTER TABLE dimproduct
  MODIFY `Unit price` DECIMAL(10,2),
  MODIFY ProductSubcategoryKey INT,
  MODIFY StandardCost DECIMAL(12,4); 


-- check TABLE-6 {"dim_product_category"} table
describe dimproductcategory;
select * from dimproductcategory limit 5;
select count(*) from dimproductcategory;
alter table dimproductcategory change `ï»¿ProductCategoryKey`  ProductCategoryKey int;

-- check TABLE-7 {"dim_product_sub_category"} table
describe dimproductsubcategory;
select * from dimproductsubcategory limit 5;
select count(*) from dimproductsubcategory;
alter table dimproductsubcategory change `ï»¿ProductSubCategoryKey`  ProductSubCategoryKey int;


-- check TABLE-8 {"dim_sales_territory"} table
describe dimsalesterritory;
select * from dimsalesterritory limit 5;
select count(*) from dimsalesterritory;
alter table dimsalesterritory change `ï»¿SalesTerritoryKey` SalesTerritoryKey  int;


-- (Q0) UNION fact sales tables creation 
DROP TABLE IF EXISTS fact_internet_sales_union;
create table fact_internet_sales_union as
select * from factinternetsales   
union all
select * from fact_internet_sales_new;

select count(*) from fact_internet_sales_union;   -- total rows = 60398
describe fact_internet_sales_union;


-- (Q1) productname 
SELECT
    s.*,
    p.EnglishProductName AS ProductName
FROM fact_internet_sales_union AS s
LEFT JOIN dimproduct AS p
    ON s.ProductKey = p.ProductKey;


-- (Q2) Customer fullname from dimcustomer and unitprice from dimproduct
describe dimcustomer;
describe dimproduct;

 select s.*,
 concat_ws(' ',c.firstname, c.middlename, c.lastname) as customerfullname,
 p.`unit price` as Punitprice
 from fact_internet_sales_union as s
 left join  dimcustomer as c
 on s.CustomerKey = c.customerkey
 left join dimproduct as p
 on s.ProductKey = p.ProductKey;
 
 -- (Q3  DATE QUERIES) 
 describe dimdate;
 SELECT
    s.OrderDateKey,
    d.FullDateAlternateKey AS OrderDate
FROM fact_internet_sales_union AS s
LEFT JOIN dimdate AS d
    ON s.OrderDateKey = d.DateKey
LIMIT 20;

-- (Q3 A year)
SELECT
    s.*,
    p.EnglishProductName AS ProductName,    -- (Q1)
    CONCAT_WS(' ', c.FirstName, c.MiddleName, c.LastName) AS CustomerFullName,  -- (Q2)
    p.`Unit price` AS PtUnitPrice, -- (Q2)
    d.FullDateAlternateKey AS OrderDate,
    YEAR(STR_TO_DATE(d.FullDateAlternateKey, '%m/%d/%Y')) AS Year
FROM fact_internet_sales_union AS s
LEFT JOIN dimcustomer AS c
    ON s.CustomerKey = c.CustomerKey
LEFT JOIN dimproduct AS p
    ON s.ProductKey = p.ProductKey
LEFT JOIN dimdate AS d
    ON s.OrderDateKey = d.DateKey
LIMIT 20;

-- (Q3 B Monthno)
SELECT
    s.*,
    p.EnglishProductName AS ProductName,
    CONCAT_WS(' ', c.FirstName, c.MiddleName, c.LastName) AS CustomerFullName,
    p.`Unit price` AS ProductUnitPrice,
    d.FullDateAlternateKey AS OrderDate,
    YEAR(STR_TO_DATE(d.FullDateAlternateKey, '%m/%d/%Y')) AS Year,
    MONTH(STR_TO_DATE(d.FullDateAlternateKey, '%m/%d/%Y')) AS Monthno
FROM fact_internet_sales_union AS s
LEFT JOIN dimcustomer AS c
    ON s.CustomerKey = c.CustomerKey
LEFT JOIN dimproduct AS p
    ON s.ProductKey = p.ProductKey
LEFT JOIN dimdate AS d
    ON s.OrderDateKey = d.DateKey
LIMIT 20;

-- (Q3 C Monthfullname)
SELECT
    s.*,
    p.EnglishProductName AS ProductName,
    CONCAT_WS(' ', c.FirstName, c.MiddleName, c.LastName) AS CustomerFullName,
    p.`Unit price` AS ProductUnitPrice,
    d.FullDateAlternateKey AS OrderDate,
    YEAR(STR_TO_DATE(d.FullDateAlternateKey, '%m/%d/%Y')) AS Year,
    MONTH(STR_TO_DATE(d.FullDateAlternateKey, '%m/%d/%Y')) AS Monthno,
    MONTHNAME(STR_TO_DATE(d.FullDateAlternateKey, '%m/%d/%Y')) AS Monthfullname
FROM fact_internet_sales_union AS s
LEFT JOIN dimcustomer AS c
    ON s.CustomerKey = c.CustomerKey
LEFT JOIN dimproduct AS p
    ON s.ProductKey = p.ProductKey
LEFT JOIN dimdate AS d
    ON s.OrderDateKey = d.DateKey
LIMIT 20;

-- (Q3 D Quarter)
SELECT
    s.*,
    p.EnglishProductName AS ProductName,
    CONCAT_WS(' ', c.FirstName, c.MiddleName, c.LastName) AS CustomerFullName,
    p.`Unit price` AS ProductUnitPrice,
    d.FullDateAlternateKey AS OrderDate,
    YEAR(STR_TO_DATE(d.FullDateAlternateKey, '%m/%d/%Y')) AS Year,
    MONTH(STR_TO_DATE(d.FullDateAlternateKey, '%m/%d/%Y')) AS Monthno,
    MONTHNAME(STR_TO_DATE(d.FullDateAlternateKey, '%m/%d/%Y')) AS Monthfullname,
    CONCAT('Q', QUARTER(STR_TO_DATE(d.FullDateAlternateKey, '%m/%d/%Y'))) AS Quarter
FROM fact_internet_sales_union AS s
LEFT JOIN dimcustomer AS c
    ON s.CustomerKey = c.CustomerKey
LEFT JOIN dimproduct AS p
    ON s.ProductKey = p.ProductKey
LEFT JOIN dimdate AS d
    ON s.OrderDateKey = d.DateKey
LIMIT 20;

-- (Q3 E YearMonth)
SELECT
    s.*,
    p.EnglishProductName AS ProductName,
    CONCAT_WS(' ', c.FirstName, c.MiddleName, c.LastName) AS CustomerFullName,
    p.`Unit price` AS ProductUnitPrice,
    d.FullDateAlternateKey AS OrderDate,
    YEAR(STR_TO_DATE(d.FullDateAlternateKey, '%m/%d/%Y')) AS Year,
    MONTH(STR_TO_DATE(d.FullDateAlternateKey, '%m/%d/%Y')) AS Monthno,
    MONTHNAME(STR_TO_DATE(d.FullDateAlternateKey, '%m/%d/%Y')) AS Monthfullname,
    CONCAT('Q', QUARTER(STR_TO_DATE(d.FullDateAlternateKey, '%m/%d/%Y'))) AS Quarter,
    DATE_FORMAT(
    STR_TO_DATE(d.FullDateAlternateKey, '%m/%d/%Y'),
    '%Y-%b'
) AS YearMonth
FROM fact_internet_sales_union AS s
LEFT JOIN dimcustomer AS c
    ON s.CustomerKey = c.CustomerKey
LEFT JOIN dimproduct AS p
    ON s.ProductKey = p.ProductKey
LEFT JOIN dimdate AS d
    ON s.OrderDateKey = d.DateKey
LIMIT 20;

-- (Q3 F Weekdayno)
SELECT
    s.*,
    p.EnglishProductName AS ProductName,
    CONCAT_WS(' ', c.FirstName, c.MiddleName, c.LastName) AS CustomerFullName,
    p.`Unit price` AS ProductUnitPrice,
    d.FullDateAlternateKey AS OrderDate,
    YEAR(STR_TO_DATE(d.FullDateAlternateKey, '%m/%d/%Y')) AS Year,
    MONTH(STR_TO_DATE(d.FullDateAlternateKey, '%m/%d/%Y')) AS Monthno,
    MONTHNAME(STR_TO_DATE(d.FullDateAlternateKey, '%m/%d/%Y')) AS Monthfullname,
    CONCAT('Q', QUARTER(STR_TO_DATE(d.FullDateAlternateKey, '%m/%d/%Y'))) AS Quarter,
    DATE_FORMAT(
    STR_TO_DATE(d.FullDateAlternateKey, '%m/%d/%Y'),
    '%Y-%b'
) AS YearMonth,
WEEKDAY(STR_TO_DATE(d.FullDateAlternateKey, '%m/%d/%Y')) + 1 AS Weekdayno
FROM fact_internet_sales_union AS s
LEFT JOIN dimcustomer AS c
    ON s.CustomerKey = c.CustomerKey
LEFT JOIN dimproduct AS p
    ON s.ProductKey = p.ProductKey
LEFT JOIN dimdate AS d
    ON s.OrderDateKey = d.DateKey
LIMIT 20;

-- (Q3 G Weekdayname)
SELECT
    s.*,
    p.EnglishProductName AS ProductName,
    CONCAT_WS(' ', c.FirstName, c.MiddleName, c.LastName) AS CustomerFullName,
    p.`Unit price` AS ProductUnitPrice,
    d.FullDateAlternateKey AS OrderDate,
    YEAR(STR_TO_DATE(d.FullDateAlternateKey, '%m/%d/%Y')) AS Year,
    MONTH(STR_TO_DATE(d.FullDateAlternateKey, '%m/%d/%Y')) AS Monthno,
    MONTHNAME(STR_TO_DATE(d.FullDateAlternateKey, '%m/%d/%Y')) AS Monthfullname,
    CONCAT('Q', QUARTER(STR_TO_DATE(d.FullDateAlternateKey, '%m/%d/%Y'))) AS Quarter,
    DATE_FORMAT(
    STR_TO_DATE(d.FullDateAlternateKey, '%m/%d/%Y'),
    '%Y-%b'
) AS YearMonth,
WEEKDAY(STR_TO_DATE(d.FullDateAlternateKey, '%m/%d/%Y')) + 1 AS Weekdayno,
DAYNAME(STR_TO_DATE(d.FullDateAlternateKey, '%m/%d/%Y')) AS Weekdayname
FROM fact_internet_sales_union AS s
LEFT JOIN dimcustomer AS c
    ON s.CustomerKey = c.CustomerKey
LEFT JOIN dimproduct AS p
    ON s.ProductKey = p.ProductKey
LEFT JOIN dimdate AS d
    ON s.OrderDateKey = d.DateKey
LIMIT 20;

-- (Q3 H FinancialMonth)
SELECT
    s.*,
    p.EnglishProductName AS ProductName,
    CONCAT_WS(' ', c.FirstName, c.MiddleName, c.LastName) AS CustomerFullName,
    p.`Unit price` AS ProductUnitPrice,
    d.FullDateAlternateKey AS OrderDate,
    YEAR(STR_TO_DATE(d.FullDateAlternateKey, '%m/%d/%Y')) AS Year,
    MONTH(STR_TO_DATE(d.FullDateAlternateKey, '%m/%d/%Y')) AS Monthno,
    MONTHNAME(STR_TO_DATE(d.FullDateAlternateKey, '%m/%d/%Y')) AS Monthfullname,
    CONCAT('Q', QUARTER(STR_TO_DATE(d.FullDateAlternateKey, '%m/%d/%Y'))) AS Quarter,
    DATE_FORMAT(
    STR_TO_DATE(d.FullDateAlternateKey, '%m/%d/%Y'),
    '%Y-%b'
) AS YearMonth,
WEEKDAY(STR_TO_DATE(d.FullDateAlternateKey, '%m/%d/%Y')) + 1 AS Weekdayno,
DAYNAME(STR_TO_DATE(d.FullDateAlternateKey, '%m/%d/%Y')) AS Weekdayname,
MOD(
    MONTH(STR_TO_DATE(d.FullDateAlternateKey, '%m/%d/%Y')) - 4 + 12,
    12
) + 1 AS FinancialMonth
FROM fact_internet_sales_union AS s
LEFT JOIN dimcustomer AS c
    ON s.CustomerKey = c.CustomerKey
LEFT JOIN dimproduct AS p
    ON s.ProductKey = p.ProductKey
LEFT JOIN dimdate AS d
    ON s.OrderDateKey = d.DateKey
LIMIT 20;

-- (Q3 I Financial Quarter)
SELECT
    s.*,
    p.EnglishProductName AS ProductName,
    CONCAT_WS(' ', c.FirstName, c.MiddleName, c.LastName) AS CustomerFullName,
    p.`Unit price` AS ProductUnitPrice,
    d.FullDateAlternateKey AS OrderDate,
    YEAR(STR_TO_DATE(d.FullDateAlternateKey, '%m/%d/%Y')) AS Year,
    MONTH(STR_TO_DATE(d.FullDateAlternateKey, '%m/%d/%Y')) AS Monthno,
    MONTHNAME(STR_TO_DATE(d.FullDateAlternateKey, '%m/%d/%Y')) AS Monthfullname,
    CONCAT('Q', QUARTER(STR_TO_DATE(d.FullDateAlternateKey, '%m/%d/%Y'))) AS Quarter,
    DATE_FORMAT(
    STR_TO_DATE(d.FullDateAlternateKey, '%m/%d/%Y'),
    '%Y-%b'
) AS YearMonth,
WEEKDAY(STR_TO_DATE(d.FullDateAlternateKey, '%m/%d/%Y')) + 1 AS Weekdayno,
DAYNAME(STR_TO_DATE(d.FullDateAlternateKey, '%m/%d/%Y')) AS Weekdayname,
MOD(
    MONTH(STR_TO_DATE(d.FullDateAlternateKey, '%m/%d/%Y')) - 4 + 12,
    12
) + 1 AS FinancialMonth,
CONCAT(
    'FQ',
    CEIL(
        (
            MOD(
                MONTH(STR_TO_DATE(d.FullDateAlternateKey, '%m/%d/%Y')) - 4 + 12,
                12
            ) + 1
        ) / 3
    )
) AS FinancialQuarter
FROM fact_internet_sales_union AS s
LEFT JOIN dimcustomer AS c
    ON s.CustomerKey = c.CustomerKey
LEFT JOIN dimproduct AS p
    ON s.ProductKey = p.ProductKey
LEFT JOIN dimdate AS d
    ON s.OrderDateKey = d.DateKey
LIMIT 20;


-- (Q4 calculate sales amount \ Q5 production cost \ Q6 Profit)
SELECT
    s.*,
    p.EnglishProductName AS ProductName,
    CONCAT_WS(' ', c.FirstName, c.MiddleName, c.LastName) AS CustomerFullName,
    p.`Unit price` AS ProductUnitPrice,
    d.FullDateAlternateKey AS OrderDate,
    YEAR(STR_TO_DATE(d.FullDateAlternateKey, '%m/%d/%Y')) AS Year,
    MONTH(STR_TO_DATE(d.FullDateAlternateKey, '%m/%d/%Y')) AS Monthno,
    MONTHNAME(STR_TO_DATE(d.FullDateAlternateKey, '%m/%d/%Y')) AS Monthfullname,
    CONCAT('Q', QUARTER(STR_TO_DATE(d.FullDateAlternateKey, '%m/%d/%Y'))) AS Quarter,
    DATE_FORMAT(
    STR_TO_DATE(d.FullDateAlternateKey, '%m/%d/%Y'),
    '%Y-%b'
) AS YearMonth,
WEEKDAY(STR_TO_DATE(d.FullDateAlternateKey, '%m/%d/%Y')) + 1 AS Weekdayno,
DAYNAME(STR_TO_DATE(d.FullDateAlternateKey, '%m/%d/%Y')) AS Weekdayname,
MOD(
    MONTH(STR_TO_DATE(d.FullDateAlternateKey, '%m/%d/%Y')) - 4 + 12,
    12
) + 1 AS FinancialMonth,
CONCAT(
    'FQ',
    CEIL(
        (
            MOD(
                MONTH(STR_TO_DATE(d.FullDateAlternateKey, '%m/%d/%Y')) - 4 + 12,
                12
            ) + 1
        ) / 3
    )
) AS FinancialQuarter,
s.UnitPrice * s.OrderQuantity * (1 - s.UnitPriceDiscountPct) AS CalculatedSalesAmount, -- (Q4 Sales amount)
s.ProductStandardCost * s.OrderQuantity AS ProductionCost, -- (Q5 production cost)
(
    s.UnitPrice * s.OrderQuantity * (1 - s.UnitPriceDiscountPct)
) - (
    s.ProductStandardCost * s.OrderQuantity
) AS Profit  -- (Q6)
FROM fact_internet_sales_union AS s
LEFT JOIN dimcustomer AS c
    ON s.CustomerKey = c.CustomerKey
LEFT JOIN dimproduct AS p
    ON s.ProductKey = p.ProductKey
LEFT JOIN dimdate AS d
    ON s.OrderDateKey = d.DateKey
LIMIT 20;

-- (Q7 year\ Month wise sales)

SELECT
    YEAR(STR_TO_DATE(d.FullDateAlternateKey, '%m/%d/%Y')) AS Year,
    MONTH(STR_TO_DATE(d.FullDateAlternateKey, '%m/%d/%Y')) AS Monthno,
    MONTHNAME(STR_TO_DATE(d.FullDateAlternateKey, '%m/%d/%Y')) AS Monthfullname,
    SUM(
        s.UnitPrice * s.OrderQuantity * (1 - s.UnitPriceDiscountPct)
    ) AS TotalSales
FROM fact_internet_sales_union AS s
LEFT JOIN dimdate AS d
    ON s.OrderDateKey = d.DateKey
GROUP BY
    YEAR(STR_TO_DATE(d.FullDateAlternateKey, '%m/%d/%Y')),
    MONTH(STR_TO_DATE(d.FullDateAlternateKey, '%m/%d/%Y')),
    MONTHNAME(STR_TO_DATE(d.FullDateAlternateKey, '%m/%d/%Y'))
ORDER BY
    Year,
    Monthno;
    
-- (Q8) Year wise sales
SELECT
    YEAR(STR_TO_DATE(d.FullDateAlternateKey, '%m/%d/%Y')) AS Year,
    ROUND(
        SUM(
            s.UnitPrice * s.OrderQuantity * (1 - s.UnitPriceDiscountPct)
        ),
        2
    ) AS TotalSales
FROM fact_internet_sales_union AS s
LEFT JOIN dimdate AS d
    ON s.OrderDateKey = d.DateKey
GROUP BY
    YEAR(STR_TO_DATE(d.FullDateAlternateKey, '%m/%d/%Y'))
ORDER BY
    Year;

-- (Q9 Month wise sales )   
SELECT
    DATE_FORMAT(
        STR_TO_DATE(d.FullDateAlternateKey, '%m/%d/%Y'),
        '%Y-%b'
    ) AS YearMonth,
    ROUND(
        SUM(
            s.UnitPrice * s.OrderQuantity * (1 - s.UnitPriceDiscountPct)
        ),
        2
    ) AS TotalSales
FROM fact_internet_sales_union AS s
LEFT JOIN dimdate AS d
    ON s.OrderDateKey = d.DateKey
GROUP BY
    YEAR(STR_TO_DATE(d.FullDateAlternateKey, '%m/%d/%Y')),
    MONTH(STR_TO_DATE(d.FullDateAlternateKey, '%m/%d/%Y')),
    DATE_FORMAT(
        STR_TO_DATE(d.FullDateAlternateKey, '%m/%d/%Y'),
        '%Y-%b'
    )
ORDER BY
    YEAR(STR_TO_DATE(d.FullDateAlternateKey, '%m/%d/%Y')),
    MONTH(STR_TO_DATE(d.FullDateAlternateKey, '%m/%d/%Y')); 
    
-- (Q10  Quarter-wise Sales)
SELECT
    Quarter,
    ROUND(SUM(
        UnitPrice * OrderQuantity * (1 - UnitPriceDiscountPct)
    ), 2) AS TotalSales
FROM (
    SELECT
        s.UnitPrice,
        s.OrderQuantity,
        s.UnitPriceDiscountPct,
        CONCAT(
            'Q',
            QUARTER(STR_TO_DATE(d.FullDateAlternateKey, '%m/%d/%Y'))
        ) AS Quarter,
        QUARTER(STR_TO_DATE(d.FullDateAlternateKey, '%m/%d/%Y')) AS QuarterNo
    FROM fact_internet_sales_union AS s
    LEFT JOIN dimdate AS d
        ON s.OrderDateKey = d.DateKey
) AS sales_data
GROUP BY
    Quarter,
    QuarterNo
ORDER BY
    QuarterNo;
    
    
-- (Q11 Compare Total_sales and total_production_cost)
SELECT
    YEAR(STR_TO_DATE(d.FullDateAlternateKey, '%m/%d/%Y')) AS Year,
    
    ROUND(
        SUM(
            s.UnitPrice * s.OrderQuantity * (1 - s.UnitPriceDiscountPct)
        ),
        2
    ) AS TotalSales,
    
    ROUND(
        SUM(
            s.ProductStandardCost * s.OrderQuantity
        ),
        2
    ) AS TotalProductionCost

FROM fact_internet_sales_union AS s

LEFT JOIN dimdate AS d
    ON s.OrderDateKey = d.DateKey

GROUP BY
    YEAR(STR_TO_DATE(d.FullDateAlternateKey, '%m/%d/%Y'))

ORDER BY
    Year;    
    
-- (Q12 A Product-wise Sales)
SELECT
    p.EnglishProductName AS ProductName,
    ROUND(
        SUM(
            s.UnitPrice * s.OrderQuantity * (1 - s.UnitPriceDiscountPct)
        ),
        2
    ) AS TotalSales
FROM fact_internet_sales_union AS s
LEFT JOIN dimproduct AS p
    ON s.ProductKey = p.ProductKey
GROUP BY
    p.ProductKey,
    p.EnglishProductName
ORDER BY
    TotalSales DESC;    

-- (Q12 B Customer-wise Sales)
SELECT
    s.CustomerKey,
    CONCAT_WS(' ', c.FirstName, c.MiddleName, c.LastName) AS CustomerFullName,
    ROUND(
        SUM(
            s.UnitPrice * s.OrderQuantity * (1 - s.UnitPriceDiscountPct)
        ),
        2
    ) AS TotalSales
FROM fact_internet_sales_union AS s
LEFT JOIN dimcustomer AS c
    ON s.CustomerKey = c.CustomerKey
GROUP BY
    s.CustomerKey,
    c.FirstName,
    c.MiddleName,
    c.LastName
ORDER BY
    TotalSales DESC;
    
-- (Q12 C  Region-wise Sales)  
SELECT
    t.SalesTerritoryRegion AS Region,
    ROUND(
        SUM(
            s.UnitPrice * s.OrderQuantity * (1 - s.UnitPriceDiscountPct)
        ),
        2
    ) AS TotalSales
FROM fact_internet_sales_union AS s
LEFT JOIN dimsalesterritory AS t
    ON s.SalesTerritoryKey = t.SalesTerritoryKey
GROUP BY
    t.SalesTerritoryRegion
ORDER BY
    TotalSales DESC;
    
    
-- (Q13 Total Sales, Total Production cost, Total Profit, Total Quantity)
SELECT
    ROUND(
        SUM(
            UnitPrice * OrderQuantity * (1 - UnitPriceDiscountPct)
        ), 2
    ) AS TotalSales,

    ROUND(
        SUM(
            ProductStandardCost * OrderQuantity
        ), 2
    ) AS TotalProductionCost,

    ROUND(
        SUM(
            (UnitPrice * OrderQuantity * (1 - UnitPriceDiscountPct))
            - (ProductStandardCost * OrderQuantity)
        ), 2
    ) AS TotalProfit,

    SUM(OrderQuantity) AS TotalQuantity

FROM fact_internet_sales_union;    