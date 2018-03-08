-- Total running queries and slots consumed
SELECT
	RunningQueries  = SUM(CASE WHEN r.[status] ='Running'   THEN 1 ELSE 0 END)
	,SlotsGranted   = SUM(CASE WHEN r.[status] ='Running'   THEN rw.concurrency_slots_used ELSE 0 END)
	,QueuedQueries  = SUM(CASE WHEN r.[status] ='Suspended' THEN 1 ELSE 0 END)
	,SlotsQueued    = SUM(CASE WHEN rw.[state] ='Queued'    THEN rw.concurrency_slots_used ELSE 0 END)
FROM
	sys.dm_pdw_exec_requests r 
	JOIN sys.dm_pdw_resource_waits rw on rw.request_id = r.request_id
WHERE
	( (r.[status] = 'Running' AND r.resource_class IS NOT NULL ) OR r.[status] ='Suspended' )
	AND rw.[type] ='UserConcurrencyResourceType'