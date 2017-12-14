CREATE TABLE [Fact].[Order]
(
	[Order Key]				BIGINT	IDENTITY(1,1)	NOT NULL,
	[City Key]				INT						NOT NULL,
	[Customer Key]			INT						NOT NULL,
	[Stock Item Key]		INT						NOT NULL,
	[Order Date Key]		DATE					NOT NULL,
	[Picked Date Key]		DATE					NULL,
	[Salesperson Key]		INT						NOT NULL,
	[Picker Key]			INT						NULL,
	[WWI Order ID]			INT						NOT NULL,
	[WWI Backorder ID]		INT						NULL,
	[Description]			NVARCHAR(100)			NOT NULL,
	[Package]				NVARCHAR(50)			NOT NULL,
	[Quantity]				INT						NOT NULL,
	[Unit Price]			DECIMAL(18, 2)			NOT NULL,
	[Tax Rate]				DECIMAL(18, 3)			NOT NULL,
	[Total Excluding Tax]	DECIMAL(18, 2)			NOT NULL,
	[Tax Amount]			DECIMAL(18, 2)			NOT NULL,
	[Total Including Tax]	DECIMAL(18, 2)			NOT NULL,
	[Lineage Key]			INT						NOT NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED COLUMNSTORE INDEX
);
GO