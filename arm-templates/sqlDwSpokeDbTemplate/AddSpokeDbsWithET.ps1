<# 
	This PowerShell script was automatically converted to PowerShell Workflow so it can be run as a runbook.
	Specific changes that have been made are marked with a comment starting with “Converter:”
#>
Param(	
	[Parameter(Mandatory= $true)]
	[String]$SqlServer,
	[Parameter(Mandatory= $true)]
	[String]$Datawarehouse,
	[Parameter(Mandatory= $true)]
	[String]$SpokeDbBaseName,
	[Parameter(Mandatory= $true)]
	[int16]$SpokeCount
)

workflow spokeDbSetup {

inlineScript {
$logicalServerAdminCredential = Get-AutomationPSCredential -Name logicalServerAdminCredential 

if ($logicalServerAdminCredential -eq $null) 
{ 
   throw "Could not retrieve '$logicalServerAdminCredential' credential asset. Check that you created this first in the Automation service." 
}   
# Get the username and password from the SQL Credential 
$SqlUsername = $logicalServerAdminCredential.UserName 
$SqlPass = $logicalServerAdminCredential.GetNetworkCredential().Password


$SqlServerPort = '1433' 

# Define the connection to the logical server master database 
$MasterConn = New-Object System.Data.SqlClient.SqlConnection("Server=tcp:$SqlServer.database.windows.net,$SqlServerPort;Initial Catalog=master;Persist Security Info=False;User ID=$SqlUsername;Password=$SqlPass;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;")         
# Open the SQL connection 
$MasterConn.Open() 

# Create logins for each database in master
For ($i=0; $i -lt $SpokeCount; $i++) {
	$CreateDatabaseLoginInMaster=new-object system.Data.SqlClient.SqlCommand("
CREATE LOGIN $SpokeDbBaseName$i WITH PASSWORD = 'p@ssw0rd##%$i';
", $MasterConn)

	$Da=New-Object system.Data.SqlClient.SqlDataAdapter($CreateDatabaseLoginInMaster) 
	$Ds=New-Object system.Data.DataSet 
	[void]$Da.fill($Ds)
}
$MasterConn.Close() 


# Define the connection to the SQL data warehouse instance
$DwConn = New-Object System.Data.SqlClient.SqlConnection("Server=tcp:$SqlServer.database.windows.net,$SqlServerPort;Initial Catalog=$Datawarehouse;Persist Security Info=False;User ID=$SqlUsername;Password=$SqlPass;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;")         
# Open the SQL connection 
$DwConn.Open() 

# Create user for each database in the data warehouse instance and setup meta schema
For ($i=0; $i -lt $SpokeCount; $i++) {
   $CreateDatabaseUserInDw=new-object system.Data.SqlClient.SqlCommand("
   CREATE USER $SpokeDbBaseName$i FOR LOGIN $SpokeDbBaseName$i;

   IF NOT EXISTS (SELECT * FROM sys.schemas sch WHERE sch.[name] = 'meta')
BEGIN
EXEC sp_executesql N'CREATE SCHEMA [meta]'
END
", $DwConn)

   $Da=New-Object system.Data.SqlClient.SqlDataAdapter($CreateDatabaseUserInDw) 
   $Ds=New-Object system.Data.DataSet 
   [void]$Da.fill($Ds)
   
}
$DwConn.Close() 


# Setup each database instance with connections to the data warehouse instance given the credentials just created and setup meta schema
For ($i=0; $i -lt $SpokeCount; $i++) {
   $DbConn = New-Object System.Data.SqlClient.SqlConnection("Server=tcp:$SqlServer.database.windows.net,$SqlServerPort;Initial Catalog=$SpokeDbBaseName$i;Persist Security Info=False;User ID=$SqlUsername;Password=$SqlPass;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;")         
   
   $DbConn.Open() 
   $SetupDatabaseEQCredentials=new-object system.Data.SqlClient.SqlCommand("
IF NOT EXISTS (SELECT * FROM sys.symmetric_keys WHERE symmetric_key_id = 101)
CREATE MASTER KEY;


CREATE DATABASE SCOPED CREDENTIAL [$Datawarehouse-Credential]
WITH IDENTITY = '$SpokeDbBaseName$i',
SECRET = 'p@ssw0rd##%$i';


CREATE EXTERNAL DATA SOURCE [$Datawarehouse] WITH 
(TYPE = RDBMS, 
LOCATION = '$SqlServer.database.windows.net', 
DATABASE_NAME = '$Datawarehouse', 
CREDENTIAL = [$Datawarehouse-Credential], 
);

IF NOT EXISTS (SELECT * FROM sys.schemas sch WHERE sch.[name] = 'meta')
BEGIN
EXEC sp_executesql N'CREATE SCHEMA [meta]'
END

", $DbConn)

   $Da=New-Object system.Data.SqlClient.SqlDataAdapter($SetupDatabaseEQCredentials) 
   $Ds=New-Object system.Data.DataSet 
   [void]$Da.fill($Ds)
   $DbConn.Close() 
}

############## Load DW with stored procedures ##############
# Define the connection to the SQL data warehouse instance
$DwConn = New-Object System.Data.SqlClient.SqlConnection("Server=tcp:$SqlServer.database.windows.net,$SqlServerPort;Initial Catalog=$Datawarehouse;Persist Security Info=False;User ID=$SqlUsername;Password=$SqlPass;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;")         
# Open the SQL connection 
$DwConn.Open() 

# Create user for each database in the data warehouse instance
$CreateExternalTableFromDw=new-object system.Data.SqlClient.SqlCommand("
CREATE PROC [meta].[CreateExternalTableFromDw] @externalSchema [VARCHAR](50),@schemaName [VARCHAR](50),@tableName [VARCHAR](255),@nameAppendix [VARCHAR](255),@externalDataSource [VARCHAR](255),@sqlCmd [VARCHAR](8000) OUT AS
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

--> Construct the 'CREATE TABLE ...' clause
SET @createClause = 'CREATE EXTERNAL TABLE [' + @externalSchema + '].[' + @nameAppendix + '_' +@tableName + ']';

--> Construct the column list
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

--> Construct the entire sql command by combining the individual clauses
SET @sqlCmd = @createClause
						  + ' ' + @columnList
						  + ' WITH ('  + CHAR(13)+CHAR(10) +'DATA_SOURCE = ' + @externalDataSource
						  + ', ' + CHAR(13)+CHAR(10) +'SCHEMA_NAME  = N' + '''' +  @schemaName + ''''
						  + ', ' + CHAR(13)+CHAR(10) +'OBJECT_NAME  = N' + '''' + @tableName + ''''
						  + CHAR(13)+CHAR(10) + ')'
						  ;
END

", $DwConn)


$Da=New-Object system.Data.SqlClient.SqlDataAdapter($CreateExternalTableFromDw) 
$Ds=New-Object system.Data.DataSet 
[void]$Da.fill($Ds)


$GenerateDatamartExternalTableDefinitionsAndGrantSelect=new-object system.Data.SqlClient.SqlCommand("
CREATE PROC [meta].[GenerateDatamartExternalTableDefinitionsAndGrantSelect] AS
BEGIN
IF EXISTS ( SELECT * FROM sys.tables WHERE object_id = OBJECT_ID('meta.DatamartExternalTableDefinitions') )
BEGIN
DROP TABLE meta.DatamartExternalTableDefinitions
END

CREATE TABLE meta.DatamartExternalTableDefinitions
WITH
( 
DISTRIBUTION = ROUND_ROBIN
,	HEAP
)
AS
SELECT  
ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS Sequence
,	[DataMartUser]
,	[DataSource]
,	[ObjectId]
,	[TableName]	
,	[SchemaName]
,	CAST('' AS VARCHAR(max)) AS [DDL]
FROM
[meta].[DatamartControlTable]

IF NOT EXISTS (SELECT * FROM sys.objects obj WHERE obj.[name] = 'RemoteTableDefinitionView' and obj.[type] = 'V')
EXEC sp_executesql N'
CREATE VIEW [meta].[RemoteTableDefinitionView] AS 
SELECT	[TableName]
,		[SchemaName]
,		[DDL]
FROM [meta].[DatamartExternalTableDefinitions]
WHERE DataMartUser = SUSER_SNAME();

DECLARE @nbr_statements INT = (SELECT COUNT(*) FROM [meta].[DatamartExternalTableDefinitions])
,       @i INT = 1
;

DECLARE @databaseName VARCHAR(100) = DB_NAME();

WHILE   @i <= @nbr_statements
BEGIN
DECLARE @DDL NVARCHAR(MAX); --= (SELECT sql_code FROM [meta].[DatamartControlTable] WHERE Sequence = @i);
DECLARE @tableName VARCHAR(1000) = (SELECT tableName FROM [meta].[DatamartExternalTableDefinitions] WHERE Sequence = @i);
DECLARE @schemaName VARCHAR(1000) = (SELECT schemaName FROM [meta].[DatamartExternalTableDefinitions] WHERE Sequence = @i);
DECLARE @externalDataSourceName VARCHAR(1000) = (SELECT [DataSource] FROM [meta].[DatamartExternalTableDefinitions] WHERE Sequence = @i);
DECLARE @datamartUser VARCHAR(1000) = (SELECT [DataMartUser] FROM [meta].[DatamartExternalTableDefinitions] WHERE Sequence = @i);
DECLARE @grantCommand VARCHAR(100) = 'GRANT SELECT ON OBJECT::['+@schemaName+'].['+@tableName+'] TO ['+@datamartUser+'];';
DECLARE @grantViewCommand VARCHAR(100) = 'GRANT SELECT ON OBJECT::[meta].[DataMartTableDefinitions] TO '+@datamartUser+''';
EXEC    [meta].[createExternalTableFromDw] @databaseName, @schemaName, @tableName, @schemaName, @externalDataSourceName, @DDL OUTPUT;
UPDATE  [meta].[DatamartExternalTableDefinitions] SET DDL = @DDL WHERE Sequence = @i;
EXEC	sp_executesql @grantCommand;
EXEC	sp_executesql @grantViewCommand;
SET     @i +=1;
END

END
", $DwConn)

$Da=New-Object system.Data.SqlClient.SqlDataAdapter($GenerateDatamartExternalTableDefinitionsAndGrantSelect) 
$Ds=New-Object system.Data.DataSet 
[void]$Da.fill($Ds)


$AddObjectsForDatamartUserToControlTable=new-object system.Data.SqlClient.SqlCommand("
CREATE PROC [meta].[AddObjectsForDatamartUserToControlTable] @userName [VARCHAR](150),@dataSource [VARCHAR](150),@objectId [VARCHAR](150),@schemaName [VARCHAR](150) AS
BEGIN
-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.
SET NOCOUNT ON

-- Insert statements for procedure here

IF OBJECT_ID('tempdb..#TablesByUserSchema') IS NOT NULL DROP TABLE #TablesByUserSchema


IF @objectId IS NOT NULL OR @schemaName IS NOT NULL
BEGIN
-- If objectId is set, just add the unique object to datamart user. ObjectId always
-- takes precedence over schema
IF (@objectId IS NOT NULL)
BEGIN
	SELECT		@userName		AS [DataMartUser]
	,			@dataSource		AS [DataSource]
	,			tbl.[object_id]	AS [ObjectId]	
	,			sch.[name]		AS [SchemaName]
	,			tbl.[name]		AS [TableName]	
	INTO		#TablesByUserSchema
	FROM		sys.tables tbl
	JOIN		sys.schemas sch		ON tbl.[schema_id] = sch.[schema_id]
	WHERE		tbl.[object_id]		= @objectId
	AND			tbl.[is_external]	= 0
END
-- If schemaName is set, add all tables in the schema to datamart user
-- but not objectId
ELSE 
BEGIN
	SELECT 
		@userName		AS [DataMartUser]
	,	@dataSource		AS [DataSource]
	,	tbl.[object_id]	AS [ObjectId]	
	,	sch.[name]		AS [SchemaName]
	,	tbl.[name]		AS [TableName]	
	INTO #TablesByUserSchema
	FROM
	sys.tables tbl
	JOIN
	sys.schemas sch
	ON tbl.[schema_id] = sch.[schema_id]
	WHERE sch.[name] = @schemaName
	AND tbl.[is_external] = 0
END
END
-- If no optional parameters given, add all user tables to datamart user
ELSE
BEGIN
SELECT 
	@userName		AS [DataMartUser]
,	@dataSource		AS [DataSource]
,	tbl.[object_id]	AS [ObjectId]	
,	sch.[name]		AS [SchemaName]
,	tbl.[name]		AS [TableName]	
INTO #TablesByUserSchema
FROM
sys.tables tbl
JOIN
sys.schemas sch
ON tbl.[schema_id] = sch.[schema_id]
AND tbl.[is_external] = 0
END

IF NOT EXISTS ( SELECT * FROM sys.tables WHERE object_id = OBJECT_ID('meta.DatamartControlTable') )
BEGIN
CREATE TABLE meta.[DatamartControlTable]
WITH
(
	HEAP,
	DISTRIBUTION=ROUND_ROBIN
)
AS SELECT * FROM #TablesByUserSchema
END
ELSE
BEGIN
CREATE TABLE meta.[DatamartControlTable_new]
WITH
(
	HEAP
,	DISTRIBUTION=ROUND_ROBIN
)
AS
SELECT
	*
FROM #TablesByUserSchema t
WHERE NOT EXISTS
(
	SELECT * 
	FROM meta.[DatamartControlTable] c 
	WHERE t.[DataMartUser] = c.[DataMartUser] AND t.[ObjectId] = c.[ObjectId]
)
UNION ALL
SELECT * FROM meta.[DatamartControlTable]

RENAME OBJECT meta.[DatamartControlTable]	 TO [DatamartControlTable_old];
RENAME OBJECT meta.[DatamartControlTable_new] TO [DatamartControlTable];

DROP TABLE [meta].[DatamartControlTable_old];

END

END
", $DwConn)

$Da=New-Object system.Data.SqlClient.SqlDataAdapter($AddObjectsForDatamartUserToControlTable) 
$Ds=New-Object system.Data.DataSet 
[void]$Da.fill($Ds)

# $RemoteTableDefinitionView=new-object system.Data.SqlClient.SqlCommand("
# 	CREATE VIEW [meta].[RemoteTableDefinitionView] AS 
# 	SELECT	[TableName]
# 	,		[SchemaName]
# 	,		[DDL]
# 	FROM [meta].[DatamartExternalTableDefinitions]
# 	WHERE DataMartUser = SUSER_SNAME();
# ", $DwConn)

# $Da=New-Object system.Data.SqlClient.SqlDataAdapter($RemoteTableDefinitionView) 
# $Ds=New-Object system.Data.DataSet 
# [void]$Da.fill($Ds)


$DwConn.Close() 


############## Load each database with stored procedures ##############

# Setup each database instance with connections to the data warehouse instance given the credentials just created
For ($i=0; $i -lt $SpokeCount; $i++) {
   $DbConn = New-Object System.Data.SqlClient.SqlConnection("Server=tcp:$SqlServer.database.windows.net,$SqlServerPort;Initial Catalog=$SpokeDbBaseName$i;Persist Security Info=False;User ID=$SqlUsername;Password=$SqlPass;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;")         
   
	  $DbConn.Open() 
	$CreateMetaSchemaDb=new-object system.Data.SqlClient.SqlCommand("
IF NOT EXISTS (SELECT * FROM sys.schemas sch WHERE sch.[name] = 'meta')
BEGIN
EXEC sp_executesql N'CREATE SCHEMA [meta]'
END", $DbConn)

   $Da=New-Object system.Data.SqlClient.SqlDataAdapter($CreateMetaSchemaDb) 
   $Ds=New-Object system.Data.DataSet 
   [void]$Da.fill($Ds)

   $SetupExternalTablesToDw=new-object system.Data.SqlClient.SqlCommand("

CREATE PROC [meta].[SetupExternalTablesToDw] @externalTableSource VARCHAR(100) AS
BEGIN
IF NOT EXISTS (SELECT * FROM sys.schemas sch WHERE sch.[name] = @externalTableSource)
BEGIN
	DECLARE @createSchemaCmd NVARCHAR(100) = N'CREATE SCHEMA [' + @externalTableSource + ']';
	EXEC sp_executesql @createSchemaCmd;
END
	
IF NOT EXISTS (	SELECT * 
				FROM	sys.external_tables et
				JOIN	sys.schemas sch
				ON		et.[schema_id] = sch.[schema_id]
				AND		et.[name] = 'RemoteTableDefinitionView' )
BEGIN
DECLARE @createRemoteTableDefinitionViewCmd NVARCHAR(400) = 
'
CREATE EXTERNAL TABLE [meta].[RemoteTableDefinitionView]
(
	[TableName]		NVARCHAR(128) NOT NULL
,	[SchemaName]	NVARCHAR(128) NOT NULL
,	[DDL]			VARCHAR(MAX)  NULL
)
WITH
(
	DATA_SOURCE = '+@externalTableSource+'
,	SCHEMA_NAME = ''meta''
,	OBJECT_NAME = ''RemoteTableDefinitionView''
)
'
EXEC sp_executesql @createRemoteTableDefinitionViewCmd;
END

SELECT ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS Sequence
,	   [TableName]	
,	   [SchemaName]
,	   [DDL]		
INTO	#RemoteTableDefinitions
FROM	[meta].[RemoteTableDefinitionView]

DECLARE @nbr_statements INT = (SELECT COUNT(*) FROM #RemoteTableDefinitions)
,       @i INT = 1
;

WHILE   @i <= @nbr_statements
BEGIN
	DECLARE @cmd NVARCHAR(MAX) = (SELECT [DDL] FROM #RemoteTableDefinitions WHERE Sequence = @i); 
	EXEC sp_executesql @cmd
	SET     @i +=1;
END
END
", $DbConn)

   $Da=New-Object system.Data.SqlClient.SqlDataAdapter($SetupExternalTablesToDw) 
   $Ds=New-Object system.Data.DataSet 
   [void]$Da.fill($Ds)
   $DbConn.Close() 
}


### Execute stored procedures to generate the control tables and external metadata information for each of the dbs created against the DW

$DwConn = New-Object System.Data.SqlClient.SqlConnection("Server=tcp:$SqlServer.database.windows.net,$SqlServerPort;Initial Catalog=$Datawarehouse;Persist Security Info=False;User ID=$SqlUsername;Password=$SqlPass;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;")         
# Open the SQL connection 
$DwConn.Open() 

For ($i=0; $i -lt $SpokeCount; $i++) {
	$AddObjectsForDatamartUserToControlTable=new-object system.Data.SqlClient.SqlCommand("
EXEC [meta].[AddObjectsForDatamartUserToControlTable] '$SpokeDbBaseName$i', '$Datawarehouse', null, null
", $DwConn)

	$Da=New-Object system.Data.SqlClient.SqlDataAdapter($AddObjectsForDatamartUserToControlTable) 
	$Ds=New-Object system.Data.DataSet 
	[void]$Da.fill($Ds)
}
$GenerateDatamartExternalTableDefinitionsAndGrantSelect=new-object system.Data.SqlClient.SqlCommand("
EXEC [meta].[GenerateDatamartExternalTableDefinitionsAndGrantSelect]
", $DwConn)

$Da=New-Object system.Data.SqlClient.SqlDataAdapter($GenerateDatamartExternalTableDefinitionsAndGrantSelect) 
$Ds=New-Object system.Data.DataSet 
[void]$Da.fill($Ds)


$DwConn.Close() 

### Execute stored procedures to generate external table definitions in each of the databases

For ($i=0; $i -lt $SpokeCount; $i++) {
	$DbConn = New-Object System.Data.SqlClient.SqlConnection("Server=tcp:$SqlServer.database.windows.net,$SqlServerPort;Initial Catalog=$SpokeDbBaseName$i;Persist Security Info=False;User ID=$SqlUsername;Password=$SqlPass;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;")         

	$DbConn.Open() 
	$SetupDatabaseEQCredentials=new-object system.Data.SqlClient.SqlCommand("
EXEC [meta].[SetupExternalTablesToDw] '$Datawarehouse'
", $DbConn)

	$Da=New-Object system.Data.SqlClient.SqlDataAdapter($SetupDatabaseEQCredentials) 
	$Ds=New-Object system.Data.DataSet 
	[void]$Da.fill($Ds)
	$DbConn.Close() 
}


}
}