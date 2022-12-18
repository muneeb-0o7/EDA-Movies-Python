

/*
Covid 19 Data Exploration
*/

select * from [Portfolio Project] ..coviddeaths 
	where continent is not null
	order by 2

-- Select Data that we are going to be starting with
 

select Location, population, date, total_cases, new_cases, total_deaths from [Portfolio Project] ..coviddeaths 
	where continent is not null
	order by 1,3

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in UK


select Location, population, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Cases_DeathPercent from [Portfolio Project] ..coviddeaths 
	where location like 'Pakistan'	
	--where continent is not null
	order by 1,3

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

select Location, population, date, total_cases, (total_cases/population)*100 as PercentPopulationInfected from [Portfolio Project] ..coviddeaths 	
	where continent is not null
	order by 1,3


-- Countries with Highest Infection Rate compared to Population

select Location, population, MAX(total_cases), MAX((total_cases/population)*100) as PercentPopulationInfected from [Portfolio Project] ..coviddeaths 	
	where continent is not null
	group by location, population
	order by PercentPopulationInfected desc

	-- Countries with Highest Death Count per Population

select Location, population, MAX(cast(Total_deaths as int)) as Total_Deaths, MAX((total_deaths/population)*100) as PercentPopulationDied from [Portfolio Project] ..coviddeaths 	
	where continent is not null
	group by location, population
	order by PercentPopulationDied desc

-- BREAKING THINGS DOWN BY CONTINENT
-- Showing contintents with the highest death count per population

select continent, MAX(cast(Total_deaths as int)) as Total_Deaths, MAX((total_deaths/population)*100) as PercentPopulationDied from [Portfolio Project] ..coviddeaths 	
	where continent is not null
	group by continent
	order by PercentPopulationDied desc

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [Portfolio Project] ..coviddeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
select cd.continent, cd.location, cd.population, cd.date, cv.new_vaccinations, 
	SUM(CAST(cv.new_vaccinations as BIGINT)) OVER (Partition by cd.location order by cd.location, cd.date)  as RollingPeopleVaccinated
	from [Portfolio Project]..coviddeaths cd Join [Portfolio Project]..covidcavccination cv
		on cd.location = cv.location and
		cd.date = cv.date
	where cd.continent is not null --and cv.total_vaccinations is not null
	order by 2,1

-- Using CTE to perform Calculation on Partition By in previous query
with popvsvac (continent, location, population, date, new_vaccinations, RollingPeopleVaccinated)
as
(
select cd.continent, cd.location, cd.population, cd.date, cv.new_vaccinations, 
	SUM(CAST(cv.new_vaccinations as BIGINT)) OVER (Partition by cd.location order by cd.location, cd.date)  as RollingPeopleVaccinated
	from [Portfolio Project]..coviddeaths cd 
	Join [Portfolio Project]..covidcavccination cv
	on cd.location = cv.location and cd.date = cv.date
	where cd.continent is not null
	)
select *,  (RollingPeopleVaccinated/Population)*100 as PercentPopVacc
From PopvsVac

-- Creating View to store data for later visualizations

create view PercentPopulationVaccinated
as
select cd.continent, cd.location, cd.population, cd.date, cv.new_vaccinations, 
SUM(CAST(cv.new_vaccinations as BIGINT)) OVER (Partition by cd.location order by cd.location, cd.date)  as RollingPeopleVaccinated
	from [Portfolio Project]..coviddeaths cd 
	Join [Portfolio Project]..covidcavccination cv
	on cd.location = cv.location 
	and cd.date = cv.date
where cd.continent is not null
