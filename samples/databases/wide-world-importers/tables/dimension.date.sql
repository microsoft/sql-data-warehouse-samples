CREATE TABLE [Dimension].[Date]
(
	[Date]						DATE			NOT NULL,
	[Day Number]				INT				NOT NULL,
	[Day]						NVARCHAR(10)	NOT NULL,
	[Month]						NVARCHAR(10)	NOT NULL,
	[Short Month]				NVARCHAR(3)		NOT NULL,
	[Calendar Month Number]		INT				NOT NULL,
	[Calendar Month Label]		NVARCHAR(20)	NOT NULL,
	[Calendar Year]				INT				NOT NULL,
	[Calendar Year Label]		NVARCHAR(10)	NOT NULL,
	[Fiscal Month Number]		INT				NOT NULL,
	[Fiscal Month Label]		NVARCHAR(20)	NOT NULL,
	[Fiscal Year]				INT				NOT NULL,
	[Fiscal Year Label]			NVARCHAR(10)	NOT NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED INDEX
	(
		[Date] ASC
	)
);
GO