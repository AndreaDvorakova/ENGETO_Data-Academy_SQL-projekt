<h1>Projek SQL - Příprava datových podkladů ohledně cen základních potravin, jejich dostupnosti široké veřejnosti</h1>

<p>Cílem projektu je odpovědět na pár definovaných výzkumných otázek, které adresují dostupnost základních potravin široké veřejnosti. Níže jsou defonované základní otázky,
na které se pokusí odpovědět. 
Jako základ jsou připravené robustní datové podklady, ve kterých je vidět porovnání dostupnosti potravin na základě průměrných příjmů za určité časové období. 
Viz. <a
        href="https://github.com/AndreaDvorakova/ENGETO_Data-Academy_SQL-projekt/blob/d43394b155ca7c2576b0e38fd1e7f82bdf3cd587/ENGETO_t_andrea_dvorakova_project_SQL_primary_final.sql">ENGETO_t_andrea_dvorakova_project_SQL_primary_final.sql</a></p>

<h2>Použité datové sady:</h2>

<h3>Primární tabulky:</h3>

<ul>
<li>czechia_payroll – Informace o mzdách v různých odvětvích za několikaleté období. Datová sada pochází z Portálu otevřených dat ČR.</li>
<li>czechia_payroll_calculation – Číselník kalkulací v tabulce mezd.</li>
<li>czechia_payroll_industry_branch – Číselník odvětví v tabulce mezd.</li>
<li>czechia_payroll_unit – Číselník jednotek hodnot v tabulce mezd.</li>
<li>czechia_payroll_value_type – Číselník typů hodnot v tabulce mezd.</li>
<li>czechia_price – Informace o cenách vybraných potravin za několikaleté období. Datová sada pochází z Portálu otevřených dat ČR.</li>
<li>czechia_price_category – Číselník kategorií potravin, které se vyskytují v našem přehledu.</li>
</ul>

<h3>Číselníky sdílených informací o ČR:</h3>

<li>czechia_region – Číselník krajů České republiky dle normy CZ-NUTS 2.</li>
<li>czechia_district – Číselník okresů České republiky dle normy LAU.</li>

<h3>Dodatečné tabulky:</h3>

<li>countries - Všemožné informace o zemích na světě, například hlavní město, měna, národní jídlo nebo průměrná výška populace.</li>
<li>economies - HDP, GINI, daňová zátěž, atd. pro daný stát a rok.</li>

<p>Jako dodatečný materiál je připravená i tabulka s HDP, GINI koeficientem a populací dalších evropských států ve stejném období, jako primární přehled pro ČR.
Viz. <a
        href="https://github.com/AndreaDvorakova/ENGETO_Data-Academy_SQL-projekt/blob/d43394b155ca7c2576b0e38fd1e7f82bdf3cd587/ENGETO_t_andrea_dvorakova_project_SQL_secondary_final.sql">ENGETO_t_andrea_dvorakova_project_SQL_secondary_final.sql</a></p>

<h2>Výzkumné otázky:</h2>

<ol>
<li>Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?</li>
<li>Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?</li>
<li>Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?</li>
<li>Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?</li>
<li>Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, 
   se to na cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem?</li>
</ol>

<p>Veškeré odpovědi jsou obsažené v sql: <a
        href="https://github.com/AndreaDvorakova/ENGETO_Data-Academy_SQL-projekt/blob/d43394b155ca7c2576b0e38fd1e7f82bdf3cd587/ENGETO_andrea_dvorakova_project_SQL_questions.sql">ENGETO_t_andrea_dvorakova_project_SQL_questions.sql</a>.</p>

<h3>Odpovědi:</h3>

<ol>
<li>Celkem ve 23 případech poklesly meziročně mzdy. V 10 odvětvích se pokles týkal roku 2013. Dále se nejčastěji (4x) se objevilo odvětví Těžba a dobývání. Nejvýznamnější pokles s hodnotou -9 byl v Peněžnictví a pojišťovnictví. Větší detail zobrazí sql dotaz v již zmíněném file ENGETO_t_andrea_dvorakova_project_SQL_questions.sql</li>
<li>SQL dotaz zobrazí obecně seznam jednotlivých odvětví s jejich průměrnou mzdou za roky 2006 a 2018. Dále informace o průměrné ceně chlebu a mléka v těchto letech. Poslední sloupec tabulky pak poskytuje odpověď kolik kg chleba nebo l mléka je možné koupit za průměrnou mzdu v daném odvětví.</li>
<li>Nejpomaleji roste cena rostlinného roztíratelného tuku mezi rokem 2008 a 2009. Jedná se o nárůst o 0,01%.</li>
<li>V žádném roce není vyšší procentuální růst než 10%. Největší nárůst cen lze pozorovat v roce 2017 a to konkrétně 9,63%, ovšem v tomto stejném roce se mzdy změnily o 6,4 procent. Největší rozdíl (9,66%) mezi změnou mezd a cen meziročně byl v roce 2009, kdy mzdy rostly, ale ceny poklesly.</li>
<li>Pro účely této otázky jako výraznou změnu cen chápeme změny, které jsou nad průměrem meziročních procentuálních změn mezi roky 2006 až 2018. Stejnou logiku používáme při posuzování mezd. Na základě toho v letech 2007, 2008 a 2017 při růstu GDP rostou ceny a mzdy významně, tj. jsou nad celkovým průměrem.</li>
</ol>
