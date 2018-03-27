PRINT 'Info: Creating the ''microsoft.vw_table_space_by_distribution_type'' view';
GO

CREATE VIEW microsoft.vw_table_space_by_distribution_type AS
SELECT 
    distribution_policy_name
    , SUM(row_count)                AS [table_type_row_count]
    , SUM(reserved_space_GB)        AS [table_type_reserved_space_GB]
    , SUM(data_space_GB)            AS [table_type_data_space_GB]
    , SUM(index_space_GB)           AS [table_type_index_space_GB]
    , SUM(unused_space_GB)          AS [table_type_unused_space_GB]
FROM
    microsoft.vw_table_sizes
GROUP BY
    distribution_policy_name;
GO