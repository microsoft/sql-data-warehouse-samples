CREATE TABLE [Dimension].[Supplier]
(
	[Supplier Key]			INT				NOT NULL,
	[WWI Supplier ID]		INT				NOT NULL,
	[Supplier]				NVARCHAR(100)	NOT NULL,
	[Category]				NVARCHAR(50)	NOT NULL,
	[Primary Contact]		NVARCHAR(50)	NOT NULL,
	[Supplier Reference]	NVARCHAR(20)	NULL,
	[Payment Days]			INT				NOT NULL,
	[Postal Code]			NVARCHAR(10)	NOT NULL,
	[Valid From]			DATETIME2(7)	NOT NULL,
	[Valid To]				DATETIME2(7)	NOT NULL,
	[Lineage Key]			INT				NOT NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED INDEX
	(
		[Supplier Key] ASC
	)
);
GO