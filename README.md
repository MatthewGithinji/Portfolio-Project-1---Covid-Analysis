🦠 COVID-19 Data Exploration and Analysis (PostgreSQL) 🦠

This project explores the **COVID-19 pandemic dataset** using **PostgreSQL** and visualising these findings within **Tableau**. It focuses on analysing global cases, deaths, and vaccinations to uncover trends and insights at both the country and continent levels.

The analysis is built using two main tables:

* **`covid_deaths`** – contains case counts, deaths, infection rates, population, and related metrics.
* **`covid_vaccinations`** – contains testing, vaccination progress, demographic, and health-related indicators.

---

## 🔎 Queries & Analysis Overview for Main SQL Script

### 1. **Data Selection**

Extracted relevant columns (location, date, cases, deaths, population) to build a clean dataset for analysis.

### 2. **Likelihood of Death (Case Fatality Rate)**

Compared **total cases vs total deaths** to calculate the probability of death upon contracting COVID-19 (`death_percentage`).
*Example: "What % of confirmed cases in the UK led to death over time?"*

### 3. **Infection Rate vs Population**

Measured **total cases relative to population** to see how much of each country’s population was infected (`population_percentage`).
*Example: "What % of the UK population had COVID-19 at its peak?"*

### 4. **Highest Infection Rates by Country**

Identified countries with the **highest infection rates compared to their population**, ranking them by infection percentage.

### 5. **Countries with Highest Death Count**

Ranked countries by **total COVID-19 deaths** to reveal which were most impacted in absolute terms.

### 6. **Continental Breakdown**

Aggregated deaths by **continent**, to show the pandemic’s severity across regions.
Includes both:

* Countries grouped by continent
* "Global entities" (like World, European Union, etc.) when continent is `NULL`

### 7. **Global Summary Numbers**

Calculated **total global new cases, new deaths, and case fatality rates** over time.

### 8. **Vaccination Progress**

Joined `covid_deaths` with `covid_vaccinations` to analyze vaccination rollouts:

* **Running total of vaccinations per country** (using a window function)
* **% of population vaccinated over time**

### 9. **Reusable Structures**

* **Temp Table** `percent_population_vaccinated` – stores vaccination progress for further queries.
* **View** `percent_population_vaccinated` – reusable for dashboards and BI tools (Tableau, Power BI, etc.).

---

## 🛠️ Key SQL Techniques Used

* **Aggregations** (`SUM`, `MAX`)
* **Conditional logic** with `CASE`
* **Window Functions** (`OVER PARTITION BY`) for running totals
* **JOINS** between deaths and vaccination tables
* **Temporary Tables** & **Views** for modular, reusable analysis

---

## 📈 Insights You Can Derive

* Probability of death if infected in any given country
* Percentage of population infected over time
* Countries/continents most impacted by infections & deaths
* Global death rates compared to case counts
* Progress of vaccination campaigns across countries
* Comparison of population size vs vaccination rates

---

## 🚀 Next Steps

This dataset and queries can be extended into:

* **Comparative analysis** across economic/demographic indicators (e.g., GDP per capita vs death rates)
