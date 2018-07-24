PRINT 'Info: Creating the ''microsoft.vw_query_steps'' view';
GO

CREATE VIEW microsoft.vw_query_steps
AS
SELECT
	r.[request_id]
	, r.[session_id]
	, r.[status]
	, r.[total_elapsed_time] [duration]
	, r.[label]
	, r.[resource_class]
	, r.[command]
	, rs.step_index
	, rs.operation_type
	, rs.location_type
	, rs.[status] [step_status]
	, rs.[total_elapsed_time] [step_duration]
	, rs.[row_count] [step_rows]
FROM
	sys.dm_pdw_exec_requests r
	JOIN sys.dm_pdw_request_steps rs ON rs.request_id = r.request_id;
GO