/*
*DOTAZ: Rostou v pr�b�hu let mzdy ve v�ech odv�tv�ch, nebo v n�kter�ch klesaj�?
*ODPV��: V letech viz. n�e podle SQL dotaz� mzdy klesaj�.
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
*DOTAZ: Kolik je mo�n� si koupit litr� ml�ka a kilogram� chleba za prvn� a posledn� srovnateln� obdob� v dostupn�ch datech cen a mezd?
*ODPOV��: Viz. vypis podle SQL doazu n�e.
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
*DOTAZ: Kter� kategorie potravin zdra�uje nejpomaleji (je u n� nejni��� percentu�ln� meziro�n� n�r�st)?
*ODPOV��: Nejpomaleji roste cena rostlinn�ho rot�rateln�ho tuku mezi rokem 2008 a 2009. Je to n��st o 0,01%.
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
*DOTAZ: Existuje rok, ve kter�m byl meziro�n� n�r�st cen potravin v�razn� vy��� ne� r�st mezd (v�t�� ne� 10 %)?
*ODPOV��: V ��dn�m roce nen� vy��� procentu�ln� r�st ne� 10%.
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
*OT�ZKA: M� v��ka HDP vliv na zm�ny ve mzd�ch a cen�ch potravin? Neboli, pokud HDP vzroste v�razn�ji v jednom roce, 
*projev� se to na cen�ch potravin �i mzd�ch ve stejn�m nebo n�sduj�c�m roce v�razn�j��m r�stem?
*ODPOV��: V letech 2007, 2008 a 2017 p�i r�stu GDP rostou i ceny a mzdy.
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

