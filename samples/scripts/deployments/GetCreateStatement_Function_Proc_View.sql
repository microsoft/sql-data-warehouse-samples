SET NOCOUNT ON;

-- From the PS script we call, we extract the object_id as the parameter and get the DDL for Functions, Stored Precedures, and views
SELECT sql.[definition]
FROM [sys].[sql_modules] sql
WHERE sql.[object_id] = $(object_id);