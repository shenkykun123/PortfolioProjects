--select * 
--from PortFolioProject..CovidDeath

--select * 
--from PortFolioProject..CovidVaccination

Select Location, date, total_cases, new_cases, total_deaths, population
from PortFolioProject..CovidDeath
order by 1,2

Select Location, date, total_cases, total_deaths, (TRY_CAST(total_deaths AS numeric(10, 2))
/TRY_CAST(total_cases AS numeric(10, 2)))*100 
from PortFolioProject..CovidDeath
where location like '%states%'
order by 1,2 


Select Location, date, total_cases, population, (TRY_CAST(total_cases AS numeric(10, 2))
/TRY_CAST(population AS numeric(10, 2)))*100 
from PortFolioProject..CovidDeath
where location like '%states%'
order by 1,2 

--looking at countries with highest infection rate compare to population

Select Location, population, Max(total_cases) as highestInfectionCount, 
Max((TRY_CAST(total_cases AS numeric(10, 2))
/TRY_CAST(population AS numeric(10, 2)))*100) as PercentPopulationInfection 
from PortFolioProject..CovidDeath
--where location like '%states%'
Group by Location, population
order by PercentPopulationInfection desc

--showing Countries with the highest Death Count per population

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from PortFolioProject..CovidDeath
--where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

--Global Numbers

Select sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, 
Sum(cast(new_deaths as int))/Nullif(sum(new_cases),0)*100 as DeathPercentage
from PortFolioProject..CovidDeath
--where location like '%states%'
Where continent is not null
--Group by date
order by 1,2 

--Looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, 
vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as numeric(12,0))) OVER (partition by dea.location 
order by dea.location, Dea.Date) as RollingPeopleVaccinated
From PortFolioProject..CovidDeath dea
join PortFolioProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where vac.new_vaccinations is not null
order by 2,3


--Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, 
vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as numeric(12,0))) OVER (partition by dea.location 
order by dea.location, Dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVaccination vac
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
select dea.continent, dea.location, dea.date, dea.population, 
vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as numeric(12,0))) OVER (partition by dea.location 
order by dea.location, Dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, 
vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as numeric(12,0))) OVER (partition by dea.location 
order by dea.location, Dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

