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

CREATE OR REPLACE VIEW v_question1_payroll_increasing AS (
	SELECT 
		chosen_year,
		name,
		difference
	FROM t_question1_payroll_increasing
	WHERE difference < 0
);
