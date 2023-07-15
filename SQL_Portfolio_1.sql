--SELECT location, total_cases, new_cases, total_deaths, ROUND((total_deaths/total_cases)*100,4) AS death_percentage FROM PortfolioProjekt..CovidDeaths
--ORDER BY location, total_cases ASC;
----WHERE location LIKE '%Czechia%'
----ORDER BY total_cases ASC;

--SELECT * FROM PortfolioProjekt..CovidVaccinations
--ORDER BY 3,4;


--XXXXX Pom�r naka�en�ch dle populace zem�
SELECT location, total_cases, date, new_cases, total_deaths, population, (total_cases/population) AS nakazena_populace FROM PortfolioProjekt..CovidDeaths
WHERE location LIKE '%Czechia%' AND total_deaths != 'NULL' AND new_cases > 0
ORDER BY total_cases DESC;


--XXXXX Kter� zem� m� nejv�t�� pom�r naka�en�ch �e�en� 1
--SELECT location, total_cases, date, new_cases, total_deaths, population, (total_cases/population) AS pom�r_naka�en�ch FROM PortfolioProjekt..CovidDeaths
--WHERE date = '2021-04-30'
--ORDER BY (total_cases/population) DESC;

--XXXXX Kter� zem� m� nejv�t�� pom�r naka�en�ch �e�en� 2
SELECT location, population, MAX(total_cases) AS Nejv�t��_po�et_naka�en�ch, MAX((total_cases/population)*100) AS max_pom�r_naka�en�ch FROM PortfolioProjekt..CovidDeaths
GROUP BY location, population
order by max_pom�r_naka�en�ch DESC;


--XXXX Kter� zem� m� nejv�t�� po�et �mrt� na populaci
---Chyba s datov�m typem, musel se p�ed�lat total_deaths jako int
SELECT location, MAX(cast(total_deaths as int)) AS umrt�  FROM PortfolioProjekt..CovidDeaths
WHERE continent IS NOT NULL --Proto�e do datasetu se pak serou kontinenty 
GROUP BY location
ORDER BY umrt� DESC;


----Po�ad� dle kontitnentu
SELECT continent, MAX(cast(total_deaths as int)) AS umrt�  FROM PortfolioProjekt..CovidDeaths
WHERE continent IS NOT NULL --Proto�e do datasetu se pak serou kontinenty 
GROUP BY continent
ORDER BY umrt� DESC;

----Global numbers
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS death_ratio FROM PortfolioProjekt..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2


-- Looking at total population vs vaccinations

--USE CTE
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations ,Vaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date)
AS Vaccinated--, (Vaccinated/dea.population)*100  
FROM PortfolioProjekt..CovidDeaths dea
JOIN PortfolioProjekt..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.continent = vac.continent
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--order by 2,3
)
SELECT *, (Vaccinated/Population)*100 AS Vacc_per_pop
FROM PopvsVac




-- TEMP TABLE

CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Vaccinated numeric
)

INSERT into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date)
AS Vaccinated--, (Vaccinated/dea.population)*100  
FROM PortfolioProjekt..CovidDeaths dea
JOIN PortfolioProjekt..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.continent = vac.continent
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--order by 2,3

SELECT *, (Vaccinated/Population)*100 AS Vacc_per_pop
FROM #PercentPopulationVaccinated


-- Creating view to store date for later visualizations

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date)
AS Vaccinated--, (Vaccinated/dea.population)*100  
FROM PortfolioProjekt..CovidDeaths dea
JOIN PortfolioProjekt..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.continent = vac.continent
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--order by 2,3