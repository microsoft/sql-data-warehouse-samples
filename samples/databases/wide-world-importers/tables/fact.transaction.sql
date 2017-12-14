CREATE TABLE [Fact].[Transaction]
(
	[Transaction Key]				BIGINT IDENTITY(1,1)	NOT NULL,
	[Date Key]						DATE					NOT NULL,
	[Customer Key]					INT						NULL,
	[Bill To Customer Key]			INT						NULL,
	[Supplier Key]					INT						NULL,
	[Transaction Type Key]			INT						NOT NULL,
	[Payment Method Key]			INT						NULL,
	[WWI Customer Transaction ID]	INT						NULL,
	[WWI Supplier Transaction ID]	INT						NULL,
	[WWI Invoice ID]				INT						NULL,
	[WWI Purchase Order ID]			INT						NULL,
	[Supplier Invoice Number]		NVARCHAR(20)			NULL,
	[Total Excluding Tax]			DECIMAL(18, 2)			NOT NULL,
	[Tax Amount]					DECIMAL(18, 2)			NOT NULL,
	[Total Including Tax]			DECIMAL(18, 2)			NOT NULL,
	[Outstanding Balance]			DECIMAL(18, 2)			NOT NULL,
	[Is Finalized]					BIT						NOT NULL,
	[Lineage Key]					INT					NOT NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED COLUMNSTORE INDEX
);
GO