/*-- sys.dm_pdw_sql_requests with the correct node id
CREATE VIEW sql_requests AS
(SELECT
       sr.request_id,
       sr.step_index,
       (CASE 
              WHEN (sr.distribution_id = -1 ) THEN 
              (SELECT pdw_node_id FROM sys.dm_pdw_nodes WHERE type = 'CONTROL') 
              ELSE d.pdw_node_id END) AS pdw_node_id,
       sr.distribution_id,
       sr.status,
       sr.error_id,
       sr.start_time,
       sr.end_time,
       sr.total_elapsed_time,
       sr.row_count,
       sr.spid,
       sr.command
FROM sys.pdw_distributions AS d
RIGHT JOIN sys.dm_pdw_sql_requests AS sr ON d.distribution_id = sr.distribution_id)
*/

-- Memory consumption
SELECT
  pc1.pdw_node_id,
  pc1.cntr_value * 100.0/pc2.cntr_value AS Memory_Utilization_Percentage
FROM
-- pc1: current memory
sys.dm_pdw_nodes_os_performance_counters AS pc1
-- pc2: total memory allowed for this SQL instance
JOIN sys.dm_pdw_nodes_os_performance_counters AS pc2 
ON pc1.object_name = pc2.object_name AND pc1.pdw_node_id = pc2.pdw_node_id
WHERE
pc1.counter_name = 'Total Server Memory (KB)'
AND pc2.counter_name = 'Target Server Memory (KB)'

