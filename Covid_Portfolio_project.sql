SELECT *
FROM Portfolio_Project..CovidDeaths
where continent is not null
ORDER BY 3,4

--SELECT *
--FROM Portfolio_Project..CovidVaccinations
--ORDER BY 3,4

SELECT location,date,total_cases,new_cases, total_deaths, population
FROM Portfolio_Project..CovidDeaths
where continent is not null
order by 1,2




-- Looking at total cases vs total deaths(% of people dying)
-- shows the likelihood of dying if you contract covid in India
Select location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS DeathPercentage
from Portfolio_Project..CovidDeaths 
where location like '%india%'
and continent is not null
order by 1,2

--Total cases vs population
-- shows what % of population got covid

Select location, date, total_cases,population, 
--((CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))*100) AS DeathPercentage
(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 AS PercentOfPopulationInfected
from Portfolio_Project..CovidDeaths 
where location like '%india%'
and continent is not null
order by 1,2

--Looking at countries with highest infection rate compared to population

Select location,population, max(total_cases) as HighestInfectionCount, 
Max((CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))) * 100 AS PercentOfPopulationInfected
from Portfolio_Project..CovidDeaths 
--where location like '%india%'
where continent is not null
Group by population, location
order by  PercentOfPopulationInfected desc


-- Showing the countries with the highest death count per population

Select location, max(cast(total_deaths as int)) as TotalDeathCount
from Portfolio_Project..CovidDeaths 
--where location like '%india%'
where continent is not null 
Group by location
order by  TotalDeathCount desc


--Let's BREAK THINGS DOWN BY CONTINENTS

--Select location, max(cast(total_deaths as int)) as TotalDeathCount
--from Portfolio_Project..CovidDeaths 
----where location like '%india%'
--where location not like '%income%'
--and continent is null
--Group by location
--order by  TotalDeathCount desc


--  Showing continents with highest death count per population


Select continent, max(cast(total_deaths as int)) as TotalDeathCount
from Portfolio_Project..CovidDeaths 
--where location like '%india%'
where continent is not null 
Group by continent
order by  TotalDeathCount desc


-- GLOBAL NUMBER


--Select date, Sum(new_cases) as TotalCases, sum(new_deaths) as TotalDeaths,
--(CONVERT(float, sum(new_deaths) / NULLIF(CONVERT(float, sum(new_cases)), 0)) * 100) as DeathPercentage
--from Portfolio_Project..CovidDeaths 
----where location like '%india%'
--where continent is not null
--group by date 
--order by 1,2


Select Sum(new_cases) as TotalCases, sum(new_deaths) as TotalDeaths,
(CONVERT(float, sum(new_deaths) / NULLIF(CONVERT(float, sum(new_cases)), 0)) * 100) as DeathPercentage
from Portfolio_Project..CovidDeaths 
--where location like '%india%'
where continent is not null
--group by date 
order by 1,2


--Looking at total population vs vaccinations


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(Convert(bigint, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
FROM Portfolio_Project..CovidDeaths dea
JOIN Portfolio_Project..CovidVaccinations vac
	ON
	dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 	
--where dea.continent like '%america%'
order by 2,3


--Use CTE

with PopvsVac( Continent, Location, Date, Population,New_vaccination, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(Convert(bigint, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
FROM Portfolio_Project..CovidDeaths dea
JOIN Portfolio_Project..CovidVaccinations vac
	ON
	dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 	
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac






-- Temp table 

DROP table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)



insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(Convert(bigint, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
FROM Portfolio_Project..CovidDeaths dea
JOIN Portfolio_Project..CovidVaccinations vac
	ON
	dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 	
--order by 2,3


Select *, (Nullif(RollingPeopleVaccinated,0)/Nullif(Population,0))*100 as PercentagePopulationVaccinated
From #PercentPopulationVaccinated


--Creating view to store data for later visualizations


Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(Convert(bigint, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
FROM Portfolio_Project..CovidDeaths dea
JOIN Portfolio_Project..CovidVaccinations vac
	ON
	dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 	
--order by 2,3


SELECT *
FROM PercentPopulationVaccinated;



