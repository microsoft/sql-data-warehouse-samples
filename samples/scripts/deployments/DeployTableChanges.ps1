# PS script to stage all metadata of all tables from the source database to target database (column, column type)
# The reason to stage is to run a TSQL script to loop through the metadata and apply any changes to sync the target database

# source database connection properties
$SqlServerName = <server>
$SqlDatabaseName = <sourcedb>
$Username = <sourceuser>
$Password = <sourcepassword>

# target database connection properties
$Server = <server>
$Database = <targetdb>
$User = <userdb>
$Pass = <targetpassword>
 
function DeployScript([System.Data.SqlClient.SqlConnection]$DbCon, [string]$QueryForObjectList, [string]$FileWithGetCreateQuery, [string]$ObjectType) {
    
	echo "Starting source table connection"
	$GetObjectListCmd = New-Object System.Data.SqlClient.SqlCommand
    $GetObjectListCmd.Connection = $DbCon
    $GetObjectListCmd.CommandText = $QueryForObjectList
    $ObjectListReader = $GetObjectListCmd.ExecuteReader();
    if ($ObjectListReader.HasRows)
    {
		echo "Creating new table in target db to store columns"
		$TargetColDbCon = New-Object System.Data.SqlClient.SqlConnection
		$TargetColDbCon.ConnectionString = "Server = $Server; Database = $Database; MultipleActiveResultSets=true; User ID = $User; Password = ""$Pass"";"
		$TargetColDbCon.Open();
		$AddColumnListCmd = New-Object System.Data.SqlClient.SqlCommand
		$AddColumnListCmd.Connection = $TargetColDbCon
		$AddColumnListCmd.CommandText = "drop table sourceColumns; CREATE TABLE sourceColumns (databasename varchar(8000), tablename varchar(8000),colname sysname,user_type_id tinyint,column_id int)"
		$TargetColumnListReader = $AddColumnListCmd.ExecuteReader();
		$TargetColumnListReader.Close();

		# Looping through all tables in source db
        while ($ObjectListReader.Read())
        {
            $SchemaName = $ObjectListReader.GetString(0)
            $ObjectName = $ObjectListReader.GetString(1)
            $ObjectId = $ObjectListReader.GetInt32(2)

			echo "Operating on table: $ObjectName "
			$ColDbCon = New-Object System.Data.SqlClient.SqlConnection
			$ColDbCon.ConnectionString = "Server = $SqlServerName; Database = $SqlDatabaseName; MultipleActiveResultSets=true; User ID = $Username; Password = ""$Password"";"
			$ColDbCon.Open();
			$GetColumnListCmd = New-Object System.Data.SqlClient.SqlCommand
			$GetColumnListCmd.Connection = $ColDbCon
			$GetColumnListCmd.CommandText = "select name, user_type_id, column_id from sys.columns where object_id = $ObjectId"
			$ColumnListReader = $GetColumnListCmd.ExecuteReader();

			# Looping through all columns of the table to add to target db
			If ($ColumnListReader.HasRows)
			{
				while ($ColumnListReader.Read())
				{
					echo "Found column for table $ObjectName"
					$ColumnName = $ColumnListReader.GetString(0)
					$ColumnType = $ColumnListReader.GetInt32(1)
					$ColumnId = $ColumnListReader.GetInt32(2)
					$ColumnTable = $ObjectName
		
					echo "Inserting column $ColumnName for table $ObjectName"
					$AddColumnListCmd.CommandText = "INSERT INTO sourceColumns VALUES ('$SqlDatabaseName', '$ObjectName', '$ColumnName', '$ColumnType', '$ColumnId');"
					$TargetColumnListReader = $AddColumnListCmd.ExecuteReader();
					$TargetColumnListReader.Close()
				}
			}

			$ColumnListReader.Close()
			$TargetColumnListReader.Close()
        }
    }
    $ObjectListReader.Close()
	$ColumnListReader.Close()
	$TargetColumnListReader.Close()
}

# Create connection to source database
$userDbCon = New-Object System.Data.SqlClient.SqlConnection
$userDbCon.ConnectionString = "Server = $SqlServerName; Database = $SqlDatabaseName; MultipleActiveResultSets=true; User ID = $Username; Password = ""$Password"";"
echo "Opening connection to $SqlServerName"
$userDbCon.Open();
echo "Connection ready to source database"

# Query to get list of all tables in source database
$listTablesQuery = "select sch.name as schema_name, obj.name as object_name, obj.object_id from sys.tables obj inner join sys.schemas sch on obj.schema_id = sch.schema_id where is_external = 0 and obj.name not like '%_Backup%' and obj.name not like '%_BKP%' and obj.name not like '%_tmp%' and obj.name not like '%_wDuplicates%' and sch.name != 'temp' ORDER BY 1, 2;"

# Remove the folder with all the CREATE statements if it exists
if (Test-Path ".\DeployScripts") {
    rm .\DeployScripts
}

echo "Processing tables"
DeployScript $userDbCon $listTablesQuery "AddTableChanges.sql" "Tables"
echo "Completing Inserting New Columns into Production database"