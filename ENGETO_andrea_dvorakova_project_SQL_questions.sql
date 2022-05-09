/*
*DOTAZ: Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
*ODPVĚĎ: V letech viz. níže podle SQL dotazů mzdy klesají.
*/
SELECT
	vyber.branch_name,
	vyber.year_prev,
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
	ORDER BY branch_name, year_prev) AS vyber
WHERE vyber.mzda_mezirocne = 'mezirocni pokles';

/*
*DOTAZ: Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?
*ODPOVĚĎ: Viz. vypis podle SQL doazu níže.
*/

SELECT *
FROM(
	SELECT year_czechia_price,
		branch_name,
		category_name,
		prum_mzda,
		prum_cena,
		prum_mzda DIV prum_cena AS mnozstvi_nakupu,
		price_unit,
		CONCAT('Za prumernou mzdu ', prum_mzda, ' lze nakoupit ', prum_mzda DIV prum_cena, ' ',  price_unit, ' ', category_name, ' za prumernou cenu ', prum_cena) AS odpoved
	FROM t_andrea_dvorakova_projekt_sql_primary_final tadpspf 
	WHERE category_code = 114201 OR category_code = 111301) AS vyber /**'114201 = 'Mléko polotučné pasterované', '111301'= 'Chléb konzumní kmínový'**/
WHERE vyber.year_czechia_price = 2006 OR vyber.year_czechia_price = 2018
ORDER BY vyber.branch_name, vyber.year_czechia_price;

/*
*DOTAZ: Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
*ODPOVĚĎ: Nejpomaleji roste cena rostlinného rotíratelného tuku mezi rokem 2008 a 2009. Je to náůst o 0,01%.
*/

SELECT vyber_cen_rok_1.category_code,
	vyber_cen_rok_1.category_name,
	vyber_cen_rok_2.year_czechia_price,
	vyber_cen_rok_2.prum_cena_zarok_2,
	vyber_cen_rok_1.year_czechia_price,
	vyber_cen_rok_1.prum_cena_zarok,
	round((1 - vyber_cen_rok_2.prum_cena_zarok_2 / vyber_cen_rok_1.prum_cena_zarok) * 100, 2) AS price_growth
FROM
	(SELECT tadpspf.category_code, 
		tadpspf.category_name, 
		tadpspf.year_czechia_price, 
		AVG(tadpspf.prum_cena) AS prum_cena_zarok
	FROM t_andrea_dvorakova_projekt_sql_primary_final tadpspf
	GROUP BY category_code, tadpspf.year_czechia_price) vyber_cen_rok_1
JOIN(  
	SELECT tadpspf2.category_code,
		tadpspf2.year_czechia_price,
		AVG(tadpspf2.prum_cena) AS prum_cena_zarok_2
	FROM t_andrea_dvorakova_projekt_sql_primary_final tadpspf2
	GROUP BY category_code, tadpspf2.year_czechia_price) AS vyber_cen_rok_2
ON vyber_cen_rok_1.year_czechia_price = vyber_cen_rok_2.year_czechia_price + 1
	AND vyber_cen_rok_1.category_code = vyber_cen_rok_2.category_code
WHERE round((1 - (vyber_cen_rok_2.prum_cena_zarok_2 / vyber_cen_rok_1.prum_cena_zarok )) * 100, 2) > 0
ORDER BY price_growth 
LIMIT 1;

/*
*DOTAZ: Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
*ODPOVĚĎ: V žádném roce není vyšší procentuální růst než 10%.
*/

SELECT vyber_prum_rok_2.year_czechia_price,
	vyber_prum_rok_2.prum_mzda_za_rok,
	vyber_prum_rok_1.prum_mzda_za_rok_prev,
	round(vyber_prum_rok_2.prum_mzda_za_rok * 100 / vyber_prum_rok_1.prum_mzda_za_rok_prev- 100, 2) AS mezirocni_mzda,
	vyber_prum_rok_2.prum_cena_za_rok,
	vyber_prum_rok_1.prum_cena_za_rok_prev,
	round(vyber_prum_rok_2.prum_cena_za_rok * 100 / vyber_prum_rok_1.prum_cena_za_rok_prev - 100, 2) AS mezirocni_cena
FROM
	(
	SELECT tadpspf.year_czechia_price,
		round(AVG(prum_mzda), 2) AS prum_mzda_za_rok,
		round(AVG(prum_cena), 2) AS prum_cena_za_rok
	FROM t_andrea_dvorakova_projekt_sql_primary_final tadpspf
	GROUP BY tadpspf.year_czechia_price 
	) AS vyber_prum_rok_2
