use traningYa
GO

SELECT * FROM AppleCase

--  total number of customers

SELECT count(DISTINCT [customer_id]) as total_customers FROM AppleCase

-- total revanue

SELECT sum(Revenue) as r FROM AppleCase

-- total products

SELECT Count(DISTINCT [Product])  as total_products from AppleCase

--  total target

SELECT sum([Target])  as target FROM AppleCase

-- total sold unit

SELECT sum(Unit_Sold) as unit_sold FROM  AppleCase


-- product wise total revanue

SELECT Product,sum(Revenue) as totalsales FROM AppleCase
GROUP BY [Product]
ORDER by totalsales


--  country wise total revanue

SELECT Country,sum(Revenue) as totalsales from AppleCase
GROUP BY Country

--  channel wise total revanue

SELECT Channel,sum(Revenue) as totalsales FROM AppleCase
GROUP BY Channel
ORDER by totalsales


-- region wise total revanue

SELECT Region,sum(Revenue) as totalsales FROM AppleCase
GROUP BY Region
ORDER BY totalsales

-- user type total revanue

SELECT User_Type,sum(Revenue) as totalsales FROM AppleCase
GROUP BY User_Type
ORDER by totalsales


-- migrate wise total revanue

SELECT Migrate,sum(Revenue) as totalsales FROM AppleCase
GROUP BY Migrate
ORDER BY  totalsales

-- top 5 country wise total revanue

WITH ct1 as (
    SELECT Country,sum(Revenue) as totalsales FROM  AppleCase
    GROUP BY Country
),
ct2 as (
    SELECT *,ROW_NUMBER() OVER(PARTITION BY country ORDER BY totalsales desc) as rk FROM ct1
)
SELECT * FROM ct2
WHERE rk<=5


-- country wise contribution


SELECT Country,sum(Revenue) as totalsales,sum(Revenue)*100.0/(
    SELECT sum(Revenue)  from AppleCase
) as contribution FROM AppleCase
GROUP BY Country
ORDER by contribution DESC

--  product wise contribution


SELECT Product,sum(Revenue) as totalsales,sum(Revenue)*100.0/(
    SELECT sum(Revenue) FROM AppleCase
)as contribution FROM AppleCase
GROUP BY Product
ORDER by contribution DESC


-- country target achived or not


SELECT Country,sum(revenue) as totalsales,sum([Target]) as target, abs(sum(revenue)-sum(target)) as PendingTarget,
CASE 
    WHEN sum(revenue)>=sum(target) THEN  'Target Achived'
    ELSE  'not Achived'
END as Flag FROM AppleCase
GROUP BY Country


-- channer wise total revanue to check if target is achived or not


SELECT channel,sum(Revenue) as totalsales,sum([Target]) as target,abs(sum(revenue)-sum(target)) as PendingTarget,
CASE 
    WHEN sum(Revenue)>=sum([Target]) THEN  'target achived'
    ELSE  'not achived'
END as Flag FROM AppleCase
GROUP BY Channel



-- product wise total revanue and target

SELECT Product,sum(Revenue) as AchivedRevanue,sum([Target]) as Target,abs(sum
(Revenue)-sum([Target]) )as PendingTarget ,
CASE 
    WHEN sum(Revenue)>=sum([Target]) THEN  'target Achived'
    ELSE  'not Achived'
END as Flag
from AppleCase
GROUP BY Product



-- top 5 customer based on revanue


with ct1 as (
    SELECT customer_id,sum(Revenue) as totalsales FROM AppleCase
    GROUP BY customer_id
),
ct2 as (
    SELECT *,ROW_NUMBER() OVER(ORDER BY totalsales desc) as rk FROM ct1
)
SELECT * FROM ct2
WHERE rk<=5


-- regional channer sales 

WITH RevenuePivot AS
(
    SELECT Channel, [ASIA], [EMEA], [USA]
    FROM
    (
        SELECT
            Region,
            Channel,
            SUM(Revenue) AS TotalSales
        FROM AppleCase
        GROUP BY Region, Channel
    ) AS X
    PIVOT
    (
        SUM(TotalSales)
        FOR Region IN ([ASIA], [EMEA], [USA])
    ) AS P
),
TargetPivot AS
(
    SELECT Channel, [ASIA], [EMEA], [USA]
    FROM
    (
        SELECT
            Region,
            Channel,
            SUM(Target) AS TotalTarget
        FROM AppleCase
        GROUP BY Region, Channel
    ) AS X
    PIVOT
    (
        SUM(TotalTarget)
        FOR Region IN ([ASIA], [EMEA], [USA])
    ) AS P
)
SELECT
    R.Channel,
    R.[ASIA] AS AsiaRevenue,
    R.[EMEA] AS EmeaRevenue,
    R.[USA] AS UsaRevenue,
    ISNULL(R.[ASIA],0) +
    ISNULL(R.[EMEA],0) +
    ISNULL(R.[USA],0) AS RevenueGrandTotal,

    T.[ASIA] AS AsiaTarget,
    T.[EMEA] AS EmeaTarget,
    T.[USA] AS UsaTarget,
    ISNULL(T.[ASIA],0) +
    ISNULL(T.[EMEA],0) +
    ISNULL(T.[USA],0) AS TargetGrandTotal
FROM RevenuePivot R
JOIN TargetPivot T
    ON R.Channel = T.Channel;


--  user type regional total revanue


