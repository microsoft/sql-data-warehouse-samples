PRINT 'Info: Creating the ''microsoft.vw_statistics_age'' view';
GO

CREATE VIEW microsoft.vw_statistics_age AS
SELECT
    sm.[name]                                  AS [schema_name],
    tb.[name]                                  AS [table_name],
    co.[name]                                  AS [stats_column_name],
    st.[name]                                  AS [stats_name],
    STATS_DATE(st.[object_id],st.[stats_id])   AS [stats_last_updated_date]
FROM
    sys.objects ob
    JOIN sys.stats st ON  ob.[object_id] = st.[object_id]
    JOIN sys.stats_columns sc ON  st.[stats_id] = sc.[stats_id]
        AND st.[object_id] = sc.[object_id]
    JOIN sys.columns co ON  sc.[column_id] = co.[column_id]
        AND sc.[object_id] = co.[object_id]
    JOIN sys.types ty ON co.[user_type_id] = ty.[user_type_id]
    JOIN sys.tables tb ON co.[object_id] = tb.[object_id]
    JOIN sys.schemas sm ON tb.[schema_id] = sm.[schema_id]
WHERE
    st.[user_created] = 1;
GO