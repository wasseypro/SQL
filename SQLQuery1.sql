--Covid-19 data exploration

--Skills used Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions,
--Creating views, Converting Data Types

Select *
From PortfolioProject..[Covid-Deaths]
where continent is not null 
order by 3,4

--Select Data that we are going to be starting with

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..[Covid-Deaths]
where continent is not null
order by 1,2

--Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..[Covid-Deaths]
where location like '%india%'
and continent is not null
order by 1,2

--Total Cases vs Population
--Shows what percentage of population infected with Covid

Select location, date, population,total_cases,(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..[Covid-Deaths]
--Where location like '%india%'
order by 1,2

--Countries with Highest Infection Rate compared to Population

Select location, population, date, MAX(total_cases) as HighInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..[Covid-Deaths]
--Where location like '%india%'
Group by location, population, date
order by PercentPopulationInfected desc

--Countries with highest death count per population

Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..[Covid-Deaths]
--Where location like '%india%'
where continent is not null
Group by location
order by TotalDeathCount desc


--Total death count excluding World, European Union, International
Select location, Sum(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..[Covid-Deaths]
--Where location like '%india%'
where continent is null
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


--NOW EXPLORING CONTINENT
--Showing continents with the highest death count per population

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..[Covid-Deaths]
Where continent is not null
Group by continent
order by TotalDeathCount desc

--Global Numbers

Select Sum(new_cases) as total_cases, Sum(cast(new_deaths as int))as total_deaths,
Sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
From PortfolioProject..[Covid-Deaths]
where continent is not null
order by 1,2

--Total Population vs Vaccination
--Shows Percentage of Population that has received at least one covid vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(Cast(vac.new_vaccinations as int)) Over (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated
From PortfolioProject..[Covid-Deaths] dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Using CTE to perform Calculation on Partition by in previous query

with PopvsVac (continent, location, date,population, new_vaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
Sum(Cast(vac.new_vaccinations as int)) Over (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated
From PortfolioProject..[Covid-Deaths] dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *,(RollingPeopleVaccinated/Population)*100
From PopvsVac

--Using Temp Table to perform calculation on Partition by in Previous query

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Convert(Bigint,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated
From PortfolioProject..[Covid-Deaths] dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

Select *,(RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated