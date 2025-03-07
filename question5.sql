CREATE OR REPLACE TABLE t_question5_hdp_payroll_price_comparison AS (
	SELECT 
		chosen_year,
		AVG(hdp) hdp,
		LAG(AVG(hdp)) OVER (ORDER BY chosen_year) last_year_hpd,
		(AVG(hdp) / lag(AVG(hdp)) OVER (ORDER BY chosen_year)) * 100 - 100 hdp_difference, 
		AVG(branch_payroll_average),
		LAG(AVG(branch_payroll_average)) OVER (ORDER BY chosen_year) last_year_payroll_average,
		(AVG(branch_payroll_average) / LAG(AVG(branch_payroll_average)) OVER (ORDER BY chosen_year)) * 100 - 100 payroll_difference,
		AVG(good_price_average_value) price_average,
		LAG(AVG(good_price_average_value)) OVER (ORDER BY chosen_year) last_year_price_average,
		(AVG(good_price_average_value) / LAG(AVG(good_price_average_value)) OVER (ORDER BY chosen_year)) * 100 - 100 price_difference
	FROM t_miroslav_kalik_project_sql_primary_final
	GROUP BY chosen_year
);

CREATE OR REPLACE VIEW v_question5_hdp_payroll_price_comparison AS (
	SELECT
		chosen_year,
		ROUND(hdp_difference, 2) hdp_difference,
		ROUND(payroll_difference, 2) payroll_difference,
		ROUND(LEAD(payroll_difference) OVER (ORDER BY chosen_year), 2) next_year_payroll_difference,
		ROUND(price_difference, 2) price_difference,
		ROUND(LEAD(price_difference) OVER (ORDER BY chosen_year), 2) next_year_price_difference
	FROM t_question5_hdp_payroll_price_comparison
	WHERE hdp_difference > 5
);
