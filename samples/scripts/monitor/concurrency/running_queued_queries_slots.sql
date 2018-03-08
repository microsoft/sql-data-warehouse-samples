-- Total running queries and slots consumed
SELECT
	SUM(CASE WHEN r.[status] ='Running'   THEN 1 ELSE 0 END)							[running_queries],
	SUM(CASE WHEN r.[status] ='Running'   THEN rw.concurrency_slots_used ELSE 0 END)	[running_queries_slots],
	SUM(CASE WHEN r.[status] ='Suspended' THEN 1 ELSE 0 END)							[queued_queries],
	SUM(CASE WHEN rw.[state] ='Queued'    THEN rw.concurrency_slots_used ELSE 0 END)	[queued_queries_slots]
FROM
	sys.dm_pdw_exec_requests r 
	JOIN sys.dm_pdw_resource_waits rw on rw.request_id = r.request_id
WHERE
	( (r.[status] = 'Running' AND r.resource_class IS NOT NULL ) OR r.[status] ='Suspended' )
	AND rw.[type] ='UserConcurrencyResourceType'