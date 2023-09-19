


--Initial Exploring of Covid-19 datasets (CovidDeaths dataset & CovidVaccinations dataset)
SELECT * 
FROM Portfolio_Project.dbo.CovidDeaths
ORDER BY 3,4;





--After exploring the data, some locations aren't countries (continents). When location column is not a country, the continent column is null.
--Hence the not null continent phrase
SELECT*
FROM Portfolio_Project.dbo.CovidVaccinations
WHERE continent IS NOT NULL
ORDER BY 3,4;

SELECT Location, date, population, total_cases, total_deaths 
FROM Portfolio_Project..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;











--LOOKING FOR COUNTRIES WITH EARLIEST DEATHS**
SELECT Location, date, population, total_cases, total_deaths 
FROM Portfolio_Project..CovidDeaths
WHERE continent IS NOT NULL
AND DATEPART(MONTH, date) <=3
AND DATEPART(YEAR, date) =2020
ORDER BY 1,2;

SELECT Location, date, population, total_cases, total_deaths 
FROM Portfolio_Project..CovidDeaths
WHERE continent IS NOT NULL
AND total_deaths = 1
ORDER BY 1,2;








--COUNTRY INSIGHT




















--Looking at Country Total Cases vs Total Deaths by Date (percentage of people dying who report being infected)
SELECT Location, date, population, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Rate_of_Infected
FROM Portfolio_Project..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;







--Looking at Countries with Highest Death Rate of infected people compared to Population
SELECT Location, Population, MAX (total_cases) AS max_cases, MAX(CONVERT(int, total_deaths)) AS max_deaths, (MAX (CONVERT(INT,total_deaths))/MAX(total_cases)*100) AS DeathRateOfInfected
FROM Portfolio_Project..CovidDeaths
WHERE continent IS NOT NULL
--AND Location= 'United States'
--OR location= 'Morocco'
GROUP BY Location, Population
ORDER BY DeathRateOfInfected DESC;










--Looking at Total Cases vs Population
--Shows what percentage of population in each country got COVID by date
SELECT Location, date, Population, total_cases, (total_cases/population)*100 AS Population_Infected_Percentage
FROM Portfolio_Project..CovidDeaths
WHERE continent IS NOT NULL
--AND Location= 'United States'
--AND Location= 'Morocco'
ORDER BY 1,2;










--Looking at Countries with Highest Infection Rate compared to Population
SELECT Location, Population, MAX(total_cases) AS Highest_Infection_Count, MAX((total_cases/population)*100)  AS Population_Infected_Percentage
FROM Portfolio_Project..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location, Population
ORDER BY Population_Infected_Percentage DESC;










--Countries with the highest death rates of infected people compared to their infection rates
SELECT Location, Population, MAX(total_cases) AS MaxCases, MAX(CONVERT(INT, total_deaths)) AS MaxDeaths, (MAX(CONVERT(INT,total_deaths))/MAX(total_cases))*100 AS DeathRateOfInfected, MAX((total_cases/Population)*100) AS InfectionRateOfPopulation
FROM Portfolio_Project..CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY Location, Population
ORDER BY DeathRateOfInfected DESC;







--Showing Countries with Highest Death count

--issue with how data type is read when using this aggregate function, 
--so have to use cast/convert to change the total_deaths data type from nvarchar to integer (DATA TYPE CHANGE IS EXCLUSIVE TO QUERY ONLY AND IS NOT PERMANENT)
SELECT Location, Population, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM Portfolio_Project..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location, Population
ORDER BY TotalDeathCount DESC;








--Showing Countries with Highest Death count WITH CONTEXT OF added infection rate of population and death rate of infected people
SELECT Location, Population, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount, 
	(MAX(CONVERT(INT,total_deaths))/MAX(total_cases))*100 AS DeathRateOfInfected, MAX((total_cases/Population)*100) AS InfectionRateOfPopulation 
FROM Portfolio_Project..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location, Population
ORDER BY TotalDeathCount DESC;









--CONTINENT INSIGHT




























--Displaying continents with the highest COVID death count
SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM Portfolio_Project..CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY continent
ORDER BY TotalDeathCount DESC;






--Looking at Continents with Highest Death Rate of infected people compared to Population
SELECT continent, MAX (total_cases) AS max_cases, MAX(CONVERT(int, total_deaths)) AS max_deaths, (MAX (CONVERT(INT,total_deaths))/MAX(total_cases)*100) AS DeathRateOfInfected
FROM Portfolio_Project..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY DeathRateOfInfected DESC;







--Looking at Continents with Highest Infection Rate compared to Population
SELECT Location, Population, MAX(total_cases) AS Highest_Infection_Count, MAX((total_cases/population))*100  AS Population_Infected_Percentage
FROM Portfolio_Project..CovidDeaths
WHERE continent IS NULL
AND NOT Location= 'European Union' 
AND NOT Location= 'World'
AND NOT Location= 'International'
GROUP BY Location, Population
ORDER BY Population_Infected_Percentage DESC;










-- Global insights























