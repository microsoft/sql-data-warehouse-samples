-- Creating script to drop SP if it exists and recreate. Called from DeploySPChanges
SET NOCOUNT ON;

DECLARE @objectName [VARCHAR](255);
SET @objectName =	(SELECT DISTINCT OBJECT_NAME($(object_id))  
					FROM sys.objects);

DECLARE @checkExists [VARCHAR](255);
SET @checkExists = 'IF OBJECTPROPERTY(object_id(''dbo.' + @objectName + '''), N''IsProcedure'') = 1';

DECLARE @dropText [VARCHAR](255);
SET @dropText =		'DROP PROCEDURE [dbo].' + @objectName + ';';

DECLARE @createStatement [VARCHAR](255);
SET @createStatement =	(SELECT sql.[definition]
						FROM [sys].[sql_modules] sql
						WHERE sql.[object_id] = $(object_id));

DECLARE @autoDeploy [VARCHAR](MAX);
SET @autoDeploy = @checkExists + CHAR(13)+CHAR(10) + @dropText + CHAR(13) + CHAR(10) + 'GO' + CHAR(13) + CHAR(10) +  @createStatement

SELECT @autoDeploy;

