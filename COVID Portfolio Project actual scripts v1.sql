SELECT TOP 5 * 
FROM PorfolioProject..CovidDeaths$
ORDER BY 3,4
--Explore the data
SELECT *
FROM PorfolioProject..CovidDeaths$
WHERE continent is not null
ORDER BY 3,4

--SELECT TOP 5 *
--FROM PorfolioProject..CovidVaccination$
--Select Data that we are going to be using

SELECT location,date,total_cases,new_cases,total_deaths,population
From PorfolioProject..CovidDeaths$
Order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows Likelihood of dying if you contract covid in your country
SELECT location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PorfolioProject..CovidDeaths$
WHERE Location like '%states%'
ORDER BY 1,2

SELECT location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PorfolioProject..CovidDeaths$
WHERE Location like 'Cambod__'
ORDER BY 2,1

SELECT location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PorfolioProject..CovidDeaths$
WHERE Location like 'Cambod__'
ORDER BY 4,3,2,1

--Looking at Total Cases vs Population
--show what prcentage of population got COVID
SELECT location,date, total_cases,total_deaths,population, (total_cases/population)*100 as PopulationCasePercentage
FROM PorfolioProject..CovidDeaths$
--WHERE location like 'Camb%'
ORDER BY 1,2

--Looking at Countries with highest infection Rate compared to population
SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 
as PopulationCasePercentage
FROM PorfolioProject..CovidDeaths$
--WHERE location like 'Camb%'
GROUP BY location,population
ORDER BY PopulationCasePercentage DESC

--Showing Countries with Highest Death Count Per population
SELECT Location,MAX(cast(total_deaths as int)) as TotalDeathCount 
FROM PorfolioProject..CovidDeaths$
--WHERE location like 'Camb%'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

--BREAK THINGS DOWN BY location CONTINENT
SELECT location,MAX(cast(total_deaths as int)) as TotalDeathCount 
FROM PorfolioProject..CovidDeaths$
--WHERE location like 'Camb%'
WHERE continent is  null
GROUP BY location
ORDER BY TotalDeathCount DESC

--BREAK THINGS DOWN BY CONTINENT
SELECT continent,MAX(cast(total_deaths as int)) as TotalDeathCount 
FROM PorfolioProject..CovidDeaths$
--WHERE location like 'Camb%'
WHERE continent is not  null
GROUP BY continent
ORDER BY TotalDeathCount DESC

--SHOWING CONTINENTS WITH MOST DEATHS COUNT PER POPULATION
SELECT continent,MAX(cast(total_deaths as int)) as TotalDeathCount 
FROM PorfolioProject..CovidDeaths$
--WHERE location like 'Camb%'
WHERE continent is not  null
GROUP BY continent
ORDER BY TotalDeathCount DESC

--GLOBAL NUMBERS

SELECT /*date,*/ SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PorfolioProject..CovidDeaths$
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

--Look at vacinnation databases
SELECT * 
FROM PorfolioProject..CovidVaccination$ vac
JOIN PorfolioProject..CovidDeaths$  dea
	ON dea.location = vac.location
	AND dea.date = vac.date

--LOOKING AT TOTAL POPULATION VS VACCINATIONS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM  PorfolioProject..CovidDeaths$  dea
JOIN PorfolioProject..CovidVaccination$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date 
WHERE  dea.continent is not null
ORDER BY 1,2,3

--LOOKING AT TOTAL POPULATION VS VACCINATIONS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION by dea.location) as RollingPeopleVaccinated
FROM  PorfolioProject..CovidDeaths$  dea
JOIN PorfolioProject..CovidVaccination$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date 
WHERE  dea.continent is not null AND vac.new_vaccinations is not null
ORDER BY 1,2,3

--LOOKING AT
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION by dea.location) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM  PorfolioProject..CovidDeaths$  dea
JOIN PorfolioProject..CovidVaccination$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date 
WHERE  dea.continent is not null AND vac.new_vaccinations is not null
ORDER BY 1,2,3

---- USE CTE( Common Table Expression)
--WITH PopvsVac (continent, location, date, population, RollingPeopleVaccinated)
--AS (
--SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) 
--OVER (PARTITION by dea.location ORDER BY dea.location,dea.Date) as RollingPeopleVaccinated
----,(RollingPeopleVaccinated/population)*100
--FROM  PorfolioProject..CovidDeaths$  dea
--JOIN PorfolioProject..CovidVaccination$ vac
--	ON dea.location = vac.location
--	AND dea.date = vac.date 
--WHERE  dea.continent is not null
--ORDER BY 2,3 )

--USE CTE
WITH PopvsVac (Continent, Location, Date, Population,New_Vaccinations,RollingPeopleVaccinated)
AS
(
SELECT dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location,
dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PorfolioProject..CovidDeaths$ dea
JOIN PorfolioProject..CovidVaccination$ vac
	ON dea.location =vac.location
	AND dea.date= vac.date
WHERE dea.continent is not null 
--Order by 2,3
)
SELECT *
FROM PopvsVac

-- TEMP TABLE
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location,
dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PorfolioProject..CovidDeaths$ dea
JOIN PorfolioProject..CovidVaccination$ vac
	ON dea.location =vac.location
	AND dea.date= vac.date
WHERE dea.continent is not null 
--Order by 2,3

SELECT *
FROM #PercentPopulationVaccinated

--DROP TEMP TABLE AND CREATE 
DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location,
dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PorfolioProject..CovidDeaths$ dea
JOIN PorfolioProject..CovidVaccination$ vac
	ON dea.location =vac.location
	AND dea.date= vac.date
WHERE dea.continent is not null 
--Order by 2,3

SELECT *
FROM #PercentPopulationVaccinated

-- CREATE VIEW --SHOWING CONTINENTS WITH MOST DEATHS COUNT PER POPULATION for later visualization

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location,
dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PorfolioProject..CovidDeaths$ dea
JOIN PorfolioProject..CovidVaccination$ vac
	ON dea.location =vac.location
	AND dea.date= vac.date
WHERE dea.continent is not null 
--Order by 2,3

SELECT * FROM PercentPopulationVaccinated