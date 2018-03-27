PRINT 'Info: Creating the ''microsoft.vw_query_queue'' view';
GO

CREATE VIEW microsoft.vw_query_queue
AS
SELECT
    *
    , [queued_sec] = DATEDIFF(MILLISECOND, request_time, GETDATE()) / 1000.0
FROM
    sys.dm_pdw_resource_waits
WHERE
    [state] = 'Queued';
GO