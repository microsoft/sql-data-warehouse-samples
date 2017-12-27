SET NOCOUNT ON;

/* 

From the PS script, we extract the object_id to be used in this script for table metadata. This metadata 
will be used arguments for an internal SP (usp_ConstructCreateStatementForTable) to create the DDL. Ensure
this SP already exists in your data warehouse.

*/
DECLARE @objectId AS BIGINT;
SET @objectId = $(object_id);

DECLARE @schemaName AS [VARCHAR](50);
DECLARE @tableName [VARCHAR](255);

SET @schemaName = (SELECT sch.[name]
				   FROM [sys].[objects] obj
				   INNER JOIN [sys].[schemas] sch
				   ON obj.[schema_id] = [sch].[schema_id]
				   WHERE obj.[object_id] = @objectId);
SET @tableName = (SELECT obj.[name]
				  FROM [sys].[objects] obj
				  WHERE obj.[object_id] = @objectId);

DECLARE @sqlCmd AS VARCHAR(8000);
EXEC [usp_ConstructCreateStatementForTable] @schemaName, @tableName, '', @sqlCmd OUTPUT;
SELECT @sqlCmd;