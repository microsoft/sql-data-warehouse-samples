-- Monitor tempdb
SELECT
    ssu.pdw_node_id,
    --SUM((ssu.user_objects_alloc_page_count * 8)) AS 'Space Allocated For User Objects (in KB)',
    --SUM((ssu.user_objects_dealloc_page_count * 8)) AS 'Space Deallocated For User Objects (in KB)',
    --SUM((ssu.internal_objects_alloc_page_count * 8)) AS 'Space Allocated For Internal Objects (in KB)',
    --SUM((ssu.internal_objects_dealloc_page_count * 8)) AS 'Space Deallocated For Internal Objects (in KB)'
    (SUM((ssu.user_objects_alloc_page_count * 8)) + SUM((ssu.internal_objects_alloc_page_count * 8))) AS 'Tempdb_Space_Allocated_KB'
FROM sys.dm_pdw_nodes_db_session_space_usage AS ssu
WHERE DB_NAME(ssu.database_id) = 'tempdb'
GROUP BY ssu.pdw_node_id