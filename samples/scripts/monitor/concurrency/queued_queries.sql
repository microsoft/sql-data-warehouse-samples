-- Displays wait information for any query that is queued waiting for exeuction
SELECT
	*
     , [queued_sec] = DATEDIFF(MILLISECOND, request_time, GETDATE()) / 1000.0 
FROM
	sys.dm_pdw_resource_waits 
WHERE
	[state] ='Queued'
ORDER BY
	queued_sec DESC;