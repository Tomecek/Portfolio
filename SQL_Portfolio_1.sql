--SELECT location, total_cases, new_cases, total_deaths, ROUND((total_deaths/total_cases)*100,4) AS death_percentage FROM PortfolioProjekt..CovidDeaths
--ORDER BY location, total_cases ASC;
----WHERE location LIKE '%Czechia%'
----ORDER BY total_cases ASC;

--SELECT * FROM PortfolioProjekt..CovidVaccinations
--ORDER BY 3,4;


--XXXXX Pomer nakažených dle populace zeme
SELECT location, total_cases, date, new_cases, total_deaths, population, (total_cases/population) AS nakazena_populace FROM PortfolioProjekt..CovidDeaths
WHERE location LIKE '%Czechia%' AND total_deaths != 'NULL' AND new_cases > 0
ORDER BY total_cases DESC;


--XXXXX Která zeme má nejvetší pomer nakažených rešení 1
--SELECT location, total_cases, date, new_cases, total_deaths, population, (total_cases/population) AS pomìr_nakažených FROM PortfolioProjekt..CovidDeaths
--WHERE date = '2021-04-30'
--ORDER BY (total_cases/population) DESC;

--XXXXX Která zeme má nejvetší pomer nakažených rešení 2
SELECT location, population, MAX(total_cases) AS Nejvìtší_poèet_nakažených, MAX((total_cases/population)*100) AS max_pomìr_nakažených FROM PortfolioProjekt..CovidDeaths
GROUP BY location, population
order by max_pomìr_nakažených DESC;


--XXXX Která zeme má nejvetší pocet úmrtí na populaci
---Chyba s datovým typem, musel se predìlat total_deaths jako int
SELECT location, MAX(cast(total_deaths as int)) AS umrtí  FROM PortfolioProjekt..CovidDeaths
WHERE continent IS NOT NULL --Protože do datasetu se pak serou kontinenty 
GROUP BY location
ORDER BY umrtí DESC;


----Poradí dle kontitnentu
SELECT continent, MAX(cast(total_deaths as int)) AS umrtí  FROM PortfolioProjekt..CovidDeaths
WHERE continent IS NOT NULL --Protože do datasetu se pak serou kontinenty 
GROUP BY continent
ORDER BY umrtí DESC;

----Pocet globalne
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS death_ratio FROM PortfolioProjekt..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2


-- Populace vs Vakcinace

-- CTE
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


-- View pro pozdejsi vizualizace

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
