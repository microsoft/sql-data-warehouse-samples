/* Latest backup deatils */
SELECT TOP 1
	start_time									[start_time]
	, end_time									[end_time]
	, progress									[progress_percent]
	, DATEDIFF(SECOND, start_time, end_time)	[duration_seconds]
FROM
	[sys].[pdw_loader_backup_runs]
ORDER BY
	[run_id] DESC;