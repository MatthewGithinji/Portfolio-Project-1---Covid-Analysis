
CREATE TABLE covid_deaths (
    iso_code VARCHAR(10),
    continent VARCHAR(50),
    location VARCHAR(100),
    date DATE,
    population BIGINT,
    total_cases BIGINT,
    new_cases BIGINT,
    new_cases_smoothed FLOAT,
    total_deaths BIGINT,
    new_deaths BIGINT,
    new_deaths_smoothed FLOAT,
    total_cases_per_million FLOAT,
    new_cases_per_million FLOAT,
    new_cases_smoothed_per_million FLOAT,
    total_deaths_per_million FLOAT,
    new_deaths_per_million FLOAT,
    new_deaths_smoothed_per_million FLOAT,
    reproduction_rate FLOAT,
    icu_patients BIGINT,
    icu_patients_per_million FLOAT,
    hosp_patients BIGINT,
    hosp_patients_per_million FLOAT,
    weekly_icu_admissions FLOAT,
    weekly_icu_admissions_per_million FLOAT,
    weekly_hosp_admissions FLOAT,
    weekly_hosp_admissions_per_million FLOAT
);

SELECT * FROM covid_deaths;

CREATE TABLE covid_vaccinations (
    iso_code VARCHAR(10),
    continent VARCHAR(50),
    location VARCHAR(100),
    date DATE,
    new_tests BIGINT,
    total_tests BIGINT,
    total_tests_per_thousand FLOAT,
    new_tests_per_thousand FLOAT,
    new_tests_smoothed BIGINT,
    new_tests_smoothed_per_thousand FLOAT,
    positive_rate FLOAT,
    tests_per_case FLOAT,
    tests_units VARCHAR(50),
    total_vaccinations BIGINT,
    people_vaccinated BIGINT,
    people_fully_vaccinated BIGINT,
    new_vaccinations BIGINT,
    new_vaccinations_smoothed BIGINT,
    total_vaccinations_per_hundred FLOAT,
    people_vaccinated_per_hundred FLOAT,
    people_fully_vaccinated_per_hundred FLOAT,
    new_vaccinations_smoothed_per_million FLOAT,
    stringency_index FLOAT,
    population_density FLOAT,
    median_age FLOAT,
    aged_65_older FLOAT,
    aged_70_older FLOAT,
    gdp_per_capita FLOAT,
    extreme_poverty FLOAT,
    cardiovasc_death_rate FLOAT,
    diabetes_prevalence FLOAT,
    female_smokers FLOAT,
    male_smokers FLOAT,
    handwashing_facilities FLOAT,
    hospital_beds_per_thousand FLOAT,
    life_expectancy FLOAT,
    human_development_index FLOAT
);


SELECT * FROM covid_vaccinations;


-- Select the data we are going to be using
SELECT
	LOCATION,
	DATE,
	TOTAL_CASES,
	NEW_CASES,
	TOTAL_DEATHS,
	POPULATION
FROM
	COVID_DEATHS
WHERE continent IS NOT NULL
ORDER BY
	LOCATION,
	DATE;

-- Looking at the Total Cases vs Total Deaths
-- shows the likelihood of you dying if you contract covid in your country
SELECT
    location,
    date,
    total_cases,
    total_deaths,
    CASE 
        WHEN total_cases = 0 OR total_cases IS NULL THEN NULL
        ELSE (total_deaths::numeric / total_cases::numeric) * 100
    END AS death_percentage
FROM covid_deaths
WHERE LOCATION = 'United Kingdom'
WHERE continent IS NOT NULL
ORDER BY location, date;

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
SELECT
    location,
    date,
    total_cases,
    population,
    CASE 
        WHEN total_cases = 0 OR total_cases IS NULL THEN NULL
        ELSE (total_cases::numeric / population::numeric) * 100
    END AS population_percentage
FROM covid_deaths
WHERE LOCATION = 'United Kingdom'
WHERE continent IS NOT NULL
ORDER BY location, date;

-- Looking at countries with Highest infection rate compared to population
SELECT
    location,
    population,
    MAX(total_cases) AS highest_infection_count,
    MAX((total_cases::numeric / population::numeric) * 100) AS percent_population_infected
