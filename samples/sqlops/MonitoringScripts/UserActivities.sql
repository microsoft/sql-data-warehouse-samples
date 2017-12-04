
/*
-- Active Sessions
SELECT status, login_name, login_time, query_count, app_name
FROM sys.dm_pdw_exec_sessions 
WHERE status <> 'Closed' and session_id <> session_id();

-- Active Queries
SELECT * 
FROM sys.dm_pdw_exec_requests 
WHERE status not in ('Completed','Failed','Cancelled')
  AND session_id <> session_id()
ORDER BY submit_time DESC;

-- Waiting Queued queries
SELECT waits.session_id,
      waits.request_id,  
      requests.command,
      requests.status,
      requests.start_time,  
      waits.type,
      waits.state,
      waits.object_type,
      waits.object_name
FROM   sys.dm_pdw_waits waits
   JOIN  sys.dm_pdw_exec_requests requests
   ON waits.request_id=requests.request_id
--WHERE waits.request_id = 'QID####'
WHERE status <> 'Closed' and waits.session_id <> session_id() and waits.state = 'AcquireResources'
ORDER BY waits.object_name, waits.object_type, waits.state;
*/

SELECT * FROM
(
    -- Active Sessions
    SELECT COUNT(*) AS Active_Sessions
    FROM sys.dm_pdw_exec_sessions 
    WHERE status <> 'Closed' and session_id <> session_id()
) A, 
(
    -- Active Queries
    SELECT COUNT(*) AS Active_Queries
    FROM sys.dm_pdw_exec_requests 
    WHERE status not in ('Completed','Failed','Cancelled')
    AND session_id <> session_id()
) B,
(-- Waiting Queued queries
    SELECT COUNT(*) AS Queued_Queries
    FROM   sys.dm_pdw_waits waits
    JOIN  sys.dm_pdw_exec_requests requests
    ON waits.request_id=requests.request_id
    WHERE status <> 'Closed' and waits.session_id <> session_id() and waits.state = 'AcquireResources'
) C