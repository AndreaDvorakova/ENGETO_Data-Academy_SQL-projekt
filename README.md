<h1>Projek SQL - Příprava datových podkladů ohledně cen základních potravin, jejich dostupnosti široké veřejnosti</h1>

Cílem projektu je odpovědět na pár definovaných výzkumných otázek, které adresují dostupnost základních potravin široké veřejnosti. Níže jsou defonované základní otázky,
na které se pokusí odpovědět. 
Jako základ jsou připravené robustní datové podklady, ve kterých je vidět porovnání dostupnosti potravin na základě průměrných příjmů za určité časové období. 
Viz. ENGETO_t_andrea_dvorakova_project_SQL_primary_final.sql

<h2>Použité datové sady:</h2>

<h3>Primární tabulky:</h3>

* czechia_payroll – Informace o mzdách v různých odvětvích za několikaleté období. Datová sada pochází z Portálu otevřených dat ČR.
* czechia_payroll_calculation – Číselník kalkulací v tabulce mezd.
* czechia_payroll_industry_branch – Číselník odvětví v tabulce mezd.
* czechia_payroll_unit – Číselník jednotek hodnot v tabulce mezd.
* czechia_payroll_value_type – Číselník typů hodnot v tabulce mezd.
* czechia_price – Informace o cenách vybraných potravin za několikaleté období. Datová sada pochází z Portálu otevřených dat ČR.
* czechia_price_category – Číselník kategorií potravin, které se vyskytují v našem přehledu.

<h3>Číselníky sdílených informací o ČR:</h3>

* czechia_region – Číselník krajů České republiky dle normy CZ-NUTS 2.
* czechia_district – Číselník okresů České republiky dle normy LAU.

<h3>Dodatečné tabulky:</h3>

* countries - Všemožné informace o zemích na světě, například hlavní město, měna, národní jídlo nebo průměrná výška populace.
* economies - HDP, GINI, daňová zátěž, atd. pro daný stát a rok.

Jako dodatečný materiál je připravená i tabulka s HDP, GINI koeficientem a populací dalších evropských států ve stejném období, jako primární přehled pro ČR.
Viz. ENGETO_t_andrea_dvorakova_project_SQL_secondary_final.sql

<h2>Výzkumné otázky:</h2>

1/ Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
2/ Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?
3/ Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
4/ Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
5/ Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, 
   se to na cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem?
