# This PS script creates the DDL for all Views, SPs, and Table objects

# Basic connection properties
$SqlServerName = <server>
$SqlDatabaseName = <database>
$Username = <user>
$Password = <password>

# Main function to call with all objects
function CreateScriptsForObjects([System.Data.SqlClient.SqlConnection]$DbCon, [string]$QueryForObjectList, [string]$FileWithGetCreateQuery, [string]$ObjectType) {
    $GetObjectListCmd = New-Object System.Data.SqlClient.SqlCommand
    $GetObjectListCmd.Connection = $DbCon
    $GetObjectListCmd.CommandText = $QueryForObjectList
    $ObjectListReader = $GetObjectListCmd.ExecuteReader();

    # Looping through all objects of the specified type and creating the DDL
    if ($ObjectListReader.HasRows)
    {
        while ($ObjectListReader.Read())
        {
            $SchemaName = $ObjectListReader.GetString(0)
            $ObjectName = $ObjectListReader.GetString(1)
            $ObjectId = $ObjectListReader.GetInt32(2)
            if (-not (Test-Path ".\dbo\$ObjectType\")) {
                mkdir "dbo\$ObjectType\"
            }
            echo "Scripting CREATE for [$SchemaName].[$ObjectName] of type $ObjectType"

	    # DDL output will be in the specified path under dbo
            sqlcmd -i .\$FileWithGetCreateQuery -S $SqlServerName -d $SqlDatabaseName -U $Username -P $Password -I -o .\dbo\$ObjectType\$ObjectName.sql -v object_id=$ObjectId -y 0
        }
    }
    $ObjectListReader.Close()
}

# Create connection to Master to get list of objects for catalog views
$userDbCon = New-Object System.Data.SqlClient.SqlConnection

$userDbCon.ConnectionString = "Server = $SqlServerName; Database = $SqlDatabaseName; User ID = $Username; Password = ""$Password"";"
echo $userDbCon.ConnectionString
echo "Opening connection to $SqlServerName"
$userDbCon.Open();
echo "Connection ready to query catalog views"

# Querying catalog views to get the list of objects of every type
$listStoredProceduresQuery = "select sch.name as schema_name, obj.name as object_name, obj.object_id from sys.objects obj inner join sys.schemas sch on obj.schema_id = sch.schema_id where obj.type_desc = 'SQL_STORED_PROCEDURE' and sch.name != 'temp' ORDER BY 1, 2;"
$listFunctionsQuery = "select sch.name as schema_name, obj.name as object_name, obj.object_id from sys.objects obj inner join sys.schemas sch on obj.schema_id = sch.schema_id where obj.type_desc = 'SQL_SCALAR_FUNCTION' and sch.name != 'temp' ORDER BY 1, 2;"
$listViewsQuery = "select sch.name as schema_name, obj.name as object_name, obj.object_id from sys.objects obj inner join sys.schemas sch on obj.schema_id = sch.schema_id where obj.type_desc = 'VIEW' and sch.name != 'temp' ORDER BY 1, 2;"
$listTablesQuery = "select sch.name as schema_name, obj.name as object_name, obj.object_id from sys.tables obj inner join sys.schemas sch on obj.schema_id = sch.schema_id where is_external = 0 and obj.name not like '%_Backup%' and obj.name not like '%_BKP%' and obj.name not like '%_tmp%' and obj.name not like '%_wDuplicates%' and sch.name != 'temp' ORDER BY 1, 2;"

# Remove and recreate the folder with all the CREATE statements if it exists to cover object deletions
if (Test-Path ".\dbo") {
    rm .\dbo
}

# Call the function exporting the create statements for every object type
echo "Scripting Stored Procedures"
CreateScriptsForObjects $userDbCon $listStoredProceduresQuery "GetCreateStatement_Function_Proc_View.sql" "StoredProcedures"
echo "Scripting Functions"
CreateScriptsForObjects $userDbCon $listFunctionsQuery "GetCreateStatement_Function_Proc_View.sql" "Functions"
echo "Scripting Views"
CreateScriptsForObjects $userDbCon $listViewsQuery "GetCreateStatement_Function_Proc_View.sql" "Views"
echo "Scripting Tables"
CreateScriptsForObjects $userDbCon $listTablesQuery "GetCreateStatement_Table.sql" "Tables"
echo "Done creating scripts"


