/* Calculating memory grants per table */
SELECT schm_name + '.' + table_name AS Table_name
	--,CAST((table_overhead * 1.0 + column_size + short_string_size + long_string_size) AS DECIMAL(18, 2)) AS est_mem_grant_B
	,CAST((table_overhead * 1.0 + column_size + short_string_size + long_string_size) / 1048576 AS DECIMAL(18, 2)) AS est_mem_grant_MiB
	--,CAST((table_overhead * 1.0 + column_size + short_string_size + long_string_size) / 1073741824 AS DECIMAL(18, 2)) AS est_mem_grant_GiB
FROM (
	SELECT schm_name
		,table_name
		,75497472 AS table_overhead
		,column_count * 1048576 * 8 AS column_size
		,short_string_count * 1048576 * 32 AS short_string_size
		,(long_string_count * 16777216) - (32 * long_string_count) AS long_string_size
	FROM (
		SELECT schm_name
			,table_name
			,SUM(CAST(column_count AS BIGINT)) AS column_count
			,ISNULL(SUM(CAST(short_string_count AS BIGINT)), 0) AS short_string_count
			,ISNULL(SUM(CAST(long_string_count AS BIGINT)), 0) AS long_string_count
		FROM (
			SELECT sm.name AS schm_name
				,tb.name AS table_name
				,COUNT(CAST(co.column_id AS BIGINT)) AS column_count
				,CASE 
					WHEN co.system_type_id IN (
							167
							,175
							,231
							,239
							)
						AND co.max_length <= 32
						THEN COUNT(CAST(co.column_id AS BIGINT))
					END AS short_string_count
				,CASE 
					WHEN co.system_type_id IN (
							167
							,175
							,231
							,239
							)
						AND co.max_length > 32
						THEN COUNT(CAST(co.column_id AS BIGINT))
					END AS long_string_count
			FROM sys.schemas AS sm
			INNER JOIN sys.tables AS tb ON sm.[schema_id] = tb.[schema_id]
			INNER JOIN sys.columns AS co ON tb.[object_id] = co.[object_id]
			GROUP BY sm.name
				,tb.name
				,co.system_type_id
				,co.max_length
			) C
		GROUP BY schm_name
			,table_name
		) B
	) A