FROM covid_deaths
--WHERE location = 'United Kingdom'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY percent_population_infected DESC;

-- Showing the countries with the highest death count per population
SELECT
    location,
    MAX(total_deaths) AS total_death_count
FROM covid_deaths
--WHERE location = 'United Kingdom'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC;

-- LET'S BREAK THINGS DOWN BY CONTINENT
SELECT
    continent,
    MAX(total_deaths) AS total_death_count
FROM covid_deaths
--WHERE location = 'United Kingdom'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC;

-- Alternative all encompassing method
SELECT
    location,
    MAX(total_deaths) AS total_death_count
FROM covid_deaths
--WHERE location = 'United Kingdom'
WHERE continent IS NULL
GROUP BY location
ORDER BY total_death_count DESC;


-- Showing the continents with the highest deathcount

SELECT
    continent,
    MAX(total_deaths) AS total_death_count
FROM covid_deaths
--WHERE location = 'United Kingdom'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC;



-- GLOBAL NUMBERS

SELECT
    SUM(new_cases) AS total_new_cases,
    SUM(new_deaths) AS total_new_deaths,
    CASE 
        WHEN SUM(new_cases) = 0 THEN NULL
        ELSE (SUM(new_deaths)::numeric / SUM(new_cases)::numeric) * 100
    END AS death_percentage
FROM covid_deaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2;

-- Looking at Total Population vs Vaccinations

SELECT
  dea.continent,
  dea.location,
  dea.date,
  dea.population,
  vac.new_vaccinations,
  SUM(COALESCE(vac.new_vaccinations, 0)::bigint)
    OVER (
      PARTITION BY dea.location
      ORDER BY dea.date
      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    )                                   AS running_total_vaccinations,
  CASE
    WHEN dea.population > 0 THEN
      (SUM(COALESCE(vac.new_vaccinations, 0)::bigint)
         OVER (
           PARTITION BY dea.location
           ORDER BY dea.date
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
         )::numeric / dea.population::numeric) * 100
  END                                    AS running_pct_of_population
FROM covid_deaths AS dea
JOIN covid_vaccinations AS vac
  ON dea.location = vac.location
 AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY dea.location, dea.date;


-- TEMP TABLE
DROP TABLE IF EXISTS percent_population_vaccinated;

CREATE TEMP TABLE percent_population_vaccinated AS
SELECT
  dea.continent,
  dea.location,
  dea.date,
  dea.population,
  vac.new_vaccinations,
  SUM(COALESCE(vac.new_vaccinations, 0)::bigint)
    OVER (
      PARTITION BY dea.location
      ORDER BY dea.date
      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total_vaccinations,
  CASE
    WHEN dea.population > 0 THEN
      (SUM(COALESCE(vac.new_vaccinations, 0)::bigint)
         OVER (
           PARTITION BY dea.location
           ORDER BY dea.date
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
         )::numeric / dea.population::numeric) * 100
  END AS running_pct_of_population
FROM covid_deaths AS dea
JOIN covid_vaccinations AS vac
  ON dea.location = vac.location
 AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY dea.location, dea.date;

-- Second query
SELECT
  *,
  (running_total_vaccinations::numeric / population::numeric) * 100 
    AS calc_pct_population
FROM percent_population_vaccinated;


-- Creating View to store data for later visualizations

CREATE VIEW percent_population_vaccinated AS
SELECT
  dea.continent,
  dea.location,
  dea.date,
  dea.population,
  vac.new_vaccinations,
  SUM(COALESCE(vac.new_vaccinations, 0)::bigint)
    OVER (
      PARTITION BY dea.location
      ORDER BY dea.date
      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total_vaccinations,
  CASE
    WHEN dea.population > 0 THEN
      (SUM(COALESCE(vac.new_vaccinations, 0)::bigint)
         OVER (
           PARTITION BY dea.location
           ORDER BY dea.date
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
         )::numeric / dea.population::numeric) * 100
  END AS running_pct_of_population
FROM covid_deaths AS dea
JOIN covid_vaccinations AS vac
  ON dea.location = vac.location
 AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY dea.location, dea.date;

 

