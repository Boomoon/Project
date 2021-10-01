------- Exploring COVID-19 situation -------
SELECT location,date, total_cases, new_cases, total_deaths, population
FROM demo.dbo.CovidDeaths
ORDER by 1,2;

-- Looking at total cases, total deaths and fatality rate of COVID in USA
SELECT location,date ,(total_cases), (total_deaths), (total_deaths/total_cases)*100 as fatality_rate
FROM demo.dbo.CovidDeaths
WHERE location like '%states%';

 -- Total number of total case for each country
SELECT location, max(total_cases) as totalCase, max(total_deaths) as total_deaths
FROM demo.dbo.CovidDeaths
GROUP by location 
ORDER BY totalCase DESC, total_deaths DESC;

 -- Looking at the Total cases vs population
SELECT location, date , population, total_cases, (total_cases/population)*100 as infectedperpopulation
FROM demo.dbo.CovidDeaths
WHERE location like '%states%';

 -- Highest infection rate country
SELECT location, max(total_cases) as totalCase, population, max(total_cases)*100/(population) as infectionRate
FROM demo.dbo.CovidDeaths
GROUP BY location, population 
ORDER BY infectionRate DESC;

 -- Highest fatality rate per population in each location
SELECT location, max(total_deaths) as totalDeath, population, max(total_deaths)*100/(population) as fatalityRate
FROM demo.dbo.CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY fatalityRate DESC;

 -- Highest death counts continent
SELECT continent, max(total_deaths) as totalDeath
FROM demo.dbo.CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY totalDeath DESC;

-- Highest deathrate in continent
SELECT continent, max(total_deaths) as totalDeath, max(population) as population, max(total_deaths)*100/(max(population)) as deathRate
FROM demo.dbo.CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY deathRate DESC;

-- Global number death percentage
SELECT sum(new_cases) as globalTotalCase , sum(new_deaths) as globalTotalDeath, sum(new_deaths)*100/sum(new_cases) as deathPercen
FROM demo.dbo.CovidDeaths
WHERE continent is not null
ORDER by deathPercen DESC;


--- Join two table (Covid death and Covid vaccination)
SELECT TOP 5 *
FROM demo.dbo.CovidDeaths death
JOIN demo.dbo.CovidVaccination vac
    ON death.location=vac.location AND death.date=vac.date;


-- Looking at Total Population who have been vaccinated (1st dose is counted as vaccinated each day)
SELECT subquery.location,subquery.datetimeX,(subquery.rollingvac)*100/(subquery.population) as vaccinatedPercen
FROM
    (SELECT death.continent , death.location as location, convert(datetime, death.date, 103) as datetimeX,
    death.population as population,
    vac.new_vaccinations, (sum(new_vaccinations) OVER (PARTITION BY death.location ORDER BY death.location,convert(datetime, death.date, 103))) as rollingvac
    FROM demo.dbo.CovidDeaths death
    JOIN demo.dbo.CovidVaccination vac
        ON death.location=vac.location AND death.date=vac.date
    WHERE death.continent is not null
     ) as subquery
ORDER BY subquery.location, subquery.datetimeX;


-- Looking at the percentage of fully vaccinated people
SELECT death.location as Location, max(vac.people_fully_vaccinated) as fullyVac, death.population as Population ,max(vac.people_fully_vaccinated)*100/death.population as fullyVacPercen
FROM demo.dbo.CovidDeaths as death
JOIN demo.dbo.CovidVaccination as vac
    ON death.location=vac.location AND death.date=vac.date
GROUP BY death.location,death.population 
ORDER BY fullyVacPercen DESC;

-- Creating View to store data for later visualization
create view subquery AS
(SELECT death.continent , death.location as location, convert(datetime, death.date, 103) as datetimeX,
    death.population as population,
    vac.new_vaccinations, (sum(new_vaccinations) OVER (Partition by death.location order by death.location,convert(datetime, death.date, 103))) as rollingvac
    FROM demo.dbo.CovidDeaths death
    JOIN demo.dbo.CovidVaccination vac
        ON death.location=vac.location AND death.date=vac.date
    WHERE death.continent is not null);
    
select * from subquery
order by 2,3;


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject.CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc