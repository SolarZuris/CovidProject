SELECT * 
FROM CovidProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidProject..CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidProject..CovidDeaths
--WHERE Location LIKE '%states%'
WHERE continent is not null
ORDER BY 1,2

-- Looking at Total Cases vs Population
SELECT Location, date, total_cases, population, (total_cases/population)*100 AS PercentagePopulation
FROM CovidProject..CovidDeaths
--WHERE Location LIKE '%states%'
WHERE continent is not null
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate compared to population
SELECT Location, population,date, MAX(total_cases) AS HighestInfectionCount , MAX((total_cases/population)*100) AS PercentagePopulationInfected
FROM CovidProject..CovidDeaths
--WHERE Location LIKE '%states%'
WHERE continent is not null
GROUP BY
	Location,
	population,
	date
ORDER BY PercentagePopulationInfected desc

-- Showing Countries with Highest Death Count per Population
SELECT Location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM CovidProject..CovidDeaths
--WHERE Location LIKE '%states%'
WHERE continent is not null
GROUP BY
	Location
ORDER BY TotalDeathCount desc

-- Showing Continent with Highest Death Count per Population
SELECT continent, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM CovidProject..CovidDeaths
--WHERE Location LIKE '%states%'
WHERE continent is not null
GROUP BY
	continent
ORDER BY TotalDeathCount desc

-- Global Numbers
SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM CovidProject..CovidDeaths
--WHERE Location LIKE '%states%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2


-- Looking at Total Population vs Vaccinations

WITH PopVsVac 
(	continent,
	location,
	date,
	population,
	new_vaccinations,
	RollingPeopleVaccinated) AS
(
Select
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION by dea.location
	ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100
FROM CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopVsVac

-- USE CTE



--TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar (255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION by dea.location
	ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100
FROM CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

-- Creating View for visualizations
CREATE VIEW PercentPopulationVaccinated AS
Select
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION by dea.location
	ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100
FROM CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

-- Tables that we require for Data Visualization
-- 1.
SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM CovidProject..CovidDeaths
--WHERE Location LIKE '%states%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

-- 2.
SELECT Location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM CovidProject..CovidDeaths
--WHERE Location LIKE '%states%'
WHERE continent is null
and location not in ('World','European Union', 'International','High income', 'Upper middle income','Lower middle income','Low income')
GROUP BY
	Location
ORDER BY TotalDeathCount desc

-- 3.
SELECT Location, population, MAX(total_cases) AS HighestInfectionCount , MAX((total_cases/population)*100) AS PercentagePopulationInfected
FROM CovidProject..CovidDeaths
--WHERE continent is not null
GROUP BY
	Location,
	population
ORDER BY PercentagePopulationInfected desc

-- 4.
SELECT Location, population,date, MAX(total_cases) AS HighestInfectionCount , MAX((total_cases/population)*100) AS PercentagePopulationInfected
FROM CovidProject..CovidDeaths
--WHERE Location LIKE '%states%'
WHERE continent is not null
GROUP BY
	Location,
	population,
	date
ORDER BY PercentagePopulationInfected desc

