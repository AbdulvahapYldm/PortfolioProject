DATA ADDRESS LINK => https://ourworldindata.org/explorers/coronavirus-data-explorer


SELECT * FROM PortfolioProject..CovidDeaths
SELECT * FROM PortfolioProject..CovidVaccinations


--NEW CASES, TOTAL CASES AND TOTAL DEATHS DATA FOR EACH COUNTRY ON WHAT DATE
SELECT continent,location,date,population,new_cases,total_cases,total_deaths
FROM PortfolioProject..CovidDeaths WHERE continent IS NOT NULL
--AND location ='Ireland'
ORDER BY location,date

--DEATH PERCENTAGE OF EACH COUNTRY DEPENDING ON DATES
SELECT continent,location,date,population,new_cases,total_cases,total_deaths,
(CAST(total_deaths AS INT)/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location ='Ireland'
ORDER BY location,date


--TOTAL DEATHS TO POPULATION RATIO OF EACH COUNTRY BY DATE
SELECT continent,location,date,population, new_cases,total_cases,total_deaths,
(total_deaths/total_cases)*100 AS DeathPercentage,(total_cases/population)*100 as PercentageOfPopulation
FROM PortfolioProject..CovidDeaths WHERE continent IS NOT NULL 
--AND location ='Ireland'
ORDER BY location,date


--LOOKING AT THE COUNTRIES WITH THE HIGHEST INFECTION RATE COMPARED TO THE POPULATION
SELECT location,population,
max(total_cases) AS HighestInfectionCount,
max((CAST(total_deaths AS INT)/total_cases)*100) AS DeathPercentageMax,
max((total_cases/population)*100) AS PercentPopulationInfactionMax
FROM PortfolioProject..CovidDeaths WHERE continent IS NOT NULL
GROUP BY location,population
ORDER BY PercentPopulationInfactionMax Desc

--COUNTRIES WITH THE HIGHEST TOTAL NUMBER OF DEATHS
SELECT location,
MAX(CAST(total_deaths AS INT)) AS TotalDeaths
from PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeaths Desc

--TOTAL CASES, TOTAL DEATHS AND DEATH PERCENTAGES IN THE WORLD UNTIL 22/02/2024
SELECT SUM(new_cases) AS TotalCase,SUM((CAST(new_deaths AS INT))) AS TotalDeats,
(SUM((CAST(new_deaths AS INT)))/SUM(new_cases))*100 AS DeatsPercentages
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--JOINING TWO TABLES
--[dbo].[CovidDeaths] AND [dbo].[CovidVaccinations]
SELECT * FROM 
PortfolioProject.dbo.CovidDeaths AS DEATS
JOIN 
PortfolioProject.dbo.CovidVaccinations AS VAC
ON DEATS.date=VAC.date AND DEATS.location=VAC.location

--TOTAL VACCINE AND TOTAL DEATH RATES BY COUNTRIES
SELECT DEATS.continent,DEATS.location ,
SUM(CAST(VAC.new_vaccinations AS bigint)) AS TotalVaccinations ,
SUM(DEATS.new_deaths) TotalDeats
FROM PortfolioProject.dbo.CovidDeaths DEATS
FULL OUTER JOIN
PortfolioProject.dbo.CovidVaccinations VAC
	ON DEATS.date=VAC.date AND DEATS.location=VAC.location
WHERE DEATS.continent IS NOT NULL and DEATS.new_deaths IS NOT NULL 
GROUP BY DEATS.location,DEATS.continent
ORDER BY 3 DESC

--NUMBER OF VACCINATIONS OF COUNTRIES BY HISTORY
SELECT DEATS.continent,DEATS.location ,DEATS.date,DEATS.population,VAC.new_vaccinations,
sum(convert(bigint,VAC.new_vaccinations)) over (partition by DEATS.location order by DEATS.location,DEATS.date) as rollingpeoplevaccined
FROM PortfolioProject.dbo.CovidDeaths DEATS FULL OUTER JOIN PortfolioProject.dbo.CovidVaccinations VAC
	ON DEATS.date=VAC.date AND DEATS.location=VAC.location
WHERE DEATS.continent IS NOT NULL AND VAC.new_vaccinations IS NOT NULL
ORDER BY 2,3

--TOTAL VACCINATION PERCENTAGE
WITH PopVsVac(continent,location ,date,population,new_vaccination,rollingpeoplevaccined) AS
(
SELECT DEATS.continent,DEATS.location ,DEATS.date,DEATS.population,VAC.new_vaccinations,
sum(convert(bigint,VAC.new_vaccinations)) over 
(partition by DEATS.location order by DEATS.location,DEATS.date) as RollingPeopleVaccined
FROM PortfolioProject.dbo.CovidDeaths DEATS JOIN PortfolioProject.dbo.CovidVaccinations VAC
	ON DEATS.date=VAC.date AND DEATS.location=VAC.location
WHERE DEATS.continent IS NOT NULL AND VAC.new_vaccinations IS NOT NULL
)
SELECT *,(RollingPeopleVaccined/population)*100 AS TotalVaccinatedPercentage FROM PopVsVac

--CREATE TABLE
DROP TABLE IF EXISTS #TotalVaccinatedPer
CREATE TABLE #TotalVaccinatedPer(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
rollingpeoplevaccined numeric)

INSERT INTO #TotalVaccinatedPer
SELECT DEATS.continent,DEATS.location ,DEATS.date,DEATS.population,VAC.new_vaccinations,
SUM(CONVERT(BIGINT,VAC.new_vaccinations)) OVER 
(partition by DEATS.location order by DEATS.location,DEATS.date) AS RollingPeopleVaccined
FROM PortfolioProject.dbo.CovidDeaths DEATS JOIN PortfolioProject.dbo.CovidVaccinations VAC
	ON DEATS.date=VAC.date AND DEATS.location=VAC.location
WHERE DEATS.continent IS NOT NULL AND VAC.new_vaccinations IS NOT NULL

--USE NEW TABLE
SELECT *,(rollingpeoplevaccined/population)*100 AS TotalVaccinatedPercent FROM #TotalVaccinatedPer


--CREATE WIEW 
CREATE VIEW TotalVaccinatedPercentage AS
SELECT DEATS.continent,DEATS.location ,DEATS.date,DEATS.population,VAC.new_vaccinations,
SUM(CONVERT(bigint,VAC.new_vaccinations)) OVER 
(partition by DEATS.location order by DEATS.location,DEATS.date) AS RollingPeopleVaccined
FROM PortfolioProject.dbo.CovidDeaths DEATS JOIN PortfolioProject.dbo.CovidVaccinations VAC
	ON DEATS.date=VAC.date AND DEATS.location=VAC.location
WHERE DEATS.continent IS NOT NULL AND VAC.new_vaccinations IS NOT NULL

--USE WIEW'S TABLE
SELECT * FROM TotalVaccinatedPercentage
