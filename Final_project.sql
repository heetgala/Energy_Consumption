use Final_project
ALTER TABLE rates
DROP CONSTRAINT PK_Rates;

-- Add a new primary key constraint to the rates table
ALTER TABLE rates
ADD CONSTRAINT PK_Rates
PRIMARY KEY (Year, Month, Category);

ALTER TABLE business_2
ADD CONSTRAINT FK_BusinessEnergy_Rates
FOREIGN KEY (year, month, category)
REFERENCES rates(Year, Month, Category);

ALTER TABLE small_commercials
ADD CONSTRAINT FK_small_commercials_Energy_Rates
FOREIGN KEY (year, month, category)
REFERENCES rates(Year, Month, Category);

ALTER TABLE residents
ADD CONSTRAINT FK_ResidentsEnergy_Rates
FOREIGN KEY (year, month, category)
REFERENCES rates(Year, Month, Category);


SELECT
    b.year,
    b.month,
    b.zip_code,
    b.consumption_MW,
    b.number_of_accounts,
    r.Price,
    b.consumption_MW * r.Price AS CalculatedPrice,
	r.category
FROM
    business_2 b
JOIN
    rates r ON b.year = r.Year AND b.month = r.Month AND b.category = r.Category
ORDER BY
    b.year, b.month, b.zip_code;


---Total consumption by each sector
SELECT
    year,
    'business' AS category,
    SUM(consumption_MW) AS TotalEnergy
FROM
    business_2
GROUP BY
    year

	Union ALL

SELECT
    year,
    'residents' AS category,
    SUM(consumption_MW) AS TotalEnergy
FROM
    residents
GROUP BY
    year

Union ALL

SELECT
    year,
    'small business' AS category,
    SUM(consumption_MW) AS TotalEnergy
FROM
    small_commercials
GROUP BY
    year
ORDER BY
    year, category;
 
 ---
SELECT TOP 10
    b.zip_code,
    SUM(b.consumption_MW) AS TotalConsumption,
    p.Population
FROM
    residents b
JOIN
    population_2 p ON b.zip_code = p.zipcode
GROUP BY
    b.zip_code, p.Population
ORDER BY
    TotalConsumption DESC;

---Q8
WITH RankedZipCodes AS (
    SELECT
        year,
        zip_code,
        SUM(consumption_MW) AS TotalConsumption,
        ROW_NUMBER() OVER (PARTITION BY year ORDER BY SUM(consumption_MW) DESC) AS RowNum
    FROM
        business_2
    GROUP BY
        year, zip_code
)
SELECT
    year,
    zip_code,
    TotalConsumption
FROM
    RankedZipCodes
WHERE
    RowNum <= 10
ORDER BY
    year, TotalConsumption DESC;

---
SELECT TOP 1
    zip_code,
    SUM(consumption_MW) AS TotalConsumption
FROM
    business_2
GROUP BY
    zip_code
ORDER BY
    TotalConsumption DESC;

SELECT TOP 1
    zip_code,
    SUM(consumption_MW) AS TotalConsumption
FROM
    business_2
GROUP BY
    zip_code
ORDER BY
    TotalConsumption ASC;

---- price for all
SELECT
    b.year,
    b.month,
    r.category,
    SUM(b.consumption_MW) AS TotalConsumption,
    SUM(b.consumption_MW * r.Price) AS TotalCalculatedPrice
FROM
    business_2 b
JOIN
    rates r ON b.year = r.Year AND b.month = r.Month AND b.category = r.Category
GROUP BY
    b.year, b.month, r.category

UNION ALL

SELECT
    b.year,
    b.month,
    r.category,
    SUM(b.consumption_MW) AS TotalConsumption,
    SUM(b.consumption_MW * r.Price) AS TotalCalculatedPrice
FROM
    residents b
JOIN
    rates r ON b.year = r.Year AND b.month = r.Month AND b.category = r.Category
GROUP BY
    b.year, b.month, r.category

UNION ALL

SELECT
    b.year,
    b.month,
    r.category,
    SUM(b.consumption_MW) AS TotalConsumption,
    SUM(b.consumption_MW * r.Price) AS TotalCalculatedPrice
FROM
    small_commercials b
JOIN
    rates r ON b.year = r.Year AND b.month = r.Month AND b.category = r.Category
GROUP BY
    b.year, b.month, r.category
