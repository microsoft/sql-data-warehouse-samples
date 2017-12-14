CREATE TABLE [Fact].[Purchase]
(
	[Purchase Key]				BIGINT	IDENTITY(1,1)	NOT NULL,
	[Date Key]					DATE					NOT NULL,
	[Supplier Key]				INT						NOT NULL,
	[Stock Item Key]			INT						NOT NULL,
	[WWI Purchase Order ID]		INT						NULL,
	[Ordered Outers]			INT						NOT NULL,
	[Ordered Quantity]			INT						NOT NULL,
	[Received Outers]			INT						NOT NULL,
	[Package]					NVARCHAR(50)			NOT NULL,
	[Is Order Finalized]		BIT						NOT NULL,
	[Lineage Key]				INT						NOT NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED COLUMNSTORE INDEX
);
GO