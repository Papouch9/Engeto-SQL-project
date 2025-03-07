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
		round(avg(cpay.value), 0) branch_payroll_average,
		cpri.category_code good_category,
		round(avg(cpri.value), 0) good_price_average_value,
		eco.GDP hdp
	FROM czechia_payroll cpay
	JOIN czechia_price cpri
		ON cpay.payroll_year = year(cpri.date_from)
	JOIN economies eco
		ON cpay.payroll_year = eco.`year` 
	WHERE eco.country = 'Czech Republic' AND cpay.industry_branch_code IS NOT null
	GROUP BY cpay.payroll_year, cpay.industry_branch_code, YEAR(cpri.date_from), cpri.category_code
);

CREATE OR REPLACE TABLE t_miroslav_kalik_project_sql_secondary_final AS (
	SELECT 
		eco.country,
		eco.year,
		round(eco.GDP, 0) GDP,
		eco.gini,
		cou.population 
	FROM economies eco 
	RIGHT JOIN countries cou 
		ON eco.country = cou.country
	WHERE cou.continent = 'Europe' AND 
		eco.year BETWEEN (
			SELECT 
				min(tmk.chosen_year)
			FROM t_miroslav_kalik_project_sql_primary_final tmk)
				AND (
			SELECT
				max(tmk.chosen_year)
			FROM t_miroslav_kalik_project_sql_primary_final tmk)
	ORDER BY eco.country, eco.year
);


CREATE OR REPLACE TABLE t_question1_payroll_increasing AS (
	SELECT
		tmk.chosen_year,
		cpib.name, 
		tmk.branch_payroll_average,
		LAG(tmk.branch_payroll_average) OVER (PARTITION BY tmk.branch_code ORDER BY tmk.chosen_year) AS last_year_payroll_average,
		tmk.branch_payroll_average - LAG(tmk.branch_payroll_average) OVER (PARTITION BY tmk.branch_code ORDER BY tmk.chosen_year) difference
	FROM t_miroslav_kalik_project_sql_primary_final tmk
	LEFT JOIN czechia_payroll_industry_branch cpib 
		ON tmk.branch_code = cpib.code 
	WHERE branch_code IS NOT NULL
	GROUP BY tmk.chosen_year, tmk.branch_code
	ORDER BY cpib.name, tmk.chosen_year
);


CREATE OR REPLACE TABLE t_question2_goods_buy_possibility AS (
	(SELECT 
		tmk.chosen_year,
		round(AVG(tmk.branch_payroll_average), 0) payroll_average_all,
		cpc.name,
		tmk.good_price_average_value,
		floor(tmk.branch_payroll_average / tmk.good_price_average_value) buy_possibility
	FROM t_miroslav_kalik_project_sql_primary_final tmk
	LEFT JOIN czechia_price_category cpc 
		ON tmk.good_category = cpc.code
	WHERE tmk.good_category IN (111301, 114201)
	GROUP BY tmk.chosen_year, cpc.name
	ORDER BY tmk.chosen_year ASC 
	LIMIT 2)
UNION 
	(SELECT 
		tmk.chosen_year,
		round(AVG(tmk.branch_payroll_average), 0) payroll_average_all,
		cpc.name,
		tmk.good_price_average_value,
		floor(tmk.branch_payroll_average / tmk.good_price_average_value) buy_possibility
	FROM t_miroslav_kalik_project_sql_primary_final tmk
	LEFT JOIN czechia_price_category cpc 
		ON tmk.good_category = cpc.code
	WHERE tmk.good_category IN (111301, 114201)
	GROUP BY tmk.chosen_year, cpc.name
	ORDER BY tmk.chosen_year DESC 
	LIMIT 2)
);

CREATE OR REPLACE TABLE t_question3_price_increasing AS (
	SELECT
		tmk.chosen_year,
		cpc.name,
		tmk.good_price_average_value,
		LAG(good_price_average_value) OVER (PARTITION BY tmk.good_category ORDER BY tmk.chosen_year) AS last_year_good_price_average_value,
		tmk.good_price_average_value - LAG(good_price_average_value) OVER (PARTITION BY tmk.good_category ORDER BY tmk.chosen_year) AS difference,
		round((((tmk.good_price_average_value / LAG(good_price_average_value) OVER (PARTITION BY tmk.good_category ORDER BY tmk.chosen_year)) - 1) * 100), 2) AS pct_difference
	FROM t_miroslav_kalik_project_sql_primary_final tmk
	JOIN czechia_price_category cpc 
		ON tmk.good_category = cpc.code 
	GROUP BY tmk.chosen_year, tmk.good_category
	ORDER BY cpc.name, tmk.chosen_year
);

