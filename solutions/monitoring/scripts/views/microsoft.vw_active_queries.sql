PRINT 'Info: Creating the ''microsoft.vw_active_queries'' view';
GO

CREATE VIEW microsoft.vw_active_queries
AS
SELECT
	*
FROM
	sys.dm_pdw_exec_requests
WHERE
	status NOT IN ('Completed', 'Failed');
GO