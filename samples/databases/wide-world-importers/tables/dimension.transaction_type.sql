CREATE TABLE [Dimension].[Transaction Type]
(
	[Transaction Type Key]		INT				NOT NULL,
	[WWI Transaction Type ID]	INT				NOT NULL,
	[Transaction Type]			NVARCHAR(50)	NOT NULL,
	[Valid From]				DATETIME2(7)	NOT NULL,
	[Valid To]					DATETIME2(7)	NOT NULL,
	[Lineage Key]				INT				NOT NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED INDEX
	(
		[Transaction Type Key]
	)
);
GO