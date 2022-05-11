
/* COVID 19 DATA EXPLORATION

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

SELECT *
FROM Portfolio_project..coviddeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT THE DATA FOR ANALYSIS

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Portfolio_project..coviddeaths
ORDER BY 1,2 

-- LOOKING AT TOTAL CASES VS TOTAL DEATHS
-- SHOWS THE PERCENTAGE RATE OF DYING IF YOU CONTRACT COVID 19

SELECT location, date, total_cases,  total_deaths, (total_cases/total_deaths)*100 AS DeathPercentage
FROM Portfolio_project..coviddeaths
WHERE Location like '%Nigeria' 
AND continent IS NOT NULL
ORDER BY 1,2 

-- LOOKING AT TOTAL CASES VS POPULATION
-- SHOWS WHAT PERCENTAGE OF THE POPULATION CONTRACT COVID

SELECT location, date, total_cases,  (total_cases/population)*100 AS contractPercentage, population
FROM Portfolio_project..coviddeaths
WHERE continent IS NOT NULL
--WHERE Location like '%states'
ORDER BY 1,2 desc

-- LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION

SELECT location, MAX(total_cases)  AS HighestInfectionCount,  MAX(total_cases/population)*100 AS PercentPopInfected, population
FROM Portfolio_project..coviddeaths
--WHERE Location like '%states'
GROUP BY location, population
ORDER BY  PercentPopInfected desc

-- SHOWING COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION

SELECT location, MAX(cast (total_deaths as int))  AS TotalDeathCount, population
FROM Portfolio_project..coviddeaths
WHERE continent IS NOT NULL
--WHERE Location like '%states'
GROUP BY location, population
ORDER BY  TotalDeathCount desc

-- BREAKING DATA BY CONTINENT

SELECT continent, MAX(cast (total_deaths as int))  AS TotalDeathCount, population
FROM Portfolio_project..coviddeaths
WHERE continent IS NOT NULL
--WHERE Location like '%states'
GROUP BY continent, population
ORDER BY  TotalDeathCount desc

-- WHEN CONTINENT IS NULL

SELECT location, MAX(cast (total_deaths as int))  AS TotalDeathCount, population
FROM Portfolio_project..coviddeaths
WHERE continent IS  NULL
--WHERE Location like '%states'
GROUP BY location, population
ORDER BY  TotalDeathCount desc

--SHOWING CONTINENT WITH HIGHEST DEATH COUNT PER POPULATION

SELECT continent, MAX(cast (total_deaths as int))  AS TotalDeathCount
FROM Portfolio_project..coviddeaths
WHERE continent IS NOT NULL
--WHERE Location like '%states'
GROUP BY continent
ORDER BY  TotalDeathCount desc


-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as totaldeaths, 
SUM(cast (new_deaths as int))/SUM(new_cases)* 100 AS DeathPerc 
FROM Portfolio_project..coviddeaths
WHERE continent IS NOT NULL
--WHERE Location like '%states'
GROUP BY date

-- TOTAL DEATH CASES

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as totaldeaths, 
SUM(cast (new_deaths as int))/SUM(new_cases)* 100 AS DeathPerc 
FROM Portfolio_project..coviddeaths
WHERE continent IS NOT NULL
--WHERE Location like '%states'
--GROUP BY date
ORDER BY 1,2 

-- LOOKING AT TOTAL POPULATION VS VACCINATION

SELECT deat.continent, deat.location, deat.date, deat.population, vacc.new_vaccinations
FROM Portfolio_project..coviddeaths AS deat
JOIN Portfolio_project..covidVaccination AS vacc
	ON deat.location = vacc.location
	and deat.date = vacc.date
WHERE deat.continent is not NULL 
ORDER BY 1,2,3


SELECT deat.continent, deat.location, deat.date, deat.population, vacc.new_vaccinations,
SUM(CAST(vacc.new_vaccinations AS int)) OVER (Partition by deat.location, deat.date ORDER BY deat.location) as ProgressiveVaccCount

FROM Portfolio_project..coviddeaths AS deat
JOIN Portfolio_project..covidVaccination AS vacc
	ON deat.location = vacc.location
	and deat.date = vacc.date
WHERE deat.continent is not NULL 
ORDER BY 2,3

-- USE A CTE

WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, ProgressiveVaccCount) as 
(
SELECT deat.continent, deat.location, deat.date, deat.population, vacc.new_vaccinations,
SUM(CAST(vacc.new_vaccinations AS int)) OVER (Partition by deat.location, deat.date ORDER BY deat.location) as ProgressiveVaccCount

FROM Portfolio_project..coviddeaths AS deat
JOIN Portfolio_project..covidVaccination AS vacc
	ON deat.location = vacc.location
	and deat.date = vacc.date
WHERE deat.continent is not NULL 
--ORDER BY 2,3
)
SELECT *, ( ProgressiveVaccCount/Population)*100
FROM PopvsVac



--TEMPORARY TABLE
-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
New_Vaccinations numeric,
ProgressiveVaccCount numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT deat.continent, deat.location, deat.date, deat.population, vacc.new_vaccinations,
SUM(CAST(vacc.new_vaccinations AS int)) OVER (Partition by deat.location, deat.date ORDER BY deat.location) as ProgressiveVaccCount
FROM Portfolio_project..coviddeaths AS deat
JOIN Portfolio_project..covidVaccination AS vacc
	ON deat.location = vacc.location
	and deat.date = vacc.date
--WHERE deat.continent is not NULL 
--ORDER BY 2,3

SELECT *, (ProgressiveVaccCount/population)*100
FROM #PercentPopulationVaccinated

--CREATING VIEWS TO STORE DATA FOR VISUALISATIONS

CREATE VIEW PercentPopulationVaccinated as
SELECT deat.continent, deat.location, deat.date, deat.population, vacc.new_vaccinations,
SUM(CAST(vacc.new_vaccinations AS int)) OVER (Partition by deat.location, deat.date ORDER BY deat.location) as ProgressiveVaccCount
FROM Portfolio_project..coviddeaths AS deat
JOIN Portfolio_project..covidVaccination AS vacc
	ON deat.location = vacc.location
	and deat.date = vacc.date
WHERE deat.continent is not NULL 
--ORDER BY 2,3