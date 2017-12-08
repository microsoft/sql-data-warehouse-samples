/* Monitor active sessions, queries, and queried queries */

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
) C,
(-- Waiting load queries
    SELECT Count(*) AS Loads
    FROM
       sys.dm_pdw_dms_external_work s INNER JOIN 
    sys.dm_pdw_exec_requests r
        ON r.request_id = s.request_id
    --WHERE command IN('%CREATE TABLE AS%', '%INSERT%') AND r.status = 'Running' 
) D