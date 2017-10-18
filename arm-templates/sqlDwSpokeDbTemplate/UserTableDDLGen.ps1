$SqlCredential = Get-AutomationPSCredential -Name DefaultAzureCredential 
 
if ($SqlCredential -eq $null) 
{ 
    throw "Could not retrieve '$SqlCredentialAsset' credential asset. Check that you created this first in the Automation service." 
}   
# Get the username and password from the SQL Credential 
$SqlUsername = 'cloudSA'  #$SqlCredential.UserName 
$SqlPass = 'dogmat1C'  #$SqlCredential.GetNetworkCredential().Password
$SqlServerPort = '1433' 
$SqlServer = 'sampleeqsvr'
$Database = 'sampleeqdw'

# Define the connection to the SQL Database 
$Conn = New-Object System.Data.SqlClient.SqlConnection("Server=tcp:$SqlServer.database.windows.net,$SqlServerPort;Initial Catalog=$Database;Persist Security Info=False;User ID=$SqlUsername;Password=$SqlPass;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;")         
# Open the SQL connection 
$Conn.Open() 

# Define the SQL command to run. In this case we are getting the number of rows in the table 
$GetTableSchema=new-object system.Data.SqlClient.SqlCommand("
SELECT 
	tbl.name
,	sch.name 
FROM sys.tables tbl
JOIN sys.schemas sch 
ON	tbl.schema_id = sch.schema_id
WHERE is_external = 0
", $Conn) 
$GetTableSchema.CommandTimeout=120 

# Execute the SQL command 
$Ds=New-Object system.Data.DataSet 
$Da=New-Object system.Data.SqlClient.SqlDataAdapter($GetTableSchema) 
[void]$Da.fill($Ds) 

# Output the count 
$Ds.Tables.Column1
$Ds.Tables.Column2
 

# Close the SQL connection 
$Conn.Close()