--Showing the percentage of deaths of infected people in the world by date
SELECT date, SUM (new_cases) AS TotalCases, SUM(cast(new_deaths AS INT))AS TotalDeaths, (SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 AS GlobalDeathRateOfInfected
FROM Portfolio_Project..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1;






--Showing the death percentage of infected people and corresponding infection rate of population in total 
SELECT SUM (new_cases) AS TotalCases, SUM(cast(new_deaths AS INT))AS TotalDeaths, (SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 AS GlobalDeathRateOfInfected,
	(SUM(new_cases)/SUM(DISTINCT population))*100 AS GlobalInfectionRate, SUM(DISTINCT population) AS GlobalPopulation
FROM Portfolio_Project..CovidDeaths
WHERE continent IS NOT NULL;














--INSIGHTS ON TOTAL POPULATION VS. VACCINATIONS













--Initial viewing of joined tables to ensure the tables are joined correctly
SELECT *
FROM Portfolio_Project..CovidDeaths AS D, Portfolio_Project..CovidVaccinations AS V
WHERE D.location=V.location
AND D.date=V.date






--Showing new vaccinations and the rolling sum of new vaccinations by date for countries (EQUI-JOIN)
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations,
SUM(CONVERT(INT, V.new_vaccinations)) OVER (PARTITION BY D.location ORDER BY D.location, D.date) AS Rolling_Sum_of_Vaccinations_by_Location
FROM Portfolio_Project..CovidDeaths AS D, Portfolio_Project..CovidVaccinations AS V
WHERE D.location= V.location
AND D.date= V.date
AND D.continent IS NOT NULL
ORDER BY 2,3








--Showing new vaccinations and rolling sum by date for countries (INNER JOIN)
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations,
SUM(CONVERT(INT, V.new_vaccinations)) OVER (PARTITION BY D.location ORDER BY D.location, D.date) AS Rolling_Sum_of_Vaccinations_by_Location
FROM Portfolio_Project..CovidDeaths AS D JOIN Portfolio_Project..CovidVaccinations AS V
	ON D.location= V.location
	AND D.date= V.date
WHERE D.continent IS NOT NULL
ORDER BY 2,3














--USING CTE to utilize newly created expression as a column
WITH Pop_vs_Vac (Continent, Location, Date, Population, New_Vaccinations, Rolling_Sum_of_Vaccinations_by_Location)
AS
(
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations,
SUM(CONVERT(INT, V.new_vaccinations)) OVER (PARTITION BY D.location ORDER BY D.location, D.date) AS Rolling_Sum_of_Vaccinations_by_Location
FROM Portfolio_Project..CovidDeaths AS D JOIN Portfolio_Project..CovidVaccinations AS V
	ON D.location= V.location
	AND D.date= V.date
WHERE D.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (Rolling_Sum_of_Vaccinations_by_Location/Population)*100 AS Rolling_Total_PopulationVaccinated_Percentage
FROM Pop_vs_Vac
















--TEMP TABLE VERSION OF ABOVE QUERY
DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent									NVARCHAR (255),
Location									NVARCHAR (255),
Date										DATETIME,
Population									NUMERIC,
New_vaccinations							NUMERIC,
Rolling_Sum_of_Vaccinations_by_Location		NUMERIC
);

INSERT INTO #PercentPopulationVaccinated
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations,
SUM(CONVERT(INT, V.new_vaccinations)) OVER (PARTITION BY D.location ORDER BY D.location, D.date) AS Rolling_Sum_of_Vaccinations_by_Location
FROM Portfolio_Project..CovidDeaths AS D JOIN Portfolio_Project..CovidVaccinations AS V
	ON D.location= V.location
	AND D.date= V.date
WHERE D.continent IS NOT NULL
--AND D.location='United States'
--ORDER BY 2,3;

SELECT *, (Rolling_Sum_of_Vaccinations_by_Location/Population)*100 AS Rolling_Total_PopulationVaccinated_Percentage
FROM #PercentPopulationVaccinated














--Creating Views to store data for visualizations



















--View for showing new vaccinations and rolling sum by date for countries
USE Portfolio_Project

CREATE VIEW Percent_Population_Vaccinated AS
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations,
SUM(CONVERT(INT, V.new_vaccinations)) OVER (PARTITION BY D.location ORDER BY D.location, D.date) AS Rolling_Sum_of_Vaccinations_by_Location
FROM Portfolio_Project..CovidDeaths AS D JOIN Portfolio_Project..CovidVaccinations AS V
	ON D.location= V.location
	AND D.date= V.date
WHERE D.continent IS NOT NULL
--AND D.location='United States'
--ORDER BY 2,3;




--View for displaying continents with the highest COVID death count
USE Portfolio_Project

CREATE VIEW Continent_death_count AS
SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM Portfolio_Project..CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY continent
--ORDER BY TotalDeathCount DESC;






--View for Continents with Death Rate of infected people compared to Population
USE Portfolio_Project

CREATE VIEW Continent_death_rate AS
SELECT continent, MAX (total_cases) AS max_cases, MAX(CONVERT(int, total_deaths)) AS max_deaths, (MAX (CONVERT(INT,total_deaths))/MAX(total_cases)*100) AS DeathRateOfInfected
FROM Portfolio_Project..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
--ORDER BY DeathRateOfInfected DESC;







--View for Continents with Infection Rate compared to Population
USE Portfolio_Project

CREATE VIEW infection_rate_of_continents AS
(
SELECT Location, Population, MAX(total_cases) AS Highest_Infection_Count, MAX((total_cases/population))*100  AS Population_Infected_Percentage
FROM Portfolio_Project..CovidDeaths
WHERE continent IS NULL
AND NOT Location= 'European Union' 
AND NOT Location= 'World'
AND NOT Location= 'International'
GROUP BY Location, Population
--ORDER BY Population_Infected_Percentage DESC;
)






--Showing Views
SELECT *
FROM Percent_Population_Vaccinated
ORDER BY 2,3

SELECT *
FROM infection_rate_of_continents
ORDER BY 4 DESC

SELECT *
FROM Continent_death_rate
ORDER BY 4 DESC

SELECT * 
FROM Continent_death_count
ORDER BY 2 DESC
