CREATE TABLE [Seed].[Sale]
(
	[Sale Key]					BIGINT IDENTITY(1,1)	NOT NULL,
	[City Key]					INT						NOT NULL,
	[Customer Key]				INT						NOT NULL,
	[Bill To Customer Key]		INT						NOT NULL,
	[Stock Item Key]			INT						NOT NULL,
	[Invoice Date Key]			DATE					NOT NULL,
	[Delivery Date Key]			DATE					NULL,
	[Salesperson Key]			INT						NOT NULL,
	[WWI Invoice ID]			INT						NOT NULL,
	[Description]				NVARCHAR(100)			NOT NULL,
	[Package]					NVARCHAR(50)			NOT NULL,
	[Quantity]					INT						NOT NULL,
	[Unit Price]				DECIMAL(18, 2)			NOT NULL,
	[Tax Rate]					DECIMAL(18, 3)			NOT NULL,
	[Total Excluding Tax]		DECIMAL(18, 2)			NOT NULL,
	[Tax Amount]				DECIMAL(18, 2)			NOT NULL,
	[Profit]					DECIMAL(18, 2)			NOT NULL,
	[Total Including Tax]		DECIMAL(18, 2)			NOT NULL,
	[Total Dry Items]			INT						NOT NULL,
	[Total Chiller Items]		INT						NOT NULL,
	[Lineage Key]				INT						NOT NULL
)
WITH
(
	DISTRIBUTION = HASH
	(
		[WWI Invoice ID]
	),
	CLUSTERED COLUMNSTORE INDEX
);
GO