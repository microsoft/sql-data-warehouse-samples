PRINT 'Info: Creating the ''microsoft.vw_table_space_by_distribution'' view';
GO

CREATE VIEW microsoft.vw_table_space_by_distribution AS
SELECT 
    distribution_id
    , SUM(row_count)                AS [total_node_distribution_row_count]
    , SUM(reserved_space_MB)        AS [total_node_distribution_reserved_space_MB]
    , SUM(data_space_MB)            AS [total_node_distribution_data_space_MB]
    , SUM(index_space_MB)           AS [total_node_distribution_index_space_MB]
    , SUM(unused_space_MB)          AS [total_node_distribution_unused_space_MB]
FROM
    microsoft.vw_table_sizes
GROUP BY
    distribution_id;
GO