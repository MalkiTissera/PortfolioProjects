select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

--Select Data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contact covid in Australia

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%Austra%'
and continent is not null
order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got covid

select location, date, total_cases, population, (total_cases/population)*100 as InfectedPercentage
from PortfolioProject..CovidDeaths
--where location like '%Austra%'
where continent is not null
order by 1,2


--Looking at countries with Highest Infection Rate conpared to Population

select location, population, MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population))*100 as InfectedPercentage
from PortfolioProject..CovidDeaths
--where location like '%Austra%'
where continent is not null
Group by location, population
order by InfectedPercentage desc


--Showing Countries with Highest Death Count

select location, MAX(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProject..CovidDeaths
--where location like '%Austra%'
where continent is not null
Group by location
order by HighestDeathCount desc


--LET'S BREAK THINGS DOWN BY CONTINENT

select location, MAX(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProject..CovidDeaths
--where location like '%Austra%'
where continent is null
Group by location
order by HighestDeathCount desc


--GLOBAL NUMBERS

--Daily Death Percentage

select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

--Total Death Percentage

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2


--JOINING COVID DEATHS AND VACCINATION DATA

--Looking at Total Population vs Vaccinations

select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(CONVERT(int,cv.new_vaccinations)) OVER (Partition by cd.location, cd.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as cd
join PortfolioProject..CovidVaccinations as cv
	on cd.location = cv.location
	and cd.date = cd.date
where cd.continent is not null
order by 2,3

-- USE CTE

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(CONVERT(int,cv.new_vaccinations)) OVER (Partition by cd.location, cd.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as cd
join PortfolioProject..CovidVaccinations as cv
	on cd.location = cv.location
	and cd.date = cd.date
where cd.continent is not null
)
select *,(RollingPeopleVaccinated/population)*100
from PopvsVac


--TEMP TABLE
DROP Table if exists #PopulationVaccinatePercentage
create table #PopulationVaccinatePercentage
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PopulationVaccinatePercentage
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(CONVERT(bigint,cv.new_vaccinations)) OVER (Partition by cd.location, cd.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as cd
join PortfolioProject..CovidVaccinations as cv
	on cd.location = cv.location
	and cd.date = cd.date

select *,(RollingPeopleVaccinated/population)*100
from #PopulationVaccinatePercentage



--Creating View to store data for later visualizations

Use PortfolioProject
GO
Create view PopulationVaccinatPercentage as
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(CONVERT(bigint,cv.new_vaccinations)) OVER (Partition by cd.location order by cd.location,
cd.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as cd
join PortfolioProject..CovidVaccinations as cv
	on cd.location = cv.location
	and cd.date = cd.date
where cd.continent is not null


select *
from PopulationVaccinatPercentage