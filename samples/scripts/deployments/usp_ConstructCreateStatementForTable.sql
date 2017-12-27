/* 

SP executed to get the Table DDL for generate scripts. Called from GetCreateStatment_Tabls.sql. This 
does not take into account partitions

*/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[usp_ConstructCreateStatementForTable] @schemaName [VARCHAR](50),@tableName [VARCHAR](255),@nameAppendix [VARCHAR](255),@sqlCmd [VARCHAR](8000) OUT AS
BEGIN
       DECLARE @distributionType AS VARCHAR(50);
       DECLARE @distributionColumn AS VARCHAR(255);
       DECLARE @indexType AS VARCHAR(50);
       DECLARE @createClause AS VARCHAR(1000);
       DECLARE @columnOrdinal AS INT;
       DECLARE @columnDefinition AS VARCHAR(255);
       DECLARE @columnList AS VARCHAR(8000);
       DECLARE @distributionClause AS VARCHAR(1000);
       DECLARE @indexClause AS VARCHAR(1000);

       -- Construct the CREATE TABLE 
       SET @createClause = 'CREATE TABLE [' + @schemaName + '].[' + @tableName + @nameAppendix + ']';

       -- Construct the column definition
       SET @columnList = '(' + CHAR(13)+CHAR(10) + '   ';
       SET @columnDefinition = '';
       SET @columnOrdinal = 0;

       WHILE @columnDefinition IS NOT NULL
       BEGIN
              IF @columnOrdinal > 1
                     SET @columnList = @columnList + ',' + CHAR(13)+CHAR(10) + '   ';

              IF @columnOrdinal > 0
                     SET @columnList = @columnList + @columnDefinition;

              SET @columnOrdinal = @columnOrdinal + 1;

			  -- Extracting the column name/type
              SET @columnDefinition = (SELECT '[' + [COLUMN_NAME] + '] [' + [DATA_TYPE] + ']' 
                                                                     + CASE WHEN [DATA_TYPE] LIKE '%char%' THEN ISNULL('(' + CAST([CHARACTER_MAXIMUM_LENGTH] AS VARCHAR(10)) + ')','') ELSE '' END
                                                                     + CASE WHEN [DATA_TYPE] LIKE '%binary%' THEN ISNULL('(' + CAST([CHARACTER_MAXIMUM_LENGTH] AS VARCHAR(10)) + ')','') ELSE '' END
                                                                     + CASE WHEN [DATA_TYPE] LIKE '%decimal%' THEN ISNULL('(' + CAST([NUMERIC_PRECISION] AS VARCHAR(10)) + ', ' + CAST([NUMERIC_SCALE] AS VARCHAR(10)) + ')','') ELSE '' END
                                                                     + CASE WHEN [DATA_TYPE] LIKE '%numeric%' THEN ISNULL('(' + CAST([NUMERIC_PRECISION] AS VARCHAR(10)) + ', ' + CAST([NUMERIC_SCALE] AS VARCHAR(10)) + ')','') ELSE '' END
                                                                     + CASE WHEN [DATA_TYPE] in ('datetime2','datetimeoffset') THEN ISNULL('(' + CAST([DATETIME_PRECISION] AS VARCHAR(10)) + ')','') ELSE '' END
                                                                     + CASE WHEN [IS_NULLABLE] = 'YES' THEN ' NULL' ELSE ' NOT NULL' END
                                                       FROM INFORMATION_SCHEMA.COLUMNS
                                                       WHERE [TABLE_SCHEMA] = @schemaName
                                                       AND [TABLE_NAME] = @tableName
                                                       AND [ORDINAL_POSITION] = @columnOrdinal);
       END
       SET @columnList = @columnList +  + CHAR(13)+CHAR(10) + ')';

       -- Construct the distribution clause by querrying for the distribution type/column
       SET @distributionType = (
			  -- Distribution Type
              SELECT tdp.[distribution_policy_desc] 
              FROM sys.pdw_table_distribution_properties tdp
              INNER JOIN sys.tables t
                     ON tdp.[object_id] = t.[object_id]
              INNER JOIN sys.schemas s
                     ON t.[schema_id] = s.[schema_id]
              WHERE t.[name] = @tableName
              AND s.[name] = @schemaName
       )

       SET @distributionColumn = (
			  -- Distribution Column
              SELECT c.[name] 
              FROM sys.pdw_column_distribution_properties cdp 
              INNER JOIN sys.tables t
                     ON cdp.[object_id] = t.[object_id]
              INNER JOIN sys.schemas s
                     ON t.[schema_id] = s.[schema_id]
              INNER JOIN sys.columns c
                     ON t.[object_id] = c.[object_id]
                     AND cdp.[column_id] = c.[column_id]
              WHERE t.[name] = @tableName
              AND s.[name] = @schemaName
              AND cdp.[distribution_ordinal] = 1
       )

       SET @distributionClause = ' DISTRIBUTION = '
                                                  + @distributionType
                                                  + ISNULL(' ( [' + @distributionColumn + '] )','');

       -- Construct the index clause by querrying the index type
       SET @indexType = (
              SELECT idx.[type_desc] --> Index Type
              FROM sys.indexes idx
              INNER JOIN sys.tables t
                     ON idx.[object_id] = t.[object_id]
              INNER JOIN sys.schemas s
                     ON t.[schema_id] = s.[schema_id]
              WHERE t.[name] = @tableName
              AND s.[name] = @schemaName
       )

       SET @indexClause = @indexType + ' INDEX';
       IF @indexType = 'CLUSTERED'
       BEGIN
              DECLARE @objectID BIGINT = (SELECT t.[object_id]
                                                              FROM [sys].[tables] t
                                                              INNER JOIN [sys].[schemas] sch ON t.[schema_id] = sch.[schema_id]
                                                              WHERE t.[name] = @tableName
                                                              AND sch.[name] = @schemaName);
              DECLARE @indexColumns VARCHAR(1000) = ' (';
              DECLARE @countIndexColumns INT = (SELECT COUNT(*) FROM [sys].[index_columns] WHERE [object_id] = @objectId and [index_id] = 1);
              DECLARE @indexColumnOrdinal INT = 1
              DECLARE @indexColumnName VARCHAR(1000);
              DECLARE @indexColumnSortDirection VARCHAR(1000);
              WHILE @indexColumnOrdinal <= @countIndexColumns
              BEGIN
                     SET @columnOrdinal = (SELECT [column_id]
                                                         FROM [sys].[index_columns]
                                                         WHERE [object_id] = @objectId and [index_id] = 1 and [key_ordinal] = @indexColumnOrdinal);
                     SET @indexColumnSortDirection = (SELECT CASE WHEN [is_descending_key] = 1 THEN ' DESC' ELSE ' ASC' END
                                                                           FROM [sys].[index_columns]
                                                                           WHERE [object_id] = @objectId and [index_id] = 1 and [key_ordinal] = @indexColumnOrdinal);
                     SET @indexColumnName = (SELECT '[' + [COLUMN_NAME] + ']'
                                                              FROM INFORMATION_SCHEMA.COLUMNS
                                                              WHERE [TABLE_SCHEMA] = @schemaName
                                                              AND [TABLE_NAME] = @tableName
                                                              AND [ORDINAL_POSITION] = @columnOrdinal);
                     IF @indexColumnOrdinal > 1
                           SET @indexColumns = @indexColumns + ', ';
                     SET @indexColumns = @indexColumns + @indexColumnName + @indexColumnSortDirection;
                     SET @indexColumnOrdinal = @indexColumnOrdinal + 1;
              END;
              SET @indexColumns = @indexColumns + ')';
              SET @indexClause = @indexClause + @indexColumns;
       END;

       -- Construct the entire sql command
       SET @sqlCmd = @createClause
                                  + ' ' + @columnList
                                  + ' WITH ('  + CHAR(13)+CHAR(10) + @distributionClause
                                  + ', ' + @indexClause
                                  + CHAR(13)+CHAR(10) + ')';
END
GO


