SELECT * 
	FROM 
	(SELECT	COUNT(*) AS Memory_Limitation
	FROM    sys.[schemas] sm
	JOIN    sys.[tables] tb													ON  sm.[schema_id]          = tb.[schema_id]
	JOIN    sys.[pdw_table_mappings] mp										ON  tb.[object_id]          = mp.[object_id]
	JOIN    sys.[pdw_nodes_tables] nt										ON  nt.[name]               = mp.[physical_name]
	JOIN	sys.[dm_pdw_nodes_db_column_store_row_group_physical_stats]	ps	ON  ps.[object_id]          = nt.[object_id]
																			AND ps.[pdw_node_id]        = nt.[pdw_node_id]
																			AND ps.[distribution_id]    = nt.[distribution_id]
	WHERE trim_reason_desc = 'MEMORY_LIMITATION') AS A, 
	(SELECT	COUNT(*) AS Bulkload
	FROM    sys.[schemas] sm
	JOIN    sys.[tables] tb													ON  sm.[schema_id]          = tb.[schema_id]
	JOIN    sys.[pdw_table_mappings] mp										ON  tb.[object_id]          = mp.[object_id]
	JOIN    sys.[pdw_nodes_tables] nt										ON  nt.[name]               = mp.[physical_name]
	JOIN	sys.[dm_pdw_nodes_db_column_store_row_group_physical_stats]	ps	ON  ps.[object_id]          = nt.[object_id]
																			AND ps.[pdw_node_id]        = nt.[pdw_node_id]
																			AND ps.[distribution_id]    = nt.[distribution_id]
	WHERE trim_reason_desc = 'BULKLOAD') AS B, 
	(SELECT	COUNT(*) AS Dictionary_Size
	FROM    sys.[schemas] sm
	JOIN    sys.[tables] tb													ON  sm.[schema_id]          = tb.[schema_id]
	JOIN    sys.[pdw_table_mappings] mp										ON  tb.[object_id]          = mp.[object_id]
	JOIN    sys.[pdw_nodes_tables] nt										ON  nt.[name]               = mp.[physical_name]
	JOIN	sys.[dm_pdw_nodes_db_column_store_row_group_physical_stats]	ps	ON  ps.[object_id]          = nt.[object_id]
																			AND ps.[pdw_node_id]        = nt.[pdw_node_id]
																			AND ps.[distribution_id]    = nt.[distribution_id]
	WHERE trim_reason_desc = 'DICTIONARY_SIZE') AS C