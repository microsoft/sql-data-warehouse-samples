PRINT 'Info: Creating the ''microsoft.vw_sql_requests'' view';
GO

CREATE VIEW microsoft.vw_sql_requests
AS
(
	SELECT
		sr.request_id,
		sr.step_index,
		(CASE WHEN (sr.distribution_id = -1 ) THEN (SELECT pdw_node_id FROM sys.dm_pdw_nodes WHERE type = 'CONTROL') ELSE d.pdw_node_id END) AS pdw_node_id,
		sr.distribution_id,
		sr.status,
		sr.error_id,
		sr.start_time,
		sr.end_time,
		sr.total_elapsed_time,
		sr.row_count,
		sr.spid,
		sr.command
	FROM
		sys.pdw_distributions AS d
		RIGHT JOIN sys.dm_pdw_sql_requests AS sr ON d.distribution_id = sr.distribution_id
)
GO