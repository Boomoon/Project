-------------------- Global labor productivity trends --------------------

-- back up to test delete logic
select * into salary1Backup from demo.dbo.Salary1;
select * into salary2Backup from demo.dbo.Salary2;
select top 5 * from salary2Backup;


-- Delete from yourTableName where yourColumnName=' ' OR yourColumnName IS NULL;
DELETE from salary1Backup 
WHERE (countrycode=' ' OR countrycode is NULL) 
OR (country=' ' OR country is NULL) 
OR (currency_unit=' ' OR currency_unit is NULL) 
OR (rgdpe=' ' OR rgdpe is NULL) 
OR (avh=' ' OR avh is NULL); 

-- Avg working hour/ Engaged people -> Table 1
select top 5 * from salary1Backup;
-- RGDPO/ PL --> Table 2
select top 5 * from salary2Backup;

select

--- Calculate the productivity trends
SELECT s1.country, 
s1.year,  
avg(s2.rgdpo) as rgdpoo, 
avg(s1.avh) as AnnualHours,
avg(s1.emp) as EngagedpopulationMil, 
avg(s2.pl_gdpo) as PL,
(avg(s2.rgdpo)/((avg(s1.avh))*max(s1.emp))) as productivity 
FROM salary1Backup as s1
JOIN salary2Backup as s2
ON s1.country=s2.country AND s1.year=s2.year
WHERE s1.year > 1950
GROUP by s1.country,s1.year
ORDER by s1.year DESC,productivity DESC;


--- Annual working hour vs productivity in 2019 
select subquery.country as Country,subquery.year as Year ,subquery.AnnualHours as AnnualHourse,subquery.productivity as Productivity
    FROM 
        (SELECT s1.country, 
        s1.year,  
        avg(s2.rgdpo) as rgdpoo, 
        avg(s1.avh) as AnnualHours,
        avg(s1.emp) as EngagedpopulationMil, 
        avg(s2.pl_gdpo) as PL,
        (avg(s2.rgdpo)/((avg(s1.avh))*max(s1.emp))) as productivity 
        FROM salary1Backup as s1
            JOIN salary2Backup as s2
            ON s1.country=s2.country AND s1.year=s2.year
        WHERE s1.year > 1950
        GROUP by s1.country,s1.year) 
    as subquery
WHERE productivity is not null and AnnualHours is not null AND year = 2019
ORDER by year DESC,productivity DESC;



-- Annual working hours vs GDP in 2019 
select country, year, avg(rgdpe)/avg(pop) as GDP, avg(avh) as hours
from salary1Backup
group by country,year
HAVING avg(rgdpe) is not null and avg(avh) is not null and year = 2019
ORDER BY year DESC,GDP DESC;