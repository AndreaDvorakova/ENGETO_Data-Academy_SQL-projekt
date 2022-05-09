CREATE OR REPLACE TABLE t_andrea_dvorakova_projekt_SQL_primary_final AS
	SELECT cpric.year_czechia_price,
			czpay.industry_branch_code,
			czpay.name AS branch_name,
			czpay.prum_mzda,
			cpric.category_code,
			cpric.name AS category_name, 
			cpric.prum_cena, 
			cpric.price_value,
			cpric.price_unit,
			econ.gdp 
	FROM (
		SELECT *,
			ROUND(AVG(value), 2) AS prum_mzda
		FROM czechia_payroll cp 
		JOIN czechia_payroll_industry_branch cpib 
			ON cp.industry_branch_code = cpib.code 
		WHERE cp.value_type_code  = 5958 AND cp.calculation_code = 100
		GROUP BY cp.industry_branch_code, cp.payroll_year ) AS czpay
		JOIN (
		SELECT cp.category_code,
			cpcat.name,
			cpcat.price_value,
			cpcat.price_unit,
			round(AVG(value), 2) AS prum_cena,
			YEAR(date_from) AS year_czechia_price
		FROM czechia_price cp 
		JOIN czechia_price_category cpcat 
			ON cp.category_code = cpcat.code 
		GROUP BY year_czechia_price, category_code) cpric
			ON cpric.year_czechia_price = czpay.payroll_year 
		JOIN (
		SELECT gdp, year
		FROM economies e
		WHERE country = 'Czech republic') AS econ
			ON econ.year = czpay.payroll_year 
	ORDER BY cpric.year_czechia_price DESC,
			czpay.industry_branch_code ASC,
			cpric.category_code; 
