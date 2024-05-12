Create Database PortfolioProject;

Use PortfolioProject;

select * from CovidDeaths
where continent is not NULL
order by 3,4;

select * from CovidVaccination
order by 3,4;

--looking at total cases vs total deaths
--Shows likelihood of dying if you contract covid in your country.

select LOCATION, DATE, total_cases, new_cases, total_deaths,
(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%' and 
continent is not NULL
ORDER by 1,2;

--looking at total cases vs population
select LOCATION, DATE, total_cases, new_cases, population,
(total_cases/population)*100 as PercentageOfPopulation
from PortfolioProject..CovidDeaths
--where location like '%states%'
ORDER by 1,2;

--looking at country with highest infection rate
select LOCATION, population, 
Max(total_cases) as highestinfectioncount,
 Max((total_cases/population))*100 as PercentageOfPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%states%'
group by LOCATION, population
ORDER by 1,2;

--showing countries with highest death count per population

select LOCATION,MAX(cast(total_deaths as INT)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not NULL
group by LOCATION
ORDER by TotalDeathCount Desc;

-- Let's Break things down by continent
--showing continent with the highest death count per population
Select continent ,MAX(cast(total_deaths as INT)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not NULL
group by continent
ORDER by TotalDeathCount Desc;

--global numbers
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as INT)) as total_deaths, SUM(cast(new_deaths as INT))/ SUM(new_cases) * 100 as deathpercentage
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not NULL
--group by date
order by 1,2;

-- looking at total population vs vaccinations
SELECT dea.continent, dea.LOCATION, dea.date, dea.population,
vac.new_vaccinations, 
SUM(Convert(int, vac.new_vaccinations)) 
OVER (Partition by dea.location)as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
GROUP BY dea.continent, dea.LOCATION, dea.date, dea.population,
vac.new_vaccinations
ORDER BY dea.LOCATION, dea.date;

--USE CTE
WITH PopvsVac(Continent, Location, Date, Population,
new_vaccinations, RollingPeopleVaccinated)
as (
SELECT dea.continent, dea.LOCATION, dea.date, dea.population,
vac.new_vaccinations, 
SUM(Convert(int, vac.new_vaccinations)) 
OVER (Partition by dea.location)as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
GROUP BY dea.continent, dea.LOCATION, dea.date, dea.population,
vac.new_vaccinations
--ORDER BY dea.LOCATION, dea.date
)
select *, (RollingPeopleVaccinated/Population)* 100 
from PopvsVac;

--TEMP Table
DROP TABLE IF EXISTS #PercentPopulationVaccinate;

CREATE TABLE #PercentPopulationVaccinate
(
    Continent NVARCHAR(255),
    LOCATION NVARCHAR(255),
    DATE DATETIME,
    Population NUMERIC(18, 2), -- Adjust precision and scale as per your data
    New_vaccinations NUMERIC(18, 2), -- Adjust precision and scale as per your data
    RollingPeopleVaccinated NUMERIC(18, 2) -- Adjust precision and scale as per your data
);

INSERT INTO #PercentPopulationVaccinate
SELECT 
    dea.continent, 
    dea.LOCATION, 
    dea.date, 
    dea.population,
    vac.new_vaccinations, 
    SUM(CONVERT(NUMERIC(18, 2), vac.new_vaccinations)) 
        OVER (PARTITION BY dea.location) AS RollingPeopleVaccinated
FROM 
    PortfolioProject..CovidDeaths dea
JOIN 
    PortfolioProject..CovidVaccination vac
ON 
    dea.location = vac.location
    AND dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL;

SELECT * FROM #PercentPopulationVaccinate;

--creating view to store data for later visualizations

create view  PercentPopulationVaccinate as 
SELECT  dea.continent, dea.LOCATION, dea.date, 
dea.population, vac.new_vaccinations, 
SUM(CONVERT(NUMERIC(18, 2), vac.new_vaccinations)) 
OVER (PARTITION BY dea.location) AS RollingPeopleVaccinated
FROM  PortfolioProject..CovidDeaths dea
JOIN  PortfolioProject..CovidVaccination vac
ON  dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

select * from PercentPopulationVaccinate;