CREATE OR REPLACE TABLE t_question4_payroll_price_comparison (
	SELECT
		chosen_year,
		branch_payroll_average,
		LAG(branch_payroll_average) OVER (PARTITION BY branch_code ORDER BY chosen_year) last_year_bpa,
		(branch_payroll_average / LAG(branch_payroll_average) OVER (PARTITION BY branch_code ORDER BY chosen_year)) * 100 - 100 payroll_pct_difference,
		good_price_average_value,
		LAG(good_price_average_value) OVER (PARTITION BY good_category ORDER BY chosen_year) last_year_gpav,
		(good_price_average_value / LAG(good_price_average_value) OVER (PARTITION BY good_category ORDER BY chosen_year)) * 100 -100 price_pct_difference,
		(((good_price_average_value / LAG(good_price_average_value) OVER (PARTITION BY good_category ORDER BY chosen_year)) * 100 -100)) - (((branch_payroll_average / LAG(branch_payroll_average) OVER (PARTITION BY branch_code ORDER BY chosen_year)) * 100 - 100)) price_payroll_comparison
		FROM t_miroslav_kalik_project_sql_primary_final
	GROUP BY chosen_year 
);

CREATE OR REPLACE TABLE t_question5_hdp_payroll_price_comparison AS (
	SELECT 
		chosen_year,
		avg(hdp) hdp,
		lag(avg(hdp)) OVER (ORDER BY chosen_year) last_year_hpd,
		(avg(hdp) / lag(avg(hdp)) OVER (ORDER BY chosen_year)) * 100 - 100 hdp_difference, 
		avg(branch_payroll_average),
		lag(avg(branch_payroll_average)) OVER (ORDER BY chosen_year) last_year_payroll_average,
		(avg(branch_payroll_average) / lag(avg(branch_payroll_average)) OVER (ORDER BY chosen_year)) * 100 - 100 payroll_difference,
		avg(good_price_average_value) price_average,
		lag(avg(good_price_average_value)) OVER (ORDER BY chosen_year) last_year_price_average,
		(avg(good_price_average_value) / lag(avg(good_price_average_value)) OVER (ORDER BY chosen_year)) * 100 - 100 price_difference
	FROM t_miroslav_kalik_project_sql_primary_final
	GROUP BY chosen_year

);


CREATE OR REPLACE VIEW v_question1_payroll_increasing AS (
	SELECT 
		chosen_year,
		name,
		difference
	FROM t_question1_payroll_increasing
	WHERE difference < 0
);


CREATE OR REPLACE VIEW v_question2_goods_buy_possibility AS (
	SELECT *
	FROM t_question2_goods_buy_possibility
);

CREATE OR REPLACE VIEW v_question3_price_increasing AS (
	SELECT
		name, 
		round(avg(pct_difference), 2) average_difference
	FROM t_question3_price_increasing
	GROUP BY name
	ORDER BY average_difference
	LIMIT 1
);

CREATE OR REPLACE VIEW v_question4_payroll_price_comparison AS (
	SELECT 
		chosen_year,
		round(price_payroll_comparison, 2) price_payroll_difference
	FROM t_question4_payroll_price_comparison
	WHERE price_payroll_comparison > 10
);

CREATE OR REPLACE VIEW v_question5_hdp_payroll_price_comparison AS (
	SELECT
		chosen_year,
		round(hdp_difference, 2) hdp_difference,
		round(payroll_difference, 2) payroll_difference,
		round(lead(payroll_difference) OVER (ORDER BY chosen_year), 2) next_year_payroll_difference,
		round(price_difference, 2) price_difference,
		round(lead(price_difference) OVER (ORDER BY chosen_year), 2) next_year_price_difference
	FROM t_question5_hdp_payroll_price_comparison
	WHERE hdp_difference > 5
);
