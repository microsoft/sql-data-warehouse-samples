CREATE TABLE [Fact].[Movement]
(
	[Movement Key]						BIGINT IDENTITY(1,1)	NOT NULL,
	[Date Key]							DATE					NOT NULL,
	[Stock Item Key]					INT						NOT NULL,
	[Customer Key]						INT						NULL,
	[Supplier Key]						INT						NULL,
	[Transaction Type Key]				INT						NOT NULL,
	[WWI Stock Item Transaction ID]		INT						NOT NULL,
	[WWI Invoice ID]					INT						NULL,
	[WWI Purchase Order ID]				INT						NULL,
	[Quantity]							INT						NOT NULL,
	[Lineage Key]						INT						NOT NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	 CLUSTERED COLUMNSTORE INDEX
);
GO