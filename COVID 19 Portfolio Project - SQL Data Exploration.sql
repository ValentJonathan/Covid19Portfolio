/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

Select * 
From [Portfolio Projects]..CovidDeaths
Where continent is not null
Order by 3,4

-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 1,2

-- Total Cases vs Total Deaths and the likehood of dying in my homecountry

Select Location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 AS MortalityRate
From [Portfolio Projects]..CovidDeaths
Where location like 'Indonesia'
and continent is not null
order by 1,2

-- Total Cases vs population, showing the total population that have contracted Covid

Select Location,date,total_cases,Population, (total_cases/Population)*100 AS CasesPercentage
From [Portfolio Projects]..CovidDeaths
Where location like 'Indonesia'
order by 1,2

-- Countries with Highest Infection Rate compared to Population
Select Location, Population,MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population))*100
AS PopulationInfectedPercentage
From [Portfolio Projects]..CovidDeaths
Group by Location, Population
order by 4 desc

-- Looking at Countries with the highest infection rate based on the latest data of total cases

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [Portfolio Projects]..CovidDeaths
Where continent is not null
Group by Location
order by 2 desc



-- Breaking things down by Continents


-- Showing continents with the highest death count
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [Portfolio Projects]..CovidDeaths
Where continent is not null
Group by continent
order by 2 desc


-- Global Numbers

Select date, SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths ,SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [Portfolio Projects]..CovidDeaths
where continent is not null
Group by date
order by 1,2

Select SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths ,SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [Portfolio Projects]..CovidDeaths
where continent is not null
order by 1,2

-----------------
---- Looking at total populations vs vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated --(RollingPeopleVaccinated/population)*100
From [Portfolio Projects]..CovidDeaths dea
Join [Portfolio Projects]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order by 2,3

--- USE CTE to perform Calculation on Partition By in previous query

With PopvsVac (continent,location,date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated --(RollingPeopleVaccinated/population)*100
From [Portfolio Projects]..CovidDeaths dea
join [Portfolio Projects]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

)
Select *, (RollingPeopleVaccinated/population)*100 as PercentageVaccinated
from PopvsVac

--- Using Temp Table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated --(RollingPeopleVaccinated/population)*100
From [Portfolio Projects]..CovidDeaths dea
join [Portfolio Projects]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--- Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated --(RollingPeopleVaccinated/population)*100
From [Portfolio Projects]..CovidDeaths dea
join [Portfolio Projects]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null