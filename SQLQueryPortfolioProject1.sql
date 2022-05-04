/*
Covid 19 Data Exploration

Skills used: Joins, CTE's, Temp Tables, Windows Funtions, Creating Views, Converting Data Types

*/



select*
from Portfolio..['Covid Deaths$']
where continent is not null
order by 3,4


--Select the data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from Portfolio..['Covid Deaths$']
order by 1,2

--Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Portfolio..['Covid Deaths$']
where location like '%states%'
order by 1,2

--Total Cases vs Population
--Shows what percentage of population infected Covid

select location, date,  population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from Portfolio..['Covid Deaths$']
where location like '%states%'
order by 1,2

--Countries with Highest Infection Rate compared to Population

select location, population, Max(total_cases) as HieghestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
from Portfolio..['Covid Deaths$']
--where location like '%states%'
group by location, population
order by PercentPopulationInfected desc

--Coutries with the Highest Death Count per Population

select location, max(cast(Total_deaths as int)) as TotalDeathCount
from Portfolio..['Covid Deaths$']
--where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc

--BREAK THINGS DOWN BY CONTINENT
--Showing continents with the highest death count per population

select continent, max(cast(Total_deaths as int)) as TotalDeathCount
from Portfolio..['Covid Deaths$']
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc


select location, max(cast(Total_deaths as int)) as TotalDeathCount
from Portfolio..['Covid Deaths$']
--where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc

--Global Numbers

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum
(new_cases)*100 as DeathPercentage
from Portfolio..['Covid Deaths$']
--where location like '%states%'
where continent is not null
group by date
order by 1,2

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum
(new_cases)*100 as DeathPercentage
from Portfolio..['Covid Deaths$']
--where location like '%states%'
where continent is not null
--group by date
order by 1,2

--Total Population vs Vaccinations
--Shows Percentage of Population that has recieved at least one Covid Vaccine

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from Portfolio..['Covid Deaths$'] dea
Join Portfolio..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from Portfolio..['Covid Deaths$'] dea
Join Portfolio..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Using CTE to perform Calculationon Partion By in previous query

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from Portfolio..['Covid Deaths$'] dea
Join Portfolio..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac

--Using Temp Table to perform Calculation on Partion By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio..['Covid Deaths$'] dea
Join Portfolio..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio..['Covid Deaths$'] dea
Join Portfolio..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 










