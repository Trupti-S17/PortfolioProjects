--Covid 19 Data Exploration 
--Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types


select* 
from PP.dbo.covid_deaths
order by 3,4;

select*
from PP.dbo.covid_vaccination
order by 3,4;

-- Finding out details only in India
select* 
from PP.dbo.covid_deaths
where location In ('India')
order by 3,4;

--- Cases to death percentage
select location,date,total_cases, total_deaths , (total_deaths/total_cases)*100 as Percentage_death
from PP.dbo.covid_deaths
where location In ('India')
order by 1,2;

--Death to population ratio
Select location,date,total_deaths,population, (total_deaths/population)*100 as Percent_population
from PP.dbo.covid_deaths
where location In ('India') 
order by 1,2;

-- To find maximum total_case in each country
Select location, population , max(total_cases) as Highest_Num_Case, max(total_cases/population)*100 as Percentage_cases
from PP.dbo.covid_deaths
where continent is not null
group by location , population
order by 4 DESC;

--COuntries with highest death 

select location , max(total_deaths) as Highest_Num_Deaths
from pp.dbo.covid_deaths
group by location
order by 2 desc;


--Found out that the total_deaths are nvarchar datatype , so converting the datatype to 'int' so as to get accurate 

--Findin Highesy death count per coninent

Select continent, max(cast(total_deaths as int)) as HighestDeathCount
from pp.dbo.covid_deaths
where continent is not null
group by continent
order by 2 DESC;

--Global Numbers

Select date, sum(new_cases) as Total_cases, sum(cast(new_deaths as int)) as Total_deaths 
,100*(sum(cast(new_deaths as int))/sum(new_cases)) as percentage_deaths 
from pp.dbo.covid_deaths
where continent is not null 
group by date
order by 1 

-- Total number and percentage of death as of current

Select sum(new_cases) as Total_cases, sum(cast(new_deaths as int)) as Total_deaths 
,100*(sum(cast(new_deaths as int))/sum(new_cases)) as percentage_deaths 
from pp.dbo.covid_deaths
order by 1 
 
--Vaccinations 

Select* 
from pp.dbo.covid_vaccination


--Joining the two tables

Select* from pp.dbo.covid_deaths as d
join pp.dbo.covid_vaccination as v 
on d.location = v.location and d.date = v.date


--Checking Total Populations vs Vaccinated

Select d.location  ,d.date , d.population , v.new_vaccinations
from pp.dbo.covid_deaths as d
join pp.dbo.covid_vaccination as v 
on d.location = v.location and d.date = v.date
where d.continent is not null 
order by 2,3;


-- with cte 

with pop_vac as
(
Select d.location, d.date, d.population, v.new_vaccinations,sum(cast(new_vaccinations as bigint)) 
over (partition by d.location order by d.location ,d.date) as Rolling_vaccination
from pp.dbo.covid_deaths as d
join pp.dbo.covid_vaccination as v 
on d.location = v.location and d.date = v.date
where d.continent is not null
)
Select *, 100*(Rolling_vaccination/population) as pop_vaccinated_percent
from pop_vac
where location = 'India'
order by pop_vac.location, pop_vac.date

--Create temp table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(bigint,v.new_vaccinations)) OVER (Partition by d.Location Order by d.location, d.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From pp.dbo.covid_deaths as d
join pp.dbo.covid_vaccination as v
	On d.location = v.location
	and d.date = v.date


Select *, (RollingPeopleVaccinated/Population)*100 as Percentage_vaccinated
From #PercentPopulationVaccinated


-- Create View

Create View PercentPopulationVaccinated as
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by d.Location Order by d.location, d.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From pp.dbo.covid_deaths as d
Join  pp.dbo.covid_vaccination as v
	On d.location = v.location
	and d.date = v.date
where d.continent is not null 


