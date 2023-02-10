select * from [Covid Data]..covid_deaths
where continent is not null
order by 3,4;

select * from [Covid Data]..Covid_vaccinations$;

select location, date, total_cases, new_cases, population, total_deaths 
from [Covid Data]..covid_deaths
order by 1,2;

-- Total_cases Vs Total_Deaths
select location, date, total_cases, total_deaths, (total_cases/total_deaths)*100 as Death_percentage
from [Covid Data]..covid_deaths
where location like '%states%'
order by 1,2;

--Total_cases Vs Population

select location, date, total_cases, population, (total_cases/population)*100 as percentage_of_population
from [Covid Data]..covid_deaths
where location like '%states%'
order by 1,2;

--Highest infection rate with population

select location, population,max(total_cases)as High_Infectioncount, 
max((total_cases/population))*100 as percentage_of_populationinfected
from [Covid Data]..covid_deaths
--where location like '%states%'
group by location, population
order by percentage_of_populationinfected desc;

--countries with Highest death count per population

select location,max(cast(total_deaths as int)) Total_deathcount
from [Covid Data]..covid_deaths
--where location like '%states%'
where continent is not null
group by location
order by Total_deathcount desc;


-- By continent

select continent,max(cast(total_deaths as int)) Total_deathcount
from [Covid Data]..covid_deaths
--where location like '%states%'
where continent is not null
group by continent
order by Total_deathcount desc;

--continents with highest death counts per population

select continent,max(cast(total_deaths as int)) as Total_deathcount
from [Covid Data]..covid_deaths
where continent is not null
group by continent
order by Total_deathcount desc;

--Global numbers

select sum(new_cases) as total_cases,sum (cast(new_deaths as int))as total_deaths,
sum(cast(new_deaths as int ))/sum(new_cases)*100 as Death_percentage from [Covid Data]..covid_deaths
where continent is not null
order by 1,2;


--Total population vs vaccinations

select death.continent,death.location,death.date, death.population,vaccine.new_vaccinations, 
sum(convert(int,vaccine.new_vaccinations)) 
over(partition by death.location order by death.location,death.date) as people_vaccinated
from [Covid Data]..covid_deaths death
	join [Covid Data]..Covid_vaccinations$ vaccine
	on death.location = vaccine. location
	and death.date = vaccine.date
	where death.continent is not null
	order by 2,3;


-- with CTE
with populationvsvaccine(continent, location, date, population, new_vaccinations, people_vaccinated) as
(select death.continent,death.location,death.date, death.population,vaccine.new_vaccinations, 
sum(convert(int,vaccine.new_vaccinations)) 
over(partition by death.location order by death.location, death.date) as people_vaccinated
from [Covid Data]..covid_deaths death
	join [Covid Data]..Covid_vaccinations$ vaccine
	on death.location = vaccine. location
	and death.date = vaccine.date
	where death.continent is not null
	)
	Select *, (people_vaccinated/population)* 100 from populationvsvaccine;


--Temp table
drop table if exists percentpopulationvaccinated

create table percentpopulationvaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations int,
people_vaccinated numeric)

insert into  percentpopulationvaccinated
select death.continent,death.location,death.date, death.population,vaccine.new_vaccinations, 
sum(cast(vaccine.new_vaccinations as int)) 
over(partition by death.location order by death.location, death.date) as people_vaccinated
from [Covid Data]..covid_deaths death
	join [Covid Data]..Covid_vaccinations$ vaccine
	on death.location = vaccine. location
	and death.date = vaccine.date
	--where death.continent is not null

Select *, (people_vaccinated/population)* 100 from percentpopulationvaccinated

--Creating view

create view percentpeoplevaccinated as 
select death.continent,death.location,death.date, death.population,vaccine.new_vaccinations, 
sum(cast(vaccine.new_vaccinations as int)) 
over(partition by death.location order by death.location, death.date) as people_vaccinated
from [Covid Data]..covid_deaths death
	join [Covid Data]..Covid_vaccinations$ vaccine
	on death.location = vaccine. location
	and death.date = vaccine.date
	where death.continent is not null

	select * from percentpeoplevaccinated;
	






