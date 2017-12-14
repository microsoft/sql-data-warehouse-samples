CREATE TABLE [Dimension].[Employee]
(
	[Employee Key]		INT				NOT NULL,
	[WWI Employee ID]	INT				NOT NULL,
	[Employee]			NVARCHAR(50)	NOT NULL,
	[Preferred Name]	NVARCHAR(50)	NOT NULL,
	[Is Salesperson]	BIT				NOT NULL,
	[Photo]				VARBINARY(max)	NULL,
	[Valid From]		DATETIME2(7)	NOT NULL,
	[Valid To]			DATETIME2(7)	NOT NULL,
	[Lineage Key]		INT				NOT NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED INDEX
	(
		[Employee Key]
	)
);
GO