JOIN (
	SELECT tadpspf2.year_czechia_price,
		round(AVG(prum_mzda), 2) AS prum_mzda_za_rok_prev,
		round(AVG(prum_cena), 2) AS prum_cena_za_rok_prev
	FROM t_andrea_dvorakova_projekt_sql_primary_final tadpspf2 
	GROUP BY tadpspf2.year_czechia_price 
	) AS vyber_prum_rok_1
ON vyber_prum_rok_1.year_czechia_price = vyber_prum_rok_2.year_czechia_price - 1
WHERE round(vyber_prum_rok_2.prum_mzda_za_rok * 100 / vyber_prum_rok_1.prum_mzda_za_rok_prev - 100, 2) > 10 
	OR round(vyber_prum_rok_2.prum_cena_za_rok * 100 / vyber_prum_rok_1.prum_cena_za_rok_prev - 100, 2) > 10;

/*
*OTÁZKA: Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, 
*projeví se to na cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem?
*ODPOVĚĎ: V letech 2007, 2008 a 2017 při růstu GDP rostou i ceny a mzdy. Výraznější růst = vyšší růst než průměr.
*/

SELECT vyber_prum_rok_2.year_czechia_price,
	round(vyber_prum_rok_2.prum_mzda_za_rok * 100 / vyber_prum_rok_1.prum_mzda_za_rok_prev - 100, 2) AS mezirocni_mzda,
	round(vyber_prum_rok_2.prum_cena_za_rok * 100 / vyber_prum_rok_1.prum_cena_za_rok_prev - 100, 2) AS mezirocni_cena,
	round(vyber_prum_rok_2.GDP * 100 / vyber_prum_rok_1.GDP - 100, 2) AS mezirocni_GDP,
	CASE WHEN round(vyber_prum_rok_2.GDP * 100 / vyber_prum_rok_1.GDP - 100, 2) > celk_prum_vyber.celk_prum_GDP 
		AND round(vyber_prum_rok_2.prum_mzda_za_rok * 100 / vyber_prum_rok_1.prum_mzda_za_rok_prev - 100, 2) > celk_prum_vyber.celk_prum_mzda 
		AND round(vyber_prum_rok_2.prum_cena_za_rok * 100 / vyber_prum_rok_1.prum_cena_za_rok_prev - 100, 2) > celk_prum_vyber.celk_prum_cena 
		THEN 'vyrazny'
	ELSE 'nizky'
	END AS posouzeni_vlivu
FROM(
	SELECT tadpspf.year_czechia_price,
		round(AVG(prum_mzda), 2) AS prum_mzda_za_rok,
		round(AVG(prum_cena), 2) AS prum_cena_za_rok,
		GDP
	FROM t_andrea_dvorakova_projekt_sql_primary_final tadpspf
	GROUP BY tadpspf.year_czechia_price 
	) AS vyber_prum_rok_2
JOIN(
	SELECT tadpspf2.year_czechia_price,
		round(AVG(prum_mzda), 2) AS prum_mzda_za_rok_prev,
		round(AVG(prum_cena), 2) AS prum_cena_za_rok_prev,
		GDP
	FROM t_andrea_dvorakova_projekt_sql_primary_final tadpspf2 
	GROUP BY tadpspf2.year_czechia_price 
	) AS vyber_prum_rok_1
ON vyber_prum_rok_1.year_czechia_price = vyber_prum_rok_2.year_czechia_price - 1
CROSS JOIN(
	SELECT 
		AVG(round(vyber_prum_rok_2.prum_mzda_za_rok * 100 / vyber_prum_rok_1.prum_mzda_za_rok_prev - 100, 2) AS celk_prum_mzda,
		AVG(round(vyber_prum_rok_2.prum_cena_za_rok * 100 / vyber_prum_rok_1.prum_cena_za_rok_prev - 100, 2) AS celk_prum_cena,
		AVG(round(vyber_prum_rok_2.GDP * 100 / vyber_prum_rok_1.GDP - 100, 2) AS celk_prum_GDP
	FROM(
		SELECT tadpspf.year_czechia_price,
			round(AVG(prum_mzda), 2) AS prum_mzda_za_rok,
			round(AVG(prum_cena), 2) AS prum_cena_za_rok,
			GDP
		FROM t_andrea_dvorakova_projekt_sql_primary_final tadpspf
		GROUP BY tadpspf.year_czechia_price 
		) AS vyber_prum_rok_2
	JOIN(
		SELECT tadpspf2.year_czechia_price,
			round(AVG(prum_mzda), 2) AS prum_mzda_za_rok_prev,
			round(AVG(prum_cena), 2) AS prum_cena_za_rok_prev,
			GDP
		FROM t_andrea_dvorakova_projekt_sql_primary_final tadpspf2 
		GROUP BY tadpspf2.year_czechia_price 
		) AS vyber_prum_rok_1
	ON vyber_prum_rok_1.year_czechia_price = vyber_prum_rok_2.year_czechia_price - 1) AS celk_prum_vyber;

