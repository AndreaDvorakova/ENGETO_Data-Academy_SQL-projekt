CREATE OR REPLACE TABLE t_andrea_dvorakova_project_SQL_secondary_final
	SELECT e.country, 
		c.continent, 
		e.year, 
		e.GDP,
		e.gini, 
		e.population 
	FROM economies e 
	JOIN countries c 
		ON e.country = c.country 
	WHERE c.continent = 'Europe' AND e.year >= 2006 
		AND e.year <= 2018
	ORDER BY e.country, e.year;

