SELECT *
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--Selecting the necessary columns

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--Total Deaths vs Total Cases

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE location LIKE  '%India%'
AND continent IS NOT NULL
ORDER BY 1,2

--Total Cases vs Population

SELECT Location, date, population, total_cases, (total_cases/population)*100 AS CovidCasePercentage
FROM CovidDeaths
WHERE location LIKE  '%India%'
AND continent IS NOT NULL
ORDER BY 1,2

--Country which is highly infected compared to population

SELECT Location, population, MAX(total_cases) AS HighestInfectedCount, MAX((total_cases/population))*100 AS MaxCovidCasePercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location, population
ORDER BY MaxCovidCasePercentage DESC

--Countries with highest death count per population

SELECT Location, MAX(cast(total_deaths AS int)) AS HighestDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY HighestDeathCount DESC

--Continents with highest death count per population

SELECT continent, MAX(cast(total_deaths AS int)) AS HighestDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY HighestDeathCount DESC

-- GLOBAL NUMBERS

SELECT SUM(new_cases) AS TotalCases, SUM(cast(new_deaths AS INT)) AS TotalDeaths,
				SUM(cast(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent is not null 
--This gives how many cases, death and its percentage across the Globe.

--CovidVaccinations

SELECT *
FROM CovidVaccinations

--Total Population Vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	   SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
From CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	On dea.location = vac.location
	AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--Total People Vaccinated in each country compared to population

Select dea.location, dea.population,SUM(CONVERT(int,vac.new_vaccinations))  AS TotalPeopleVaccinated
From CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	On dea.location = vac.location
	AND dea.date = vac.date 
GROUP BY dea.location, dea.population
ORDER BY 1

--Population VS Vaccinated Percentage

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	  SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
From CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	On dea.location = vac.location
	AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL
)

SELECT *, (RollingPeopleVaccinated/population)*100 AS PeopleVaccinatedPercentage
FROM PopvsVac


--Creating Temporary Tables

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
ORDER BY 2

SELECT *, (RollingPeopleVaccinated/Population)*100 AS PeopleVaccinatedPercentage
FROM #PercentPopulationVaccinated


--Create Views

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 

SELECT *
FROM PercentPopulationVaccinated

