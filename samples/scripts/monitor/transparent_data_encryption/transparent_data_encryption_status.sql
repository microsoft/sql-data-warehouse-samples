SELECT
	[name],
	CASE [is_encrypted]
		WHEN 1 THEN 'TRUE'
		ELSE 'FALSE'
	END [Encrypted]
FROM
	[sys].[databases]
ORDER BY
	[name];