WITH Region_usertype AS (
    SELECT 
        User_Type,
        ISNULL([ASIA], 0) AS [ASIA],
        ISNULL([EMEA], 0) AS [EMEA],
        ISNULL([USA], 0)  AS [USA],
        ISNULL([ASIA], 0) + ISNULL([EMEA], 0) + ISNULL([USA], 0) AS Grandtotal
    FROM (
        SELECT Region, User_Type, SUM(Revenue) AS totalsales
        FROM AppleCase
        GROUP BY Region, User_Type
    ) AS x
    PIVOT (
        SUM(totalsales)
        FOR Region IN ([ASIA], [EMEA], [USA])
    ) AS p
),
region_grandtotal AS (
    SELECT 
        ISNULL([ASIA], 0) AS [ASIA],
        ISNULL([EMEA], 0) AS [EMEA],
        ISNULL([USA], 0)  AS [USA],
        ISNULL([ASIA], 0) + ISNULL([EMEA], 0) + ISNULL([USA], 0) AS Grandtotal
    FROM (
        SELECT Region, SUM(Revenue) AS totalsales
        FROM AppleCase
        GROUP BY Region
    ) AS x
    PIVOT (
        SUM(totalsales)
        FOR Region IN ([ASIA], [EMEA], [USA])
    ) AS p
)
SELECT User_Type, [ASIA], [EMEA], [USA], Grandtotal
FROM Region_usertype

UNION ALL

SELECT 'Grand Total', [ASIA], [EMEA], [USA], Grandtotal
FROM region_grandtotal;


-- summary of country 

SELECT country,sum(revenue) as totalSales,sum(target) as target,abs(sum(revenue)-sum(target)) as PendingTarget,sum(Unit_sold) as Sold_unit FROM AppleCase
GROUP BY country


-- summary of Region

SELECT region,sum(revenue) as totalSales,sum(target) as target,abs(sum(revenue)-sum(target)) as PendingTarget,sum(Unit_sold) as Sold_unit FROM AppleCase
GROUP BY region

-- summary of channel

SELECT channel,sum(revenue) as totalSales,sum(target) as target,abs(sum(revenue)-sum(target)) as PendingTarget,sum(Unit_sold) as Sold_unit FROM AppleCase
GROUP BY channel

-- user type summary
SELECT user_type,sum(revenue) as totalSales,sum(target) as target,abs(sum(revenue)-sum(target)) as PendingTarget,sum(Unit_sold) as Sold_unit FROM AppleCase
GROUP BY user_type

-- summary of customer 

SELECT customer_id,sum(revenue) as totalSales,sum(target) as target,abs(sum(revenue)-sum(target)) as PendingTarget,sum(Unit_sold) as Sold_unit FROM AppleCase
GROUP BY customer_id
ORDER BY totalsales DESC

-- summary of product

SELECT product,sum(revenue) as totalSales,sum(target) as target,sum(revenue)-sum(target) as TargetStatus,sum(Unit_sold) as Sold_unit FROM AppleCase
GROUP BY product

-- migrate summary

SELECT migrate,sum(revenue) as totalSales,sum(price) as price,sum(target) as target,sum(revenue)-sum(target) as TargetStatus,sum(Unit_sold) as Sold_unit,CASE 
    WHEN sum(revenue)>=sum(target) THEN  'Achived'
    ELSE  'Not-Achived'
END as Flag FROM AppleCase
GROUP BY migrate


-- apple purchased  product summary

SELECT Apple_product_purchased,sum(revenue) as totalSales,sum(price) as price,sum(target) as target,sum(revenue)-sum(target) as TargetStatus,sum(Unit_sold) as Sold_unit,
CASE 
    WHEN sum(revenue)>=sum(target) THEN  'Achived'
    ELSE  'Not-Achived'
END as Flag FROM AppleCase
GROUP BY Apple_product_purchased




-- yearly  regional revanue




WITH YearGrandtotal AS (
    SELECT 
        CAST([year] AS VARCHAR(20)) AS [year],
        ISNULL([ASIA], 0) AS [ASIA],
        ISNULL([EMEA], 0) AS [EMEA],
        ISNULL([USA], 0)  AS [USA],
        ISNULL([ASIA], 0) + ISNULL([EMEA], 0) + ISNULL([USA], 0) AS Grandtotal
    FROM (
        SELECT region, YEAR(order_date) AS [year], SUM(revenue) AS totalsales
        FROM AppleCase
        GROUP BY region, YEAR(order_date)
    ) AS x
    PIVOT (
        SUM(totalsales)
        FOR region IN ([ASIA], [EMEA], [USA])
    ) AS p
),
RegionGrandtotal AS (
    SELECT 
        ISNULL([ASIA], 0) AS [ASIA],
        ISNULL([EMEA], 0) AS [EMEA],
        ISNULL([USA], 0)  AS [USA],
        ISNULL([ASIA], 0) + ISNULL([EMEA], 0) + ISNULL([USA], 0) AS Grandtotal
    FROM (
        SELECT region, SUM(revenue) AS totalsales
        FROM AppleCase
        GROUP BY region
    ) AS x
    PIVOT (
        SUM(totalsales)
        FOR region IN ([ASIA], [EMEA], [USA])
    ) AS p
)
SELECT [year], [ASIA], [EMEA], [USA], Grandtotal
FROM YearGrandtotal

UNION ALL

SELECT 'Grand Total', [ASIA], [EMEA], [USA], Grandtotal
FROM RegionGrandtotal;



