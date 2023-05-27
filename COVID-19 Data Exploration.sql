--View table CovidDeaths
SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

--View table CovidVaccinations
SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4

--ALTER TABLE PortfolioProject..CovidDeaths
--ALTER COLUMN total_cases int

--ALTER TABLE PortfolioProject..CovidDeaths
--ALTER COLUMN total_deaths int

--Infection rate for Malaysia
SELECT location, date, population, total_cases, CAST(total_cases AS int)/population*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location = 'Malaysia' AND continent IS NOT NULL
ORDER BY 2

--Death rate for Malaysia
SELECT location, date, total_cases, total_deaths, CAST(total_deaths AS float)/CAST(total_cases AS float)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'Malaysia' AND continent IS NOT NULL
ORDER BY 2

--Highest infection count and infection rate by country
SELECT location, population, MAX(CAST(total_cases AS int)) AS HighestInfectionCount, MAX(CAST(total_cases AS int)/population*100) AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--Highest death count and death rate by country
SELECT location, population, MAX(CAST(total_deaths AS int)) AS TotalDeathCount, MAX(CAST(total_deaths AS int)/population*100) AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY DeathPercentage DESC

--Highest infection count by continent
SELECT continent, MAX(CAST(total_cases AS int)) AS HighestInfectionCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY HighestInfectionCount DESC

--Highest death count by continent
SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Global numbers
SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL

--Vaccination rate using Common Table Expression
With PopvsVac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)

SELECT *, RollingPeopleVaccinated/population*100 AS RollingVaccinationRate
FROM PopvsVac
ORDER BY 2,3

--Vaccination rate using Temp Table
DROP TABLE IF EXISTS #PercentPopulationVaccinated

CREATE TABLE #PercentPopulationVaccinated(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population int,
new_vaccinations int,
RollingPeopleVaccinated bigint
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, RollingPeopleVaccinated/population*100 AS RollingVaccinationRate
FROM #PercentPopulationVaccinated
ORDER BY 2, 3

--Create View
CREATE OR ALTER VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL