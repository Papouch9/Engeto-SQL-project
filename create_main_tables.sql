/*
Engeto_SQL_project: čtvrtý projekt do Engeto Online Python Akademie
author: Miroslav Kalík
email: mira.kalik@seznam.cz
discord: mira_47271
*/

CREATE OR REPLACE TABLE t_miroslav_kalik_project_SQL_primary_final AS (
		SELECT
		cpay.payroll_year chosen_year,
		cpay.industry_branch_code branch_code,
		ROUND(AVG(cpay.value), 0) branch_payroll_average,
		cpri.category_code good_category,
		ROUND(AVG(cpri.value), 0) good_price_average_value,
		eco.GDP hdp
	FROM czechia_payroll cpay
	JOIN czechia_price cpri
		ON cpay.payroll_year = YEAR(cpri.date_from)
	JOIN economies eco
		ON cpay.payroll_year = eco.`year` 
	WHERE eco.country = 'Czech Republic' AND cpay.industry_branch_code IS NOT NULL
	GROUP BY cpay.payroll_year, cpay.industry_branch_code, YEAR(cpri.date_from), cpri.category_code
);

CREATE OR REPLACE TABLE t_miroslav_kalik_project_sql_secondary_final AS (
	SELECT 
		eco.country,
		eco.year,
		ROUND(eco.GDP, 0) GDP,
		eco.gini,
		cou.population 
	FROM economies eco 
	RIGHT JOIN countries cou 
		ON eco.country = cou.country
	WHERE cou.continent = 'Europe' AND 
		eco.year BETWEEN (
			SELECT 
				MIN(tmk.chosen_year)
			FROM t_miroslav_kalik_project_sql_primary_final tmk)
				AND (
			SELECT
				MAX(tmk.chosen_year)
			FROM t_miroslav_kalik_project_sql_primary_final tmk)
	ORDER BY eco.country, eco.year
);
