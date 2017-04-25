---------------------------------------------------------------------------------------------------
-- Applies To: Azure SQL Data Warehouse, Microsoft Analytics Platform System (APS)
-- Author: Matt Usher (Microsoft)
-- Last Updated: 2016-05-25
---------------------------------------------------------------------------------------------------
-- The script below lists the current queries executed against the SQL Data Warehouse
-- and the amount of granted, requested, and ideal memory. This script can be used to 
-- help identify queries that would benefit from larger resource class assignments. The
-- statement returns the following columns:

-- request_id: Unique numeric id for the request.
-- resource_class: The resource class for the request. 
-- command: The text of the request as submitted by the user
-- granted_memory_kb: Total amount of memory actually granted in kilobytes. 
-- requested_memory_kb: Total requested amount of memory in kilobytes
-- ideal_memory_kb: Size, in kilobytes, of the memory grant to fit everything into physical
--                  memory. This is based on the cardinality estimate for the query. 
-- requested_memory_gap: The difference in memory between the ideal and granted amounds. A value
--                       greater than 0 indicates a query that could use additional memory via
--                       a larger resource class.

SELECT DISTINCT
	pr.request_id,
	pr.resource_class,
	pr.command,
	[mem].granted_memory_kb, 
	[mem].requested_memory_kb,
	[mem].ideal_memory_kb,
	CASE 
		WHEN ( [mem].ideal_memory_kb - [mem].granted_memory_kb ) < 0 THEN 0
		ELSE ( [mem].ideal_memory_kb - [mem].granted_memory_kb )
	END AS requested_memory_gap
FROM
	-- Get all pdw requests
	sys.dm_pdw_exec_requests AS pr
	-- For each request_id, add the associated SQL requests on the Compute nodes.
	JOIN sys.dm_pdw_sql_requests AS psqlr ON psqlr.request_id = pr.request_id
	-- Add in the memory grant information
	JOIN sys.dm_pdw_nodes_exec_query_memory_grants AS [mem] ON [mem].[session_id] = psqlr.[spid]
WHERE
	1=1
	AND	pr.resource_class IS NOT NULL;