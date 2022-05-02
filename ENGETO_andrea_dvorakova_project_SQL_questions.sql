/*
*DOTAZ: Rostou v prùbìhu let mzdy ve všech odvìtvích, nebo v nìkterých klesají?
*ODPVÌÏ: V letech viz. níže podle SQL dotazù mzdy klesají.
*/
SELECT
	vyber.branch_name ,
	vyber.year_prev ,
	vyber.prum_mzda_growth,
	vyber.mzda_mezirocne 
FROM(
	SELECT DISTINCT 
		tadpspf.branch_name,
		tadpspf2.year_czechia_price + 1 AS year_prev,
		round((tadpspf.prum_mzda - tadpspf2.prum_mzda) / tadpspf2.prum_mzda * 100, 2) AS prum_mzda_growth,
		tadpspf.prum_mzda,
		CASE 
			WHEN round((tadpspf.prum_mzda - tadpspf2.prum_mzda) / tadpspf2.prum_mzda * 100, 2) < 0 THEN 'mezirocni pokles'
			ELSE 'mezirocni rust'
		END AS mzda_mezirocne
	FROM t_andrea_dvorakova_projekt_sql_primary_final tadpspf 
	JOIN t_andrea_dvorakova_projekt_sql_primary_final tadpspf2 
		ON tadpspf.branch_name = tadpspf2.branch_name 
		AND tadpspf.year_czechia_price = tadpspf2.year_czechia_price + 1
	ORDER BY branch_name , year_prev) AS vyber
WHERE vyber.mzda_mezirocne = 'mezirocni pokles';

/*
*DOTAZ: Kolik je možné si koupit litrù mléka a kilogramù chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?
*ODPOVÌÏ: Viz. vypis podle SQL doazu níže.
*/

SELECT *
FROM (
	SELECT year_czechia_price ,
		branch_name ,
		category_name ,
		prum_mzda ,
		prum_cena ,
		prum_mzda DIV prum_cena AS mnozstvi_nakupu,
		price_unit ,
		CONCAT('Za prumernou mzdu ', prum_mzda, ' lze nakoupit ', prum_mzda DIV prum_cena,' ',  price_unit,' ', category_name, ' za prumernou cenu ', prum_cena) AS odpoved
	FROM t_andrea_dvorakova_projekt_sql_primary_final tadpspf 
	WHERE category_code = 114201 OR category_code = 111301) AS vyber 
WHERE vyber.year_czechia_price = 2006 OR vyber.year_czechia_price = 2018
ORDER BY vyber.branch_name, vyber.year_czechia_price  ;

/*
*DOTAZ: Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroèní nárùst)?
*ODPOVÌÏ: Nejpomaleji roste cena rostlinného rotíratelného tuku mezi rokem 2008 a 2009. Je to náùst o 0,01%.
*/

SELECT a.category_code ,
	a.category_name ,
	b.year_czechia_price,
	b.prum_cena_zarok_2,
	a.year_czechia_price ,
	a.prum_cena_zarok ,
	round((1 - (b.prum_cena_zarok_2 /a.prum_cena_zarok )) * 100, 2) AS price_growth
FROM
	(SELECT tadpspf.category_code , 
		tadpspf.category_name , 
		tadpspf.year_czechia_price , 
		AVG(tadpspf.prum_cena) AS prum_cena_zarok
	FROM t_andrea_dvorakova_projekt_sql_primary_final tadpspf
	GROUP BY category_code, tadpspf.year_czechia_price) a
JOIN(  
	SELECT tadpspf2.category_code,
		tadpspf2.year_czechia_price ,
		AVG(tadpspf2.prum_cena) AS prum_cena_zarok_2
	FROM t_andrea_dvorakova_projekt_sql_primary_final tadpspf2
	GROUP BY category_code, tadpspf2.year_czechia_price) AS b
ON a.year_czechia_price = b.year_czechia_price + 1
	AND a.category_code = b.category_code
WHERE round((1 - (b.prum_cena_zarok_2 /a.prum_cena_zarok )) * 100, 2) > 0
ORDER BY price_growth 
LIMIT 1
;

/*
*DOTAZ: Existuje rok, ve kterém byl meziroèní nárùst cen potravin výraznì vyšší než rùst mezd (vìtší než 10 %)?
*ODPOVÌÏ: V žádném roce není vyšší procentuální rùst než 10%.
*/

SELECT b.year_czechia_price ,
	b.prum_mzda_za_rok,
	a.prum_mzda_za_rok_prev,
	round((((b.prum_mzda_za_rok * 100)/a.prum_mzda_za_rok_prev) - 100) , 2) AS mezirocni_mzda,
	b.prum_cena_za_rok,
	a.prum_cena_za_rok_prev,
	round((((b.prum_cena_za_rok * 100)/a.prum_cena_za_rok_prev) - 100) , 2) AS mezirocni_cena
