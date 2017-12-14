CREATE TABLE [Dimension].[Payment Method]
(
	[Payment Method Key]		INT				NOT NULL,
	[WWI Payment Method ID]		INT				NOT NULL,
	[Payment Method]			NVARCHAR(50)	NOT NULL,
	[Valid From]				DATETIME2(7)	NOT NULL,
	[Valid To]					DATETIME2(7)	NOT NULL,
	[Lineage Key]				INT				NOT NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED INDEX
	(
		[Payment Method Key] ASC
	)
);
GO