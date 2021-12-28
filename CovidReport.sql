SELECT *
FROM Projects..['covid-deaths$']
WHERE continent is not NULL
ORDER BY 3,4

--SELECT *
--FROM Projects..['covid-vaccinations$']
--ORDER BY 3,4

--Selecting data to be used
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM Projects.dbo.['covid-deaths$']
ORDER BY 1,2

--Looking at Total Cases Vs Total Deaths
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercent
FROM Projects.dbo.['covid-deaths$']
WHERE location like 'India'
ORDER BY 1,2

--Looking at Total Cases Vs Population and showing what percentage of people got Covid
SELECT Location, date, total_cases, population, (total_cases/population)*100 AS Percentpopulationinfected
FROM Projects.dbo.['covid-deaths$']
--WHERE location like 'India'
ORDER BY 1,2

--Looking at Countries with Highest Infection Rate compared to Population
SELECT Location, MAX(total_cases) AS HighestInfectionCount, population, MAX((total_cases/population))*100 AS Percentpopulationinfected
FROM Projects.dbo.['covid-deaths$']
--WHERE location like 'India'
GROUP BY Location, population
ORDER BY Percentpopulationinfected desc

--Showing Countries with Highest Death Count per Population
SELECT Location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM Projects.dbo.['covid-deaths$']
--WHERE location like 'India'
WHERE continent is not NULL
GROUP BY Location
ORDER BY TotalDeathCount desc

--Showing continents with the highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM Projects.dbo.['covid-deaths$']
WHERE continent is not NULL 
GROUP BY continent
ORDER BY TotalDeathCount desc

--GLOBAL NUMBERS
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int)) / SUM(New_Cases)*100 AS DeathPercent
FROM Projects.dbo.['covid-deaths$']
WHERE continent is not NULL
ORDER BY 1,2

--Looking at Total Population VS Vaccinations
With PopvsVac (Continent, Location, Date, Population, new_vaccinations, TotalPeopleVaccinated)
AS
(
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccine.new_vaccinations
, SUM(CAST(vaccine.new_vaccinations AS bigint)) OVER (Partition By  deaths.location 
  ORDER BY deaths.location, deaths.date) AS TotalPeopleVaccinated
FROM Projects.dbo.['covid-deaths$'] AS deaths
JOIN Projects.dbo.['covid-vaccinations$'] AS vaccine
	ON deaths.location = vaccine.location
	AND deaths.date = vaccine.date
WHERE deaths.continent is not NULL
)
SELECT *, (TotalPeopleVaccinated/Population)*100 AS Percentofvacccinated
FROM PopvsVac

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
TotalPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccine.new_vaccinations 
, SUM(CAST(vaccine.new_vaccinations AS bigint)) OVER (Partition By  deaths.location 
  ORDER BY deaths.location, deaths.date) AS TotalPeopleVaccinated
FROM Projects.dbo.['covid-deaths$'] AS deaths
JOIN Projects.dbo.['covid-vaccinations$'] AS vaccine
	ON deaths.location = vaccine.location
	AND deaths.date = vaccine.date
SELECT *, (TotalPeopleVaccinated/Population)*100 AS Percentofvacccinated
FROM #PercentPopulationVaccinated


--Creating View
CREATE VIEW PercentPopulationVaccinated 
AS
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccine.new_vaccinations
, SUM(CAST(vaccine.new_vaccinations AS bigint)) OVER (Partition By  deaths.location 
  ORDER BY deaths.location, deaths.date) AS TotalPeopleVaccinated
FROM Projects.dbo.['covid-deaths$'] AS deaths
JOIN Projects.dbo.['covid-vaccinations$'] AS vaccine
	ON deaths.location = vaccine.location
	AND deaths.date = vaccine.date
WHERE deaths.continent is not NULL

SELECT * 
FROM PercentPopulationVaccinated