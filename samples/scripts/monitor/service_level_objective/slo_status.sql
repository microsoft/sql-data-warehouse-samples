-- Must be run from the [master] database

-- One 
SELECT
	db.[name] AS [Name],
	ds.[edition] AS [Edition],
	ds.[service_objective] AS [ServiceObject]
FROM
	[sys].[database_service_objectives] ds
	JOIN [sys].[databases] db
		ON ds.database_id = db.database_id
WHERE
	1=1
	AND ds.edition = 'DataWarehouse';

-- Loop to monitor a scaling event
WHILE
(
	SELECT TOP 1
		[state_desc]
	FROM
		[sys].[dm_operation_status]
	WHERE
		1=1
		AND [resource_type_desc] = 'Database'
		AND [operation] = 'ALTER DATABASE'
	ORDER BY
		[start_time] DESC
) = 'IN_PROGRESS'
BEGIN

	RAISERROR('Scale operation in progress',0,0) WITH NOWAIT;
	WAITFOR DELAY '00:00:05';

END

PRINT 'Complete';