USE PortfolioProject
GO

SELECT *
FROM [covid deaths]
WHERE continent IS NOT NULL
ORDER BY 3,4


--SELECT *
--FROM [Covid Vaccination]
--ORDER BY 3,4



--Select Data that we are going to be using

SELECT location, date, total_cases,new_cases, total_deaths, population
FROM [covid deaths]
ORDER BY 1,2



--Looking at the Total Cases VS Total Deaths
--This shows the chances of dying if you contract COVID in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM [covid deaths]
WHERE location like '%Africa%'
ORDER BY 1,2

  

--Looking at the Total Cases VS Population
--That is the percentage of population got COVID

SELECT location, date, population, total_cases, (total_cases/population)*100 AS InfectedPercentage
FROM [covid deaths]
--WHERE location like '%Africa%'
ORDER BY 1,2



--Looking at countries with Highest Infection Rate compared to population

SELECT location, population,MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS InfectedPercentage
FROM [covid deaths]
--WHERE location like '%Africa%'
GROUP BY location, population
ORDER BY InfectedPercentage DESC



-- Showing Countries with Highest Death Count per Population

SELECT location, MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
FROM [covid deaths]
--WHERE location like '%Africa%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC



--Continents with Highest Death Count per Population


SELECT continent, MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
FROM [covid deaths]
--WHERE location like '%Africa%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC



-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/sum(New_Cases)*100 AS DeathPercentage
FROM [covid deaths]
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2



-- Looking at Total Population VS Total Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac. new_vaccinations
, SUM(CAST(vac. new_vaccinations AS int)) OVER (PARTITION BY dea. Location)
FROM [covid deaths] dea
JOIN [Covid Vaccination] vac
     ON dea. location = vac. location
	 AND dea.date = vac. date
	 WHERE dea.continent IS NOT NULL
	 ORDER BY 2, 3



-- USE CTE

WITH PopVsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVacccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac. new_vaccinations
, SUM(CAST(vac. new_vaccinations AS int)) OVER (PARTITION BY dea. Location ORDER BY dea. location, dea. date) AS RollingPeopleVaccinated
FROM [covid deaths] dea
JOIN [Covid Vaccination] vac
     ON dea. location = vac. location
	 AND dea.date = vac. date
	 WHERE dea.continent IS NOT NULL
	-- ORDER BY 2, 3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopVsvac




--TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinates
CREATE TABLE #PercentPopulationVaccinates
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinates
SELECT dea.continent, dea.location, dea.date, dea.population, vac. new_vaccinations
, SUM(CAST(vac. new_vaccinations AS int)) OVER (PARTITION BY dea. Location ORDER BY dea. location, dea. date) AS RollingPeopleVaccinated
FROM [covid deaths] dea
JOIN [Covid Vaccination] vac
     ON dea. location = vac. location
	 AND dea.date = vac. date
	 WHERE dea.continent IS NULL
	-- ORDER BY 2, 3

SELECT *, (#PercentPopulationVaccinates/Population)*100
FROM #PercentPopulationVaccinates




-- Creating Views for Visualizations

CREATE VIEW PercentPopulationVaccinates AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac. new_vaccinations
, SUM(CAST(vac. new_vaccinations AS int)) OVER (PARTITION BY dea. Location ORDER BY dea. location, dea. date) AS RollingPeopleVaccinated
FROM [covid deaths] dea
JOIN [Covid Vaccination] vac
     ON dea. location = vac. location
	 AND dea.date = vac. date
	 WHERE dea.continent IS NULL
	-- ORDER BY 2, 3


SELECT *
FROM PercentPopulationVaccinates


