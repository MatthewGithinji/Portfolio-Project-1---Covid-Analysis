-- 1) Global totals and death percentage (countries only)
SELECT
  SUM(new_cases)::numeric            AS total_cases,
  SUM(new_deaths)::numeric           AS total_deaths,
  CASE
    WHEN SUM(new_cases) = 0 THEN NULL
    ELSE (SUM(new_deaths)::numeric / SUM(new_cases)::numeric) * 100
  END AS death_percentage
FROM covid_deaths
WHERE continent IS NOT NULL;
-- (ORDER BY removed; this returns a single row)

-- 2) Locations with no continent (exclude World/EU/International)
SELECT
  location,
  SUM(new_deaths)::bigint AS total_death_count
FROM covid_deaths
WHERE continent IS NULL
  AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY total_death_count DESC;

-- 3) Peak infection count and % of population infected per location
SELECT
  location,
  population,
  MAX(total_cases) AS highest_infection_count,
  MAX( (total_cases::numeric / NULLIF(population,0)::numeric) ) * 100
    AS percent_population_infected
FROM covid_deaths
GROUP BY location, population
ORDER BY percent_population_infected DESC NULLS LAST;

-- 4) Same as (3) but per (location, date)
-- (Note: this shows the % for each date; it does NOT pick "the date of the peak".)
SELECT
  location,
  population,
  date,
  MAX(total_cases) AS highest_infection_count,
  MAX( (total_cases::numeric / NULLIF(population,0)::numeric) ) * 100
    AS percent_population_infected
FROM covid_deaths
GROUP BY location, population, date
ORDER BY percent_population_infected DESC;

SELECT
  location,
  population,
  date,
  MAX(total_cases) AS highest_infection_count,
  MAX( (total_cases::numeric / NULLIF(population,0)::numeric) ) * 100
    AS percent_population_infected
FROM covid_deaths
GROUP BY location, population, date
ORDER BY percent_population_infected DESC NULLS LAST;









