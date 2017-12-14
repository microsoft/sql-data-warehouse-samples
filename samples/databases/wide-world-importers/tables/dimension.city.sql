CREATE TABLE [Dimension].[City]
(
    [City Key]                   INT			NOT NULL,
    [WWI City ID]                INT			NOT NULL,
    [City]                       NVARCHAR (50)	NOT NULL,
    [State Province]             NVARCHAR (50)	NOT NULL,
    [Country]                    NVARCHAR (60)	NOT NULL,
    [Continent]                  NVARCHAR (30)	NOT NULL,
    [Sales Territory]            NVARCHAR (50)	NOT NULL,
    [Region]                     NVARCHAR (30)	NOT NULL,
    [Subregion]                  NVARCHAR (30)	NOT NULL,
    [Latest Recorded Population] BIGINT			NOT NULL,
    [Valid From]                 DATETIME2 (7)	NOT NULL,
    [Valid To]                   DATETIME2 (7)	NOT NULL,
    [Lineage Key]                INT			NOT NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED INDEX
	(
		[City Key] ASC
	)
);
GO