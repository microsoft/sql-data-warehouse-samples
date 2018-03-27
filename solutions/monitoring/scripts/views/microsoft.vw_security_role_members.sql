PRINT 'Info: Creating the ''microsoft.vw_security_role_members'' view';
GO

CREATE VIEW microsoft.vw_security_role_members
AS
SELECT
	r.[name]     AS role_principal_name
	, m.[name]   AS member_principal_name
FROM
	sys.database_role_members rm
	JOIN sys.database_principals AS r ON rm.[role_principal_id] = r.[principal_id]
	JOIN sys.database_principals AS m ON rm.[member_principal_id] = m.[principal_id]
WHERE
	r.[type_desc] = 'DATABASE_ROLE';
GO