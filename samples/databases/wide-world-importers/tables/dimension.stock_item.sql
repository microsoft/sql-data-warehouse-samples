CREATE TABLE [Dimension].[Stock Item]
(
	[Stock Item Key]			INT				NOT NULL,
	[WWI Stock Item ID]			INT				NOT NULL,
	[Stock Item]				NVARCHAR(100)	NOT NULL,
	[Color]						NVARCHAR(20)	NOT NULL,
	[Selling Package]			NVARCHAR(50)	NOT NULL,
	[Buying Package]			NVARCHAR(50)	NOT NULL,
	[Brand]						NVARCHAR(50)	NOT NULL,
	[Size]						NVARCHAR(20)	NOT NULL,
	[Lead Time Days]			INT				NOT NULL,
	[Quantity Per Outer]		INT				NOT NULL,
	[Is Chiller Stock]			BIT				NOT NULL,
	[Barcode]					NVARCHAR(50)	NULL,
	[Tax Rate]					DECIMAL(18, 3)	NOT NULL,
	[Unit Price]				DECIMAL(18, 2)	NOT NULL,
	[Recommended Retail Price]	DECIMAL(18, 2)	NULL,
	[Typical Weight Per Unit]	DECIMAL(18, 3)	NOT NULL,
	[Photo]						VARBINARY(MAX)	NULL,
	[Valid From]				DATETIME2(7)	NOT NULL,
	[Valid To]					DATETIME2(7)	NOT NULL,
	[Lineage Key]				INT				NOT NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED INDEX
	(
		[Stock Item Key] ASC
	)
);
GO