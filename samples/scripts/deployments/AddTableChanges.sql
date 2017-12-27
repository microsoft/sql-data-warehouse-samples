/* This script checks the source table meta data which has been staged to keep the taraget instance in sync */ 

 SET NOCOUNT ON;

-- All tables currently in "production db"
SELECT *, row_number() over (order by (select 0)) as number INTO #Temp1
FROM( 
SELECT obj.name as object_name, obj.object_id FROM sys.tables obj inner join sys.schemas sch on obj.schema_id = sch.schema_id 
WHERE is_external = 0 and obj.name not like '%_Backup%' 
and obj.name not like '%_BKP%' and obj.name not like '%_tmp%' 
and obj.name not like '%_wDuplicates%' and sch.name != 'temp'
and NOT(obj.name LIKE '%Source%')
 ) A

DECLARE @TotalTables int 
DECLARE @counter int 
DECLARE @currentTable nvarchar(max);

SET @TotalTables = (SELECT count(*) FROM #Temp1);
SET @counter = 1

-- Looping through all tables in "production" and checking for deltas
while (@counter <= @TotalTables) 
begin

	-- Current table in prod db and collecting all column names it should have based on source columns
	SET @currentTable = (SELECT object_name FROM #Temp1 WHERE number = @counter);
	SELECT sys.columns.name, sys.columns.user_type_id INTO #tempprodtablecolumns
	FROM
		sys.columns
		JOIN sys.tables ON
		sys.columns.object_id = sys.tables.object_id
	WHERE
	  sys.tables.name = @currentTable;

	SELECT tablename, colname, user_type_id INTO #tempdevtablecolumns FROM sourceColumns WHERE tablename = @currentTable

	-- Find newly added columns not in "production" into temp table
	SELECT user_type_id, colname, row_number() over (order by (select 0)) as number INTO #addedcolumns FROM 
	(SELECT b.*,a.user_type_id missingcolumn 
	FROM #tempprodtablecolumns a
	RIGHT OUTER JOIN #tempdevtablecolumns b ON a.name = b.colname) A WHERE missingcolumn is NULL;

	Select * from #tempprodtablecolumns
	Select * from #tempdevtablecolumns
	Select * from #addedcolumns

	-- Clean up temp tables
	drop table #tempprodtablecolumns;
	drop table #tempdevtablecolumns;

	DECLARE @totalnewcolumns int 
	DECLARE @secondcounter int 
	DECLARE @currentcolname nvarchar(max);
	DECLARE @currentcoltype nvarchar(max);
	DECLARE @coltypename nvarchar(max);
	DECLARE @SQL nvarchar(max);

	SET @totalnewcolumns = (SELECT count(*) FROM #addedcolumns);
	SET @secondcounter = 1

	print 'Total new columns for table ' + @currentTable + ' is ' + CONVERT(varchar(10), @totalnewcolumns);

	-- Loop through added columns and adding columns in "production" table
	while (@secondcounter <= @totalnewcolumns) 
	begin
		SET @currentcolname = (SELECT colname from #addedcolumns where number = @secondcounter);
		SET @currentcoltype = (SELECT user_type_id from #addedcolumns where number = @secondcounter);
		SET @coltypename = (SELECT name from sys.types where user_type_id = @currentcoltype)

		SET @SQL = 'ALTER TABLE ' + @currentTable + ' ADD ' + @currentcolname + ' ' + @coltypename;
		print '---------- Altering statement: ' + @SQL + ' ---------- ';
		exec(@SQL);
		SET @secondcounter = @secondcounter + 1
	end

	DROP table #addedcolumns
	set @counter = @counter + 1;
end

DROP table #Temp1;