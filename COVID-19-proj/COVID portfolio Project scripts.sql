SELECT * 
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
Order BY 3,4

--SELECT * 
--FROM PortfolioProject..CovidVaccinations
--Order BY 3,4

--Select Data that we are going to be using 
Select Location, date, total_cases, new_cases,total_deaths,population
From PortfolioProject..CovidDeaths
Order BY 1,2 

-- Looking at Total Caeses vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country 
Select Location, date, total_cases,total_deaths,(total_deaths/total_cases) * 100 as DeathPercentage
From PortfolioProject..CovidDeaths
WHERE location like '%Canada%'
Order BY 1,2 


-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid 
Select Location, date, Population,total_cases,(total_cases/population) * 100 as PercentPopulationInfected 
From PortfolioProject..CovidDeaths
-- WHERE location like '%Canada%'
Order BY 1,2 


-- Looking at Countries with highest Infection Rate compared to Population
Select Location,Population,MAX(total_cases) AS HighestInfectionCount,MAX((total_cases/population)) * 100 as PercentPopulationInfected 
From PortfolioProject..CovidDeaths
-- WHERE location like '%Canada%'
GROUP BY Location, Population
Order BY PercentPopulationInfected desc


-- LET'S BREAK THINGS DOWN MY CONTINENT



-- Showing continents with the highest death count per population


Select continent, MAX(cast(Total_deaths as Int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
-- WHERE location like '%Canada%'
WHERE continent is not null
GROUP BY continent 
Order BY TotalDeathCount desc


--  GLOBAL NUMBERS 

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,  SUM(cast(new_deaths as int)) / SUM(New_cases) * 100 as DeathPercentage
From PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
Order BY 1,2 


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
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
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From  PopvsVac


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


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea  
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
