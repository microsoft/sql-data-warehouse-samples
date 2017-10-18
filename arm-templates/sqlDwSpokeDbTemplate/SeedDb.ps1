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
$Database = 'spokex3fi2w5d4o6o4dbn0'

# Define the connection to the SQL Database 
$Conn = New-Object System.Data.SqlClient.SqlConnection("Server=tcp:$SqlServer.database.windows.net,$SqlServerPort;Initial Catalog=$Database;Persist Security Info=False;User ID=$SqlUsername;Password=$SqlPass;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;")         
# Open the SQL connection 
$Conn.Open() 

# Define the SQL command to run. In this case we are getting the number of rows in the table 
$Cmd=new-object system.Data.SqlClient.SqlCommand("select @@Version", $Conn) 
$Cmd.CommandTimeout=120 

# Execute the SQL command 
$Ds=New-Object system.Data.DataSet 
$Da=New-Object system.Data.SqlClient.SqlDataAdapter($Cmd) 
[void]$Da.fill($Ds) 

# Output the count 
$Ds.Tables.Column1 

# Close the SQL connection 
$Conn.Close()