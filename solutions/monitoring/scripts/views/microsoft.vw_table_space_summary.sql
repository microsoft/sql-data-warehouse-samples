PRINT 'Info: Creating the ''microsoft.vw_table_space_summary'' view';
GO

CREATE VIEW microsoft.vw_table_space_summary AS
SELECT 
    database_name
    , schema_name
    , table_name
    , distribution_policy_name
    , distribution_column
    , index_type_desc
    , COUNT(distinct partition_nmbr) AS [nbr_partitions]
    , SUM(row_count)                 AS [table_row_count]
    , SUM(reserved_space_GB)         AS [table_reserved_space_GB]
    , SUM(data_space_GB)             AS [table_data_space_GB]
    , SUM(index_space_GB)            AS [table_index_space_GB]
    , SUM(unused_space_GB)           AS [table_unused_space_GB]
FROM 
    microsoft.vw_table_sizes
GROUP BY 
    database_name
    , schema_name
    , table_name
    , distribution_policy_name
    , distribution_column
    , index_type_desc;
GO