SELECT *
    FROM sys.dm_pdw_exec_sessions 
    WHERE status <> 'Closed' and session_id <> session_id()