ORDER BY
    year, month, category;



---
WITH RankedZipCodes AS (
    SELECT
        b.year,
        b.zip_code,
        SUM(b.consumption_MW) AS TotalConsumption,
        SUM(b.consumption_MW * r.Price) AS TotalRevenue,
        ROW_NUMBER() OVER (PARTITION BY b.year ORDER BY SUM(b.consumption_MW * r.Price) DESC) AS RowNum
    FROM
        business_2 b
    JOIN
        rates r ON b.year = r.Year AND b.month = r.Month AND b.category = r.Category
    GROUP BY
        b.year, b.zip_code
)

SELECT
    year,
    zip_code,
    TotalConsumption,
    TotalRevenue
FROM
    RankedZipCodes
WHERE
    RowNum <= 10
ORDER BY
    year, TotalRevenue DESC, zip_code;


---
WITH RankedZipCodes AS (
    SELECT
        b.year,
        b.zip_code,
        SUM(b.consumption_MW) AS TotalConsumption,
        SUM(b.consumption_MW * r.Price) AS TotalRevenue,
        ROW_NUMBER() OVER (PARTITION BY b.year ORDER BY SUM(b.consumption_MW * r.Price) DESC) AS RowNum
    FROM
        residents b
    JOIN
        rates r ON b.year = r.Year AND b.month = r.Month AND b.category = r.Category
    GROUP BY
        b.year, b.zip_code
)

SELECT
    year,
    zip_code,
    TotalConsumption,
    TotalRevenue
FROM
    RankedZipCodes
WHERE
    RowNum <= 10
ORDER BY
    year, TotalRevenue DESC, zip_code;


	---
WITH RankedZipCodes AS (
    SELECT
        b.year,
        b.zip_code,
        SUM(b.consumption_MW) AS TotalConsumption,
        SUM(b.consumption_MW * r.Price) AS TotalRevenue,
        ROW_NUMBER() OVER (PARTITION BY b.year ORDER BY SUM(b.consumption_MW * r.Price) DESC) AS RowNum
    FROM
        small_commercials b
    JOIN
        rates r ON b.year = r.Year AND b.month = r.Month AND b.category = r.Category
    GROUP BY
        b.year, b.zip_code
)

SELECT
    year,
    TotalConsumption,
    TotalRevenue
FROM
    RankedZipCodes
WHERE
    RowNum <= 10
ORDER BY
    year, TotalRevenue DESC, zip_code;

---
WITH RankedCities AS (
    SELECT
        b.year,
        p.city,
        SUM(b.consumption_MW) AS TotalConsumption,
        SUM(b.consumption_MW * r.Price) AS TotalRevenue,
        ROW_NUMBER() OVER (PARTITION BY b.year ORDER BY SUM(b.consumption_MW * r.Price) DESC) AS RowNum
    FROM
        residents b
    JOIN
        rates r ON b.year = r.Year AND b.month = r.Month AND b.category = r.Category
    JOIN
        population_2 p ON b.zip_code = p.zipcode -- Assuming there's a zip_code column in the population table
    GROUP BY
        b.year, p.city
)

SELECT
    year,
    city,
    TotalConsumption,
    TotalRevenue
FROM
    RankedCities
WHERE
    RowNum <= 10
ORDER BY
    year, TotalRevenue DESC, city;

---
SELECT 
    Year,
    Bioenergy,
    Coal,
    Natural_Gas,
    Net_Imported_Electricity,
    Nuclear,
    Petroleum_Products,
    Pumped_Storage_Hydro,
    Renewables
FROM elec_generation;


SELECT 
    Year,
    Renewables,
    LAG(Renewables) OVER (ORDER BY Year) AS PreviousYearRenewables,
    ((Renewables - LAG(Renewables) OVER (ORDER BY Year)) / LAG(Renewables) OVER (ORDER BY Year)) * 100 AS PercentageChange
FROM elec_generation;

SELECT number_of_accounts, consumption_MW
FROM dbo.business_2;

SELECT number_of_accounts, consumption_MW
FROM dbo.residents;

SELECT
    number_of_accounts,
    consumption_MW,
    r.Price,
    consumption_MW * r.Price AS Revenue
FROM
    dbo.business_2 s
JOIN
    rates r ON s.year = r.Year AND s.month = r.Month AND s.category = r.Category;