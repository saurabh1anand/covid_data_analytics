select * 
from portfolioProject..CovidDeaths
--order by continent
--order by 3,4

select * 
from portfolioProject..CovidVaccination
order by 3,4


select location, date, total_cases, new_cases, total_deaths, population
from portfolioProject..CovidDeaths
order by 2

-- looking at total cases vs total deaths 

select location, date, total_cases, total_deaths, (total_deaths/total_cases) *100 as DeathPercent
from portfolioProject..CovidDeaths
where location like '%ndia'
order by 1,2

-- looking at total cases vs population 
-- show popoulation % which got covid
select location, date, total_cases, population, (total_cases/population) *100 as Percent_People_got_covid
from portfolioProject..CovidDeaths
--where location like '%ndia'
order by Percent_People_got_covid desc

-- countries with highest infection rate compared to population 
select location, population,
MAX( total_cases) as higest_infection_count,  
max((total_cases/population)) *100 as percent_people_got_infected
from portfolioProject..CovidDeaths
group by location, population
order by percent_people_got_infected desc 


-- showing the countries wiht highest death count per population  
select location, max(cast(total_deaths as int)) as toatl_death_count 
from portfolioProject..CovidDeaths
where continent is not null 
group by location
order by toatl_death_count desc



-- LETS BREAK IT DOWN BY CONTINENT


-- showing the conitnet with highest death count
select continent, max(cast(total_deaths as bigint)) as toatl_death_count 
from portfolioProject..CovidDeaths
where continent is not null 
group by continent
order by toatl_death_count desc

-- GLOBAL NUMBERS 
select date, sum(new_cases) as total_cases, sum(cast(new_deaths as bigint)) as total_deaths, sum(cast(new_deaths as bigint))/ sum(new_cases)*100    as Death_percentage
from portfolioProject..CovidDeaths
where continent is not null 
group by date
order by 1,2 

-- Looking at Total population vs vaccination 

select * from 
	portfolioProject..CovidVaccinations

select * 
from portfolioProject..CovidDeaths dea 
join portfolioProject..CovidVaccinations vac 
	on dea.location = vac.location
	and dea.date = vac.date 


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- USE CTE

with PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
select * , (RollingPeopleVaccinated / population)*100
from PopVsVac

-- TEMP TABLE
create table #PercentagePeopleVaccinated
(
continnet nvarchar (255), 
location nvarchar (255), 
date datetime, 
population numeric, 
new_vaccinations numeric, 
RollingPeopleVaccinated numeric, 
)
insert into #PercentagePeopleVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

select * , (RollingPeopleVaccinated / population)*100
from #PercentagePeopleVaccinated








-- creating view to store data for later visualization 
create view PercentagePeopleVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

select * from 
PercentagePeopleVaccinated






/*

Quries for Visualization 


*/


--1. 

select sum(new_cases) as total_cases, sum(cast(new_deaths as bigint)) as total_deaths , 
		sum(cast(new_deaths as bigint))/sum(new_cases) * 100 as death_percentage
		from portfolioProject..CovidDeaths
		where continent is not null 
order by 1,2 


-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International', 'Upper middle income', 'high income', 'lower middle income', 'low income')
Group by location
order by TotalDeathCount desc


-- 3.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc



-- 4.


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc







