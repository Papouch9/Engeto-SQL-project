CREATE OR REPLACE TABLE t_question2_goods_buy_possibility AS (
	(SELECT 
		tmk.chosen_year,
		ROUND(AVG(tmk.branch_payroll_average), 0) payroll_average_all,
		cpc.name,
		tmk.good_price_average_value,
		FLOOR(tmk.branch_payroll_average / tmk.good_price_average_value) buy_possibility
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
		ROUND(AVG(tmk.branch_payroll_average), 0) payroll_average_all,
		cpc.name,
		tmk.good_price_average_value,
		FLOOR(tmk.branch_payroll_average / tmk.good_price_average_value) buy_possibility
	FROM t_miroslav_kalik_project_sql_primary_final tmk
	LEFT JOIN czechia_price_category cpc 
		ON tmk.good_category = cpc.code
	WHERE tmk.good_category IN (111301, 114201)
	GROUP BY tmk.chosen_year, cpc.name
	ORDER BY tmk.chosen_year DESC 
	LIMIT 2)
);

CREATE OR REPLACE VIEW v_question2_goods_buy_possibility AS (
	SELECT *
	FROM t_question2_goods_buy_possibility
);
