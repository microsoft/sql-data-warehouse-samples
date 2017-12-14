CREATE TABLE [Fact].[Stock Holding]
(
	[Stock Holding Key]				BIGINT IDENTITY(1,1)	NOT NULL,
	[Stock Item Key]				INT						NOT NULL,
	[Quantity On Hand]				INT						NOT NULL,
	[Bin Location]					NVARCHAR(20)			NOT NULL,
	[Last Stocktake Quantity]		INT						NOT NULL,
	[Last Cost Price]				DECIMAL(18, 2)			NOT NULL,
	[Reorder Level]					INT						NOT NULL,
	[Target Stock Level]			INT						NOT NULL,
	[Lineage Key]					INT						NOT NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED COLUMNSTORE INDEX
);
GO