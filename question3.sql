CREATE OR REPLACE TABLE t_question3_price_increasing AS (
	SELECT
		tmk.chosen_year,
		cpc.name,
		tmk.good_price_average_value,
		LAG(good_price_average_value) OVER (PARTITION BY tmk.good_category ORDER BY tmk.chosen_year) AS last_year_good_price_average_value,
		tmk.good_price_average_value - LAG(good_price_average_value) OVER (PARTITION BY tmk.good_category ORDER BY tmk.chosen_year) AS difference,
		ROUND((((tmk.good_price_average_value / LAG(good_price_average_value) OVER (PARTITION BY tmk.good_category ORDER BY tmk.chosen_year)) - 1) * 100), 2) AS pct_difference
	FROM t_miroslav_kalik_project_sql_primary_final tmk
	JOIN czechia_price_category cpc 
		ON tmk.good_category = cpc.code 
	GROUP BY tmk.chosen_year, tmk.good_category
	ORDER BY cpc.name, tmk.chosen_year
);

CREATE OR REPLACE VIEW v_question3_price_increasing AS (
	SELECT
		name, 
		ROUND(AVG(pct_difference), 2) average_difference
	FROM t_question3_price_increasing
	GROUP BY name
	ORDER BY average_difference
	LIMIT 1
);
