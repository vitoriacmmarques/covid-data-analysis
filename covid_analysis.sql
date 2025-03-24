-- Seleciona todos os registros da tabela CovidDeaths
SELECT * FROM CovidDeaths;

-- Seleciona todos os registros da tabela CovidVaccinations
SELECT * FROM CovidVaccinations;

-- Seleciona a coluna location e continent da tabela CovidDeaths, filtrando apenas locais pertencentes ao continente asiático
SELECT location, continent
FROM CovidDeaths
WHERE continent LIKE '%Asia%';

-- Seleciona dados sobre casos, mortes e população no Brasil, ordenando por localização e data
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE location LIKE '%brazil%'
ORDER BY 1,2;

-- Calcula a porcentagem de mortalidade entre os casos confirmados no Brasil
SELECT location, 
       date, 
       total_cases, 
       total_deaths, 
       (total_deaths / total_cases) * 100 AS DeathPercentage
FROM CovidDeaths
WHERE location LIKE '%brazil%'
ORDER BY STR_TO_DATE(date, '%m/%d/%Y');

-- Calcula a porcentagem da população que foi infectada com Covid no Brasil
SELECT location, 
       date, 
       population,
       total_cases, 
       (total_cases / population) * 100 AS PercentPopulationInfected
FROM CovidDeaths
WHERE location LIKE '%brazil%'
ORDER BY STR_TO_DATE(date, '%m/%d/%Y');

-- Encontra os países com a maior taxa de infecção em relação à população
SELECT location,  
       population,
       MAX(total_cases) AS HighestInfectionCount, 
       MAX((total_cases / population) * 100) AS PercentPopulationInfected
FROM CovidDeaths
GROUP BY Location, population
ORDER BY PercentPopulationInfected DESC;

-- Exibe os países com o maior número total de mortes
SELECT Location,  
       MAX(CAST(NULLIF(Total_deaths, '') AS SIGNED)) AS TotalDeathCount
FROM CovidDeaths
WHERE NULLIF(continent, '') IS NOT NULL 
GROUP BY Location
ORDER BY TotalDeathCount DESC;

-- Exibe os continentes com o maior número total de mortes
SELECT continent,  
       MAX(CAST(NULLIF(Total_deaths, '') AS SIGNED)) AS TotalDeathCount
FROM CovidDeaths
WHERE NULLIF(continent, '') IS NOT NULL 
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- Exibe o número total de mortes por país, filtrando por continente
SELECT Location,  
       MAX(CAST(NULLIF(Total_deaths, '') AS SIGNED)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent LIKE '%Asia%' 
GROUP BY Location
ORDER BY TotalDeathCount DESC;

-- O mesmo processo para outros continentes
SELECT Location, MAX(CAST(NULLIF(Total_deaths, '') AS SIGNED)) AS TotalDeathCount FROM CovidDeaths WHERE continent LIKE '%Africa%' GROUP BY Location ORDER BY TotalDeathCount DESC;
SELECT Location, MAX(CAST(NULLIF(Total_deaths, '') AS SIGNED)) AS TotalDeathCount FROM CovidDeaths WHERE continent LIKE '%Oceania%' GROUP BY Location ORDER BY TotalDeathCount DESC;
SELECT Location, MAX(CAST(NULLIF(Total_deaths, '') AS SIGNED)) AS TotalDeathCount FROM CovidDeaths WHERE continent LIKE '%Europe%' GROUP BY Location ORDER BY TotalDeathCount DESC;
SELECT Location, MAX(CAST(NULLIF(Total_deaths, '') AS SIGNED)) AS TotalDeathCount FROM CovidDeaths WHERE continent LIKE '%South America%' GROUP BY Location ORDER BY TotalDeathCount DESC;
SELECT Location, MAX(CAST(NULLIF(Total_deaths, '') AS SIGNED)) AS TotalDeathCount FROM CovidDeaths WHERE continent LIKE '%North America%' GROUP BY Location ORDER BY TotalDeathCount DESC;

-- Calcula números globais de casos e mortes, incluindo a taxa de mortalidade
SELECT SUM(new_cases) AS total_cases, 
       SUM(CAST(NULLIF(new_deaths, '') AS SIGNED)) AS total_deaths, 
       SUM(CAST(NULLIF(new_deaths, '') AS SIGNED)) / SUM(new_cases) * 100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- Consulta principal que mostra a população em relação à vacinação
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(CAST(COALESCE(vac.new_vaccinations, 0) AS UNSIGNED)) 
        OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY dea.location, dea.date;

-- Usando CTE para calcular a taxa de vacinação
WITH PopvsVac AS (
    SELECT 
        dea.continent, 
        dea.location, 
        dea.date, 
        dea.population, 
        vac.new_vaccinations,
        SUM(CAST(COALESCE(vac.new_vaccinations, 0) AS UNSIGNED)) 
            OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
    FROM CovidDeaths dea
    JOIN CovidVaccinations vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL 
)
SELECT *, (RollingPeopleVaccinated / Population) * 100 AS VaccinationRate
FROM PopvsVac;
