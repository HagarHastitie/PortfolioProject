select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4 

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4 

select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths

select location, date, total_cases, total_deaths, 
(convert(float,total_deaths)/convert(float,total_cases))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%indonesia%'
order by 1,2

-- Looking at Total Cases vs Populations
-- Shows what percentage of population got covid
select location, date, population, total_cases, 
(convert(float,total_cases)/convert(float,population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%indonesia%'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

select location, population, max(total_cases) as HighestInfectionCount,
max((convert(float,total_cases)/convert(float,population))*100) as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%indonesia%'
group by location, population
order by PercentPopulationInfected desc

-- Showing Contries with Highest Death Count per Population

select location, max(cast(total_deaths as float)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%indonesia%'
where continent is not null
group by location
order by TotalDeathCount desc

-- let's break things down by continent



-- Showing continent with the highest death count per population

select continent, max(cast(total_deaths as float)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%indonesia%'
where continent is not null
group by continent
order by TotalDeathCount desc

-- Global Number

select sum(cast(new_cases as float)) as total_cases, sum(cast(new_deaths as float)) as total_deaths,
(sum(convert(float,new_deaths))/sum(convert(float,new_cases))*100) as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%indonesia%'
where continent is not null
--group by date
order by 1,2



-- Looking at Total Population vs Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(float, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(float, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac


-- TEMP TABLE

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(float, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


-- Creating View to store data for later visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(float, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated
