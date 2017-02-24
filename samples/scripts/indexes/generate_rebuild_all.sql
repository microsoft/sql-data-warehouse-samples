-- Lists out the T-SQL necessary to rebuild CLUSTERED COLUMNSTORE indexes 
SELECT DISTINCT
	'ALTER INDEX ALL ON ' + s.[name] + '.' + t.[name] + ' REBUILD;' AS [T-SQL to Rebuild Index]
FROM 
	[sys].[pdw_nodes_column_store_row_groups] rg
	JOIN [sys].[pdw_nodes_tables] pt
		ON rg.[object_id] = pt.[object_id] AND rg.[pdw_node_id] = pt.[pdw_node_id] AND pt.[distribution_id] = rg.[distribution_id]
	JOIN sys.[pdw_table_mappings] tm 
		ON pt.[name] = tm.[physical_name]
	INNER JOIN [sys].[tables] t 
		ON tm.[object_id] = t.[object_id]
	INNER JOIN [sys].[schemas] s
		ON t.[schema_id] = s.[schema_id]
ORDER BY
	1;