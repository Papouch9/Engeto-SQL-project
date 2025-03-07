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

CREATE OR REPLACE VIEW v_question4_payroll_price_comparison AS (
	SELECT 
		chosen_year,
		ROUND(price_payroll_comparison, 2) price_payroll_difference
	FROM t_question4_payroll_price_comparison
	WHERE price_payroll_comparison > 10
);
