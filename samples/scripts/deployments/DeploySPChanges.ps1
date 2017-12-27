# PS script to generate TSQL change scripts for Stored Procedures

# Basic connection properties
$SqlServerName = <source>
$SqlDatabaseName = <sourcedb>
$Username = <sourceuser>
$Password = <sourcepassword>

function DeployScript([System.Data.SqlClient.SqlConnection]$DbCon, [string]$QueryForObjectList, [string]$FileWithGetCreateQuery, [string]$ObjectType) {
    $GetObjectListCmd = New-Object System.Data.SqlClient.SqlCommand
    $GetObjectListCmd.Connection = $DbCon
    $GetObjectListCmd.CommandText = $QueryForObjectList
    $ObjectListReader = $GetObjectListCmd.ExecuteReader();
    if ($ObjectListReader.HasRows)
    {
        while ($ObjectListReader.Read())
        {
            $SchemaName = $ObjectListReader.GetString(0)
            $ObjectName = $ObjectListReader.GetString(1)
            $ObjectId = $ObjectListReader.GetInt32(2)
            if (-not (Test-Path ".\ChangeScripts_SP\")) {
                mkdir "ChangeScripts_SP\"
            }
            sqlcmd -i .\$FileWithGetCreateQuery -S $SqlServerName -d $SqlDatabaseName -U $Username -P $Password -I -o .\ChangeScripts_SP\$ObjectName.sql -v object_id=$ObjectId -y 0
        }
    }
    $ObjectListReader.Close()
}
# This script calls AddSPChanges which will generate TSQL to drop and recreate SP objects. Security permissions will still need ot be reinstantiated
# Create connection to source database
$userDbCon = New-Object System.Data.SqlClient.SqlConnection

$userDbCon.ConnectionString = "Server = $SqlServerName; Database = $SqlDatabaseName; User ID = $Username; Password = ""$Password"";"
echo $userDbCon.ConnectionString
echo "Opening connection to $SqlServerName"
$userDbCon.Open();
echo "Connection ready"

# Queries to get the list of SP objects
$listStoredProceduresQuery = "select sch.name as schema_name, obj.name as object_name, obj.object_id from sys.objects obj inner join sys.schemas sch on obj.schema_id = sch.schema_id where obj.type_desc = 'SQL_STORED_PROCEDURE' and sch.name != 'temp' ORDER BY 1, 2;"

# Remove the folder with all the change scripts to be executed on the production (target) instance
 if (Test-Path ".\ChangeScripts_SP") {
     rm .\ChangeScripts_SP
 }

# Call the function exporting the create statements for every SP object type
echo "Processing Stored Procedures"
DeployScript $userDbCon $listStoredProceduresQuery "AddSPChanges.sql" "StoredProcedures"



