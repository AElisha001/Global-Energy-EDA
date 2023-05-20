/*
Energy Data Exploration

Skills used: Joins, Aggregate Functions, Creating Views, Converting Data Types

*/
SELECT *
FROM [energy-biofuel] 

-- How much Biofuel is consumed per person in a Country (per capita consumption)?

SELECT YEAR,
       country,
       biofuel_cons_per_capita
FROM [energy-biofuel]
WHERE biofuel_cons_per_capita IS NOT NULL
  AND CONVERT(float, biofuel_cons_per_capita) > 0
ORDER BY CONVERT(float, biofuel_cons_per_capita) DESC 

-- We will modify the above query by grouping on Year and Country, and computing the total per capita consumption to see the country having the highest per capita Biofuel consumption

SELECT country,
       SUM(CONVERT(float, biofuel_cons_per_capita)) AS TotalPerCapitaConsumption
FROM [energy-biofuel]
WHERE biofuel_cons_per_capita IS NOT NULL
  AND CONVERT(float, biofuel_cons_per_capita) > 0
GROUP BY country
ORDER BY TotalPerCapitaConsumption DESC 

-- How much Biofuel is consumed per Country?

SELECT country,
       SUM(biofuel_consumption) AS TotalBiofuelConsumption
FROM [energy-biofuel]
GROUP BY country
HAVING SUM(biofuel_consumption) IS NOT NULL
ORDER BY TotalBiofuelConsumption DESC 

-- Next we find out which country generates the highest Biofuel-Electricity?

SELECT country,
       SUM(biofuel_electricity) AS TotalBiofuelElectricityGeneration
FROM [energy-biofuel]
GROUP BY country
HAVING SUM(biofuel_electricity) IS NOT NULL
ORDER BY TotalBiofuelElectricityGeneration DESC 

-- Country with the Highest Total per capita electricity demand

SELECT el.country,
       SUM(el.electricity_demand)/SUM(bio.population) AS PerCapitaElectricityDemand
FROM [energy-electricity] el
JOIN [energy-biofuel] bio ON el.country = bio.country
AND el.year = bio.year
WHERE (el.electricity_demand/bio.population) IS NOT NULL
GROUP BY el.country
ORDER BY PerCapitaElectricityDemand DESC 

-- Which country has the Highest per capita energy consumption?

SELECT SUM(En.TotalPerCapitaEnergy) AS SumOfPerCapitaEnergy
FROM
  (SELECT country,
          SUM(energy_per_capita) AS TotalPerCapitaEnergy
   FROM [energy-electricity]
   GROUP BY country
   HAVING SUM(energy_per_capita) IS NOT NULL --ORDER BY TotalPerCapitaEnergy DESC
) AS En 

-- CREATING a View for later visualization of dataset

CREATE VIEW EnergyConsumption AS
SELECT country,
       SUM(energy_per_capita) AS TotalPerCapitaEnergy,
       SUM(energy_per_gdp) AS TotalPerGDPEnergy
FROM [energy-electricity]
GROUP BY country
HAVING SUM(energy_per_capita) IS NOT NULL
AND SUM(energy_per_gdp) IS NOT NULL 
--ORDER BY TotalPerCapitaEnergy DESC, TotalPerGDPEnergy DESC

-- Country leading in Biofuel, Electricity and Solar Energy Production

SELECT bio.country,
       SUM(biofuel_electricity) AS TotalBiofuelElect,
       SUM(electricity_generation) AS TotalElectGeneration,
       SUM(solar_electricity) AS TotalSolarGeneration
FROM [energy-biofuel] bio
JOIN [energy-electricity] elec ON bio.country = elec.country
AND bio.year = elec.year
JOIN [energy-solar] sol ON bio.country = sol.country
AND bio.year = sol.year
GROUP BY bio.country
HAVING SUM(biofuel_electricity) IS NOT NULL
AND SUM(electricity_generation) IS NOT NULL
AND SUM(solar_electricity) IS NOT NULL
ORDER BY SUM(biofuel_electricity) DESC, SUM(electricity_generation) DESC, SUM(solar_electricity) DESC 

-- Countries, Biofuel and Solar consumption

SELECT bio.country,
       SUM(biofuel_consumption) AS TotalBiofuelConsumption,
       SUM(solar_consumption) AS TotalSolarConsumption
FROM [energy-biofuel] bio
JOIN [energy-solar] sol ON bio.country = sol.country
AND bio.year = sol.year
GROUP BY bio.country
HAVING SUM(biofuel_consumption) IS NOT NULL
AND SUM(solar_consumption) IS NOT NULL
ORDER BY SUM(biofuel_consumption) DESC, SUM(solar_consumption) DESC 

-- Creating a View for the above query for later visualization

CREATE VIEW BioSolarEnergyConsumption AS
SELECT bio.country,
       SUM(biofuel_consumption) AS TotalBiofuelConsumption,
       SUM(solar_consumption) AS TotalSolarConsumption
FROM [energy-biofuel] bio
JOIN [energy-solar] sol ON bio.country = sol.country
AND bio.year = sol.year
GROUP BY bio.country
HAVING SUM(biofuel_consumption) IS NOT NULL
AND SUM(solar_consumption) IS NOT NULL 
--ORDER BY  SUM(biofuel_consumption) DESC, SUM(solar_consumption) DESC
