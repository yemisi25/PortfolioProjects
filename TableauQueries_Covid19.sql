/*
Queries used for Tableau visualisation of the covid 19 data exploration
*/



-- 1. 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From Portfolio_project..coviddeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

-
-- 2. 

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From Portfolio_project..coviddeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International', 'Upper middle income', 'High income', 'Low income', 'lower middle income')
Group by location
order by TotalDeathCount desc


-- 3.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Portfolio_project..coviddeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- 4.


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Portfolio_project..coviddeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc


-- 5


Select SUM(new_cases) as total_cases, continent, MAX(cast (total_deaths as int))  AS TotalDeathCount, population, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From Portfolio_project..coviddeaths
--Where location like '%states%'
where continent is not null 
GROUP BY continent,population
ORDER BY TotalDeathCount desc

--6

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as totaldeaths, continent, max(population) as Total_Population,
SUM(cast (new_deaths as int))/SUM(new_cases)* 100 AS DeathPerc 
FROM Portfolio_project..coviddeaths
WHERE continent IS NOT NULL
--WHERE Location like '%states'
--GROUP BY date
group by continent
ORDER BY 1,2 






-- 7

Select deat.continent, deat.location, deat.date, deat.population
, MAX(CAST(vacc.new_vaccinations AS int)) as ProgressiveVaccCount
From Portfolio_project..coviddeaths deat
Join Portfolio_project..covidVaccination vacc
	On deat.location = vacc.location
	and deat.date = vacc.date
where deat.continent is not null 
group by deat.continent, deat.location, deat.date, deat.population
order by 1,2,3

-


-- 4.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Portfolio_project..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc



-- 5.

Select Location, date, population, total_cases, total_deaths
From Portfolio_project..CovidDeaths
--Where location like '%states%'
where continent is not null 
order by 1,2


-- 6. 


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


-- 7. 

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Portfolio_project..Coviddeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc


