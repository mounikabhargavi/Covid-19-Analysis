/*
Covid 19 Data Exploration 
*/

select * from ProjectCovid..CovidDeaths
--where continent is not null
where location like '%income%'
order by 3,4

select * from ProjectCovid..CovidVaccinations
where continent is not null
order by 3,4

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
select Location,date,total_cases,new_cases,total_deaths,population
from ProjectCovid..CovidDeaths
where continent is not null
order by 1,2

select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from ProjectCovid..CovidDeaths
where location like '%states%'
order by 1,2

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid
select Location,date,population,total_cases,(total_cases/population)*100 as PercentPopulationInfected
from ProjectCovid..CovidDeaths
where continent is not null
order by 1,2

-- Countries with Highest Infection Rate compared to Population
select Location,population,MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population)*100) as PercentPopulationInfected
from ProjectCovid..CovidDeaths
where continent is not null
group by Location, population
order by PercentPopulationInfected desc

-- Countries with Highest Death Count per Population
select Location,MAX(cast(total_deaths as int)) as TotalDeathCount
from ProjectCovid..CovidDeaths
where continent is not null
group by Location
order by TotalDeathCount desc

-- Showing contintents with the highest death count per population
select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
from ProjectCovid..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS
select SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, SUM(cast
(new_deaths as int))/SUM(new_cases)*100 as deathPercentage
from ProjectCovid..CovidDeaths
where continent is not null
--group by date
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location order by dea.location,dea.date)
as RollingPeopleVaccinated
from ProjectCovid..CovidDeaths dea
Join ProjectCovid..CovidVaccinations vac
 On dea.location = vac.location
 and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location order by dea.location,dea.date)
as RollingPeopleVaccinated
from ProjectCovid..CovidDeaths dea
Join ProjectCovid..CovidVaccinations vac
 On dea.location = vac.location
 and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *,(RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous que

Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location order by dea.location,dea.date)
as RollingPeopleVaccinated
from ProjectCovid..CovidDeaths dea
Join ProjectCovid..CovidVaccinations vac
 On dea.location = vac.location
 and dea.date = vac.date
--where dea.continent is not null 
Select *,(RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--creating view for visualization
drop View PercentPopulationVaccinated
Create View PercentPopulationVaccinated as 
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location order by dea.location,dea.date)
as RollingPeopleVaccinated
from ProjectCovid..CovidDeaths dea
Join ProjectCovid..CovidVaccinations vac
 On dea.location = vac.location
 and dea.date = vac.date
where dea.continent is not null
---order by 2,3

--view table
select * from PercentPopulationVaccinated


