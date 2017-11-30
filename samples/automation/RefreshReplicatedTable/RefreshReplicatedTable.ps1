workflow RefreshReplicatedTable
{
    Param(
        [Parameter(Mandatory=$true)]
        $ConnectionName = "AzureRunAsConnection",
        [Parameter(Mandatory=$true)]
        [string]$SQLActionAccountName,
        [Parameter(Mandatory=$true,
        HelpMessage="ServerName must be the fully qualified name.")]
        [string]$ServerName,
        [Parameter(Mandatory=$true)]
        [string]$DWName,
        [int]$RetryCount = 4,
        [int]$RetryTime = 15
    )

    #Pulling in credentials used in the process
    $credSQL = Get-AutomationPSCredential -Name $SQLActionAccountName
    $AutomationConnection = Get-AutomationConnection -Name $ConnectionName
    $null = Add-AzureRmAccount -ServicePrincipal -TenantId $AutomationConnection.TenantId -ApplicationId $AutomationConnection.ApplicationId -CertificateThumbprint $AutomationConnection.CertificateThumbprint
    $DWDetail = (Get-AzureRmResource | Where-Object {$_.Kind -like "*datawarehouse*" -and $_.Name -like "*/$DWName"})
    if ($null -ne $DWDetail) {
        $DWDetail = $DWDetail.ResourceId.Split("/")
        $SQLUser = $credSQL.Username
        $SQLPass = $credSQL.GetNetworkCredential().Password
        $cRetry = 0
        do {
            if ($cRetry -ne 0) {Start-Sleep -Seconds $RetryTime}
            $DWStatus = (Get-AzureRmSqlDatabase -ResourceGroup $DWDetail[4] -ServerName $DWDetail[8] -DatabaseName $DWDetail[10]).Status
            Write-Verbose "Test $cRetry status is $DWStatus looking for Online"
            $cRetry++
        } while ($DWStatus -ne "Online" -and $cRetry -le $RetryCount )
        if ($DWStatus -eq "Online") {
            Write-Verbose "Refreshing Replicated Tables"
            InLineScript {
                $ReplicatedTablesQuery = @"
                SELECT [ReplicatedTable] = quotename(schema_name(t.schema_id)) + '.' + quotename(t.[name])
                FROM sys.tables t  
                JOIN sys.pdw_replicated_table_cache_state c  
                  ON c.object_id = t.object_id 
                JOIN sys.pdw_table_distribution_properties p 
                  ON p.object_id = t.object_id 
                WHERE c.[state] = 'NotReady'
                  AND p.[distribution_policy_desc] = 'REPLICATE'
"@
                $DBConnection = New-Object System.Data.SqlClient.SqlConnection("Server=$($Using:ServerName); Database=$($Using:DWName);User ID=$($Using:SQLUser);Password=$($Using:SQLPass);")
                $DBConnection.Open()
                $DBCommand = New-Object System.Data.SqlClient.SqlCommand($ReplicatedTablesQuery, $DBConnection)
                $DBAdapter = New-Object -TypeName System.Data.SqlClient.SqlDataAdapter
                $ReplicatedDataSet = New-Object -TypeName System.Data.DataSet
                $DBAdapter.SelectCommand = $DBCommand
                $DBAdapter.Fill($ReplicatedDataSet) | Out-Null
                if ($ReplicatedDataSet.Tables[0].Rows.Count -gt 0) {
                    $RefreshQuery = ""
                    foreach ($ReplicatedTableName in $ReplicatedDataSet.Tables[0].Rows.ReplicatedTable) {
                        $RefreshQuery += "SELECT TOP 1 * FROM [$ReplicatedTableName]`r`n"
                    }
                    $DBCommand = New-Object System.Data.SqlClient.SqlCommand($RefreshQuery, $DBConnection)
                    $DBAdapter.SelectCommand = $DBCommand
                }
                try{$DBConnection.Close()} catch {}
            }
        }
    }
}
