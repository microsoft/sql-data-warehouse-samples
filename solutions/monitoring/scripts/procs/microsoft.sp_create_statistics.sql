PRINT 'Info: Creating the ''microsoft.sp_create_statistics'' procedure';
GO

CREATE PROCEDURE microsoft.sp_create_statistics
(
	@create_type    tinyint -- 1=default; 2=Fullscan; 3=Sample
	, @sample_pct   tinyint
)
AS
IF @create_type IS NULL
  BEGIN
	SET @create_type = 1;
  END;

IF @create_type NOT IN (1,2,3)
  BEGIN
	THROW 151000,'Invalid value for @stats_type parameter. Valid range 1 (default), 2 (fullscan) or 3 (sample).',1;
  END;

IF @sample_pct IS NULL
  BEGIN;
	SET @sample_pct = 20;
  END;

IF OBJECT_ID('tempdb..#stats_ddl') IS NOT NULL
  BEGIN;
	DROP TABLE #stats_ddl;
  END;

CREATE TABLE #stats_ddl
WITH
(
	DISTRIBUTION   = HASH([seq_nmbr])
	, LOCATION     = USER_DB
)
AS 
WITH T AS
(
	SELECT
		t.[name]                            AS [table_name]
		, s.[name]                          AS [table_schema_name]
		, c.[name]                          AS [column_name]
		, c.[column_id]                     AS [column_id]
		, t.[object_id]                     AS [object_id]
		, ROW_NUMBER()
			OVER(ORDER BY (SELECT NULL))    AS [seq_nmbr]
	FROM
		sys.tables t
		JOIN sys.schemas s ON  t.[schema_id] = s.[schema_id]
		JOIN sys.columns c ON  t.[object_id] = c.[object_id]
		LEFT JOIN sys.stats_columns l ON  l.[object_id] = c.[object_id]
			AND l.[column_id] = c.[column_id]
			AND l.[stats_column_id] = 1
		LEFT JOIN sys.external_tables e ON e.[object_id] = t.[object_id]
	WHERE
		l.[object_id] IS NULL
		AND e.[object_id] IS NULL -- not an external table
)
SELECT
	[table_schema_name]
	, [table_name]
	, [column_name]
	, [column_id]
	, [object_id]
	, [seq_nmbr]
	, CASE @create_type
		WHEN 1 THEN CAST('CREATE STATISTICS ' + QUOTENAME('stat_'+table_schema_name + '_' + table_name + '_' + column_name) + ' ON ' + QUOTENAME(table_schema_name) + '.' + QUOTENAME(table_name) + '(' + QUOTENAME(column_name) + ')' AS VARCHAR(8000))
        WHEN 2 THEN CAST('CREATE STATISTICS ' + QUOTENAME('stat_'+table_schema_name + '_' + table_name + '_' + column_name) + ' ON ' + QUOTENAME(table_schema_name) + '.' + QUOTENAME(table_name) + '(' + QUOTENAME(column_name) + ') WITH FULLSCAN' AS VARCHAR(8000))
        WHEN 3 THEN CAST('CREATE STATISTICS ' + QUOTENAME('stat_'+table_schema_name + '_' + table_name + '_' + column_name) + ' ON ' + QUOTENAME(table_schema_name) + '.' + QUOTENAME(table_name) + '(' + QUOTENAME(column_name) + ') WITH SAMPLE ' + CONVERT(VARCHAR(4), @sample_pct) + ' PERCENT' AS VARCHAR(8000))
        END AS create_stat_ddl
FROM T;

DECLARE
	@i INT = 1
	, @t INT = (SELECT COUNT(*) FROM #stats_ddl)
	, @statement NVARCHAR(4000)   = N'';

WHILE @i <= @t
  BEGIN
	SET @statement = (SELECT create_stat_ddl FROM #stats_ddl WHERE seq_nmbr = @i);

	PRINT @statement
    EXEC sp_executesql @statement
    SET @i+=1;
END

DROP TABLE #stats_ddl;
Go