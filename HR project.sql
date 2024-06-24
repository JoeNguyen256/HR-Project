Alter table hr_project.`human resources`
rename to hr;

USE hr_project;
select *
from hr;
 
 
 -- ----------------------------------------- DATA CLEANING ----------------------------------------
 -- Change Column Name --
 
 
 Alter table hr
 CHANGE COLUMN ï»¿id emp_id VARCHAR(20) NULL;
 
 -- Fix Format --
 
 
 
 select birthdate from hr;
 
 UPDATE hr
 set birthdate = CASE
	when birthdate LIKE '%/%' THEN date_format(str_to_date(birthdate, '%m/%d/%Y'),'%Y-%m-%d')
    when birthdate LIKE '%-%' THEN date_format(str_to_date(birthdate, '%m-%d-%Y'),'%Y-%m-%d')
    ELSE NULL
END;

ALter table hr
Modify column birthdate DATE;

DESCRIBE hr;

UPDATE hr
 set hire_date = CASE
	when hire_date LIKE '%/%' THEN date_format(str_to_date(hire_date, '%m/%d/%Y'),'%Y-%m-%d')
    when hire_date LIKE '%-%' THEN date_format(str_to_date(hire_date, '%m-%d-%Y'),'%Y-%m-%d')
    ELSE NULL
END;

ALter table hr
Modify column hire_date DATE;

UPDATE hr
SET termdate = IF(termdate IS NOT NULL AND termdate != '', date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC')), '0000-00-00')
WHERE true;

SELECT termdate from hr;

SET sql_mode = 'ALLOW_INVALID_DATES';

ALTER TABLE hr
MODIFY COLUMN termdate DATE;

-- ADD AGE COLUMN --

Alter table hr
Add column age INT;

SELECT *from hr;

select birthdate, curdate()
from hr;

UPDATE hr
set age = timestampdiff(Year, birthdate, CURDATE());

select birthdate, curdate(), age
from hr;

select MIN(age) as youngest, MAX(age) as oldest
from hr;

select age
from hr
where age < 18;

-- --------------------------------------------------- QUESTIONS ---------------------------------------------------

-- What is the gender breakdown of employees in the company?

select gender, count(*) as count
from hr
where age >= 18 AND termdate = '0000-00-00'
group by gender;

-- What is the race/ethnicity breakdown of employees in the company?

select race, count(*) as count
from hr
where age >= 18 AND termdate = '0000-00-00'
group by race
order by 2 DESC;

-- What is the age distribution of employees in the company?

select min(age), max(age)
from hr
where age >= 18 AND termdate = '0000-00-00';

Select
CASE
	When age >=18 and age <= 24 then '18-24'
    When age >=25 and age <= 34 then '25-34'
    When age >=35 and age <= 44 then '35-44'
    When age >=45 and age <= 54 then '45-54'
    When age >=55 and age <= 64 then '55-64'
    Else '65+' 
END as age_group, count(*)
from hr
where age >= 18 AND termdate = '0000-00-00'
group by 1
order by 1;

-- Just curious about gender distribution by age group

Select
CASE
	When age >=18 and age <= 24 then '18-24'
    When age >=25 and age <= 34 then '25-34'
    When age >=35 and age <= 44 then '35-44'
    When age >=45 and age <= 54 then '45-54'
    When age >=55 and age <= 64 then '55-64'
    Else '65+' 
END as age_group, gender, count(*)
from hr
where age >= 18 AND termdate = '0000-00-00'
group by 1, 2
order by 1;

-- How many employees work at headquarters versus remote locations?

select location, count(location) as count
from hr
where age >= 18 AND termdate = '0000-00-00'
group by location
order by 2 DESC;

-- What is the average length of employment for employees who have been terminated?

Select round(AVG(datediff(termdate,hire_date))/365,0) as avg_lenght
from hr
where termdate <= CURDATE() and termdate != '0000-00-00' and age >= 18;

-- How does the gender distribution vary across departments and job titles?

select department, gender, count(gender)
from hr
where age >= 18 AND termdate = '0000-00-00'
group by 1, 2
order by 1;

select jobtitle, gender, count(gender)
from hr
where age >= 18 AND termdate = '0000-00-00'
group by 1, 2
order by 1;

-- What is the distribution of job titles across the company?

select jobtitle, count(*) as count
from hr
where age >= 18 AND termdate = '0000-00-00'
group by 1
order by 1 DESC;

-- Which department has the highest turnover rate?

select department, total_count, terminated_count, terminated_count/total_count as turnover_rate
from (
select department, count(*) as total_count, 
SUM( CASE when termdate != '0000-00-00' and termdate <= CURDATE() then 1 else 0 END) as terminated_count
from hr
where age >= 18 
group by department) as subquerry
order by turnover_rate DESC;

-- What is the distribution of employees across locations by state and city?

select location_state, count(*)
from hr
where age >= 18 AND termdate = '0000-00-00'
group by 1
order by 2 DESC;

select location_city, count(*)
from hr
where age >= 18 AND termdate = '0000-00-00'
group by 1
order by 2 DESC;

-- How has the company's employee count changed over time based on hire and term dates?

select 
year,
hires,
terminations,
hires-terminations AS net_change,
round((hires-terminations)/hires * 100,2) AS net_change_percent
from ( 
	Select
		YEAR(hire_date) as year,
        COUNT(*) as hires,
        SUM(CASE when termdate != '0000-00-00'AND termdate <= CURDATE() THEN 1 ELSE 0 END) as terminations
	from hr
    where age >= 18
    group by YEAR(hire_date)
    ) as subquerry
ORDER BY year ASC;

-- What is the tenure distribution for each department?

select department, round(avg(datediff(termdate,hire_date)/365),0) as tenure_distribution
from hr
where age >= 18 AND termdate != '0000-00-00' AND termdate <= CURDATE()
group by department
order by 2;