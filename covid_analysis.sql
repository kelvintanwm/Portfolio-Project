SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

-- Select the data for analysis

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract Covid in Singapore
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM PortfolioProject..CovidDeaths
WHERE Location = 'Singapore'
ORDER BY 1,2

-- Looking at Total Cases vs Population
SELECT Location, date, total_cases, population, (total_cases/population)*100 as cases_percentage
FROM PortfolioProject..CovidDeaths
WHERE Location = 'Singapore'
ORDER BY 5 desc

-- Looking at countries with the highest infection rate compared to population
SELECT location, population, MAX(total_cases) as highest_infect_count, max((total_cases/population))*100 as infection_count_percentage 
FROM PortfolioProject..CovidDeaths
Group by location, population
ORDER BY 4 desc



-- Showing Countries with highest death count per population
SELECT location, population, MAX(cast(total_deaths as int)) as total_deaths_count
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
Group by location, population
ORDER BY 3 desc

-- Showing continents with highest death count per population
SELECT location, MAX(cast(total_deaths as int)) as total_deaths_count
FROM PortfolioProject..CovidDeaths
WHERE continent is null
Group by location
ORDER BY 2 desc


-- GLOABL NUMBERS

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as death_percentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 2

-- Looking at Total Population vs Vaccinations

Select D.continent, D.location, D.date, D.population, V.new_vaccinations,
SUM(CONVERT(int, V.new_vaccinations)) OVER (Partition by D.Location ORDER BY D.location, D.date) as rolling_vacinated_pop
FROM PortfolioProject..CovidVacc as V
JOIN PortfolioProject..CovidDeaths as D
ON V.location = D.location and V.date = D.date
WHERE D.continent is not null
ORDER BY 2,3


-- USING CTE
with PopvsVac (continent, location, date, population, new_vaccinations, rolling_vaccinated_pop)
as 
(
Select D.continent, D.location, D.date, D.population, V.new_vaccinations,
SUM(CONVERT(int, V.new_vaccinations)) OVER (Partition by D.Location ORDER BY D.location, D.date) as rolling_vacinated_pop
FROM PortfolioProject..CovidVacc as V
JOIN PortfolioProject..CovidDeaths as D
ON V.location = D.location and V.date = D.date
WHERE D.continent is not null)

select *, (rolling_vaccinated_pop/population)*100 as rolling_vaccinated_percentage
FROM PopvsVac




-- TEMP TABLE
DROP TABLE IF exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select D.continent, D.location, D.date, D.population, V.new_vaccinations,
SUM(CONVERT(int, V.new_vaccinations)) OVER (Partition by D.Location ORDER BY D.location, D.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths as D
JOIN PortfolioProject..CovidVacc as V
ON D.location = V.location and D.date = V.date
WHERE D.continent is not null

select *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- Creating view to store data for visualisations
Create view PercentPopulationVaccinated as 
Select D.continent, D.location, D.date, D.population, V.new_vaccinations,
SUM(CONVERT(int, V.new_vaccinations)) OVER (Partition by D.Location ORDER BY D.location, D.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths as D
JOIN PortfolioProject..CovidVacc as V
ON D.location = V.location and D.date = V.date
WHERE D.continent is not null

SELECT *
FROM PercentPopulationVaccinated
