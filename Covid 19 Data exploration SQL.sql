--Exploration of Covid 19 data downloaded from https://ourworldindata.org/covid-deaths

select * 
from CovidDeaths

--Lookling at total cases vs total deaths
--shows liklehood of dying if you contract covid based on yor loacation

select location, date,population, total_cases, total_deaths, ROUND(((total_deaths/total_cases)*100), 2) as Death_Percentage
from CovidDeaths
where location like '%Ghana%'
order by 1,2

--Looking at total cases vs population

select location, date,population, total_cases, total_deaths, ROUND(((total_cases/population)*100), 2) as PercentofPopulationInfected
from CovidDeaths
where location like '%Ghana%'
order by 1,2

--Looking at country with highest infection rates compared to population
select location,population, Max(total_cases) as HighestInfectionCount, ROUND((Max((total_cases/population))*100), 2) as PercentofPopulationInfected
from CovidDeaths
Group by location, population
order by PercentofPopulationInfected desc


--Showing countries with highest death count

select location,Max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
Group by location
order by TotalDeathCount desc 

--BREAKING THINGS DOWN BY CONTINENT

--Showing the continents with the highest death counts
select continent,Max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc

select location, Max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
Group by location
order by TotalDeathCount desc --this shows countries

--Global Numbers
--This shows the global total by date

select date, SUM(new_cases) as total_cases,
SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(new_cases)* 100 as DeathPercentge
from CovidDeaths
where continent is not null
Group by date
order by 1,2

--this shows whole total figure

select SUM(new_cases) as total_cases,
SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(new_cases)* 100 as DeathPercentge
from CovidDeaths
where continent is not null
--Group by date
order by 1,2



-- joining CovidDeaths table with CovidVaccinations table and Looking at total population v Vaccinations


select dea.continent,
dea.location,
dea.date,
dea.population,
vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3 

--USING CTE (Common Table Expression)
With PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(select dea.continent,
dea.location,
dea.date,
dea.population,
vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3 Order by andt be in CTE 
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac

--USING TEMP TABLE
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime, 
Population numeric, 
New_Vaccinations numeric, 
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent,
dea.location,
dea.date,
dea.population,
vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3 Order by andt be in CTE 

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


--Creating View to store data for later visualization

Create View PercentPoulationVacinated as
select dea.continent,
dea.location,
dea.date,
dea.population,
vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * from PercentPoulati onVacinated