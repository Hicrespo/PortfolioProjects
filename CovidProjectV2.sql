/*

Covid Data Exploration


Skills Used for Exploration: Aggregate Functions, Temp tables, joins, Creating views, CTE's, Data type converting

*/



-- Checking the death files


Select *
From PortfolioProject..CovidDeaths
Order by 3, 4


-- Checking the vaccinations files


Select *
From PortfolioProject..CovidVaccinations
Order by 3, 4



-- Select data that we are going to start off with


Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1, 2



-- Total cases vs Total deaths 
-- Probability of dying if covid is contracted


Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
and continent is not null
Order by 1, 2



-- looking at the total cases vs population
-- What percentage of the population contracted covid


Select location, date, total_cases, population, (total_cases/population)*100 as PercentOfPopultionInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%' and continent is not null
Order by 1, 2


-- Countries with the highest rate of covid compared to population


Select location, population, MAX(total_cases)as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location, population
Order by PercentPopulationInfected desc



-- Countries with the highest death count per population

Select location, Max(Cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location
Order by TotalDeathCount desc



-- By continent


Select continent, Max(Cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc



-- Globally


Select date, Sum(new_cases) as TotalCases, Sum(cast(new_deaths as int)) as TotalDeaths,  Sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by date 
Order by 1, 2



-- Total population vs vaccinations
-- Show the Percentage of the Population that has gotten at least 1 of the vaccinations


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) As PeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3 


-- CTE to Perform Calculations


With PopuvsVac (continent, location, date, population, new_vaccinations, PeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) As PeopleVaccinated
--, (PeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3 
)
select *, (PeopleVaccinated/population)*100
from PopuvsVac



--Temp table for calculations


Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
PeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) As PeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3 

Select *, (PeopleVaccinated/population)*100 as percentvac
From #PercentPopulationVaccinated


-- Creating view to store data 


Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) As PeopleVaccinated
--, (PeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select*
From PercentPopulationVaccinated
