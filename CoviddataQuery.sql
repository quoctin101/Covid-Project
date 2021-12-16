select * 
From CovidDeaths
order by 3,4;

select * 
From CovidVaccinations
order by 3,4;


--Select data we are using

select Location, date, total_cases, new_cases,total_deaths, population
From CovidDeaths
order by 1,2

-- Total case vs Total death(adding locaiton to check for United state)

select Location, date, total_cases, total_deaths,
(total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths
Where location like '%states%'
order by 1,2


--select Location, date, total_cases, total_deaths,
--(total_deaths/total_cases)*100 as deathrate
--From CovidDeaths
--Where location like '%Vietnam%'
--order by 1,2

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid
select Location, date, total_cases, total_deaths,
(total_cases/population)*100 as PercentPopulationInfected
From CovidDeaths
Where location like '%states%'
order by 1,2;


-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
Group by Location, population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population

Select Location, Population, MAX(total_deaths) as HighestDeathCount,  Max((total_deaths/population))*100 as PercentPopulationDeath
From CovidDeaths
--where location like '%states%'
Group by Location, population
order by PercentPopulationDeath desc;



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc



--GLOBAL NUMBERS

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPrecentage--, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
Where continent is not null

group by date
order by 1,2



-- Loking at Total Population vs Vaccinations
Select dea.continent,dea.location, dea.date, dea.population,vac.new_vaccinations 
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date	= vac.date
Where dea.continent is not null
order by 2,3



Select dea.continent, dea.location, cast(dea.date as date), dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3




-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

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
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated