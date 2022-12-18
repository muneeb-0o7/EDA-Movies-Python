
select  sum(new_cases) as Total_Cases, sum(cast(new_deaths as int)) as Total_Deaths, 
(sum(cast(new_deaths as int))/sum(new_cases))*100 as Death_Percentage from [Portfolio Project] ..coviddeaths 
	--where location like 'Pakistan'	
	where continent is not null
	order by 1

select location, SUM(cast(new_deaths as int)) as TotalDeathCount
from [Portfolio Project] ..coviddeaths 
Where continent is null 
and location not in ('World', 'European Union', 'International','High income', 'Upper middle income', 'Lower middle income', 'Low income')
Group by location
order by TotalDeathCount desc

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
from [Portfolio Project] ..coviddeaths 
Group by Location, Population, date
order by PercentPopulationInfected desc