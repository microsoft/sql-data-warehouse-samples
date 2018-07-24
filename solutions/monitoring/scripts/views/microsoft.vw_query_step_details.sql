PRINT 'Info: Creating the ''microsoft.vw_query_step_details'' view';
GO

CREATE VIEW microsoft.vw_query_step_details
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
	, sr.[pdw_node_id]
	, sr.[status] [request_status]
	, sr.[total_elapsed_time] [sql_duration]
	, sr.[row_count] [sql_row_count]
	, dw.[dms_step_index]
	, dw.[status] [dms_status]
	, dw.[bytes_per_sec]
	, dw.[bytes_processed]
	, dw.[rows_processed]
	, dw.[total_elapsed_time] [dms_duration]
FROM
	sys.dm_pdw_exec_requests r
	LEFT OUTER JOIN sys.dm_pdw_request_steps rs ON rs.request_id = r.request_id
	LEFT OUTER JOIN sys.dm_pdw_dms_workers dw ON dw.request_id = rs.request_id AND dw.step_index = rs.step_index
	LEFT OUTER JOIN sys.dm_pdw_sql_requests sr ON sr.request_id = rs.request_id AND sr.step_index = rs.step_index;
GO