FROM
	(
	SELECT tadpspf.year_czechia_price ,
		round(AVG(prum_mzda), 2) AS prum_mzda_za_rok,
		round(AVG(prum_cena), 2) AS prum_cena_za_rok
	FROM t_andrea_dvorakova_projekt_sql_primary_final tadpspf
	GROUP BY tadpspf.year_czechia_price 
	) AS b
JOIN (
	SELECT tadpspf2.year_czechia_price,
		round(AVG(prum_mzda), 2) AS prum_mzda_za_rok_prev,
		round(AVG(prum_cena), 2) AS prum_cena_za_rok_prev
	FROM t_andrea_dvorakova_projekt_sql_primary_final tadpspf2 
	GROUP BY tadpspf2.year_czechia_price 
	) AS a
ON a.year_czechia_price = b.year_czechia_price -1
WHERE round((((b.prum_mzda_za_rok * 100)/a.prum_mzda_za_rok_prev) - 100) , 2) > 10 
	OR round((((b.prum_cena_za_rok * 100)/a.prum_cena_za_rok_prev) - 100) , 2) > 10
;

/*
*OTÁZKA: Má výška HDP vliv na zmìny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výraznìji v jednom roce, 
*projeví se to na cenách potravin èi mzdách ve stejném nebo násdujícím roce výraznìjším rùstem?
*ODPOVÌÏ: V letech 2007, 2008 a 2017 pøi rùstu GDP rostou i ceny a mzdy.
*/

SELECT b.year_czechia_price ,
	round((((b.prum_mzda_za_rok * 100)/a.prum_mzda_za_rok_prev) - 100) , 2) AS mezirocni_mzda,
	round((((b.prum_cena_za_rok * 100)/a.prum_cena_za_rok_prev) - 100) , 2) AS mezirocni_cena,
	round((((b.GDP * 100)/a.GDP) - 100) , 2) AS mezirocni_GDP,
	CASE WHEN round((((b.GDP * 100)/a.GDP) - 100) , 2) > c.celk_prum_GDP 
		AND round((((b.prum_mzda_za_rok * 100)/a.prum_mzda_za_rok_prev) - 100) , 2) > c.celk_prum_mzda 
		AND round((((b.prum_cena_za_rok * 100)/a.prum_cena_za_rok_prev) - 100) , 2) > c.celk_prum_cena 
		THEN 'vyrazny'
	ELSE 'nizky'
	END AS posouzeni_vlivu
FROM(
	SELECT tadpspf.year_czechia_price ,
		round(AVG(prum_mzda), 2) AS prum_mzda_za_rok,
		round(AVG(prum_cena), 2) AS prum_cena_za_rok,
		GDP
	FROM t_andrea_dvorakova_projekt_sql_primary_final tadpspf
	GROUP BY tadpspf.year_czechia_price 
	) AS b
JOIN (
	SELECT tadpspf2.year_czechia_price,
		round(AVG(prum_mzda), 2) AS prum_mzda_za_rok_prev,
		round(AVG(prum_cena), 2) AS prum_cena_za_rok_prev,
		GDP
	FROM t_andrea_dvorakova_projekt_sql_primary_final tadpspf2 
	GROUP BY tadpspf2.year_czechia_price 
	) AS a
ON a.year_czechia_price = b.year_czechia_price -1
CROSS JOIN(
	SELECT 
		AVG(round((((b.prum_mzda_za_rok * 100)/a.prum_mzda_za_rok_prev) - 100) , 2)) AS celk_prum_mzda,
		AVG(round((((b.prum_cena_za_rok * 100)/a.prum_cena_za_rok_prev) - 100) , 2)) AS celk_prum_cena,
		AVG(round((((b.GDP * 100)/a.GDP) - 100) , 2)) AS celk_prum_GDP
	FROM(
		SELECT tadpspf.year_czechia_price ,
			round(AVG(prum_mzda), 2) AS prum_mzda_za_rok,
			round(AVG(prum_cena), 2) AS prum_cena_za_rok,
			GDP
		FROM t_andrea_dvorakova_projekt_sql_primary_final tadpspf
		GROUP BY tadpspf.year_czechia_price 
		) AS b
	JOIN (
		SELECT tadpspf2.year_czechia_price,
			round(AVG(prum_mzda), 2) AS prum_mzda_za_rok_prev,
			round(AVG(prum_cena), 2) AS prum_cena_za_rok_prev,
			GDP
		FROM t_andrea_dvorakova_projekt_sql_primary_final tadpspf2 
		GROUP BY tadpspf2.year_czechia_price 
		) AS a
	ON a.year_czechia_price = b.year_czechia_price -1) AS c;

