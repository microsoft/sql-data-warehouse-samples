workflow SuspendOrPauseAzureSQLDataWarehouse
{
    Param(
        [Parameter(Mandatory=$true)]
        [string]$ConnectionName = "AzureRunAsConnection",
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

            #Checking to see if the ADW exists and is online
            $cRetry = 0
            do {
                if ($cRetry -ne 0) {Start-Sleep -Seconds $RetryTime}
                $DWStatus = (Get-AzureRmSqlDatabase -ResourceGroup $DWDetail[4] -ServerName $DWDetail[8] -DatabaseName $DWDetail[10]).Status
                Write-Verbose "Test $cRetry status is $DWStatus looking for Online"
                $cRetry++
            } while ($DWStatus -ne "Online" -and $cRetry -le $RetryCount )
            if ($DWStatus -eq "Online") {
                Write-Verbose "Querying data warehouse for activity"
                $CanPause = InLineScript {
                    $testquery = @"
                    with test as 
                    (
                        select
                        (select @@version) version_number
                        ,(select count(*) from sys.dm_pdw_exec_requests where status in ('Running', 'Pending', 'CancelSubmitted') and session_id != SESSION_ID()) active_query_count
                        ,(select count(*) from sys.dm_pdw_exec_sessions where is_transactional = 1) as session_transactional_count
                        ,(select count(*) from sys.dm_pdw_waits where type = 'Exclusive') as pdw_waits
                    )
                    select
                        case when
                                version_number like 'Microsoft Azure SQL Data Warehouse%'
                                and active_query_count = 0
                                and session_transactional_count = 0
                                and pdw_waits = 0
                                then 1
                        else 0
                        end as CanPause
                    from test
"@
                    $DBConnection = New-Object System.Data.SqlClient.SqlConnection("Server=$($Using:ServerName); Database=$($Using:DWName);User ID=$($Using:SQLUser);Password=$($Using:SQLPass);")
                    $DBConnection.Open()
                    $DBCommand = New-Object System.Data.SqlClient.SqlCommand($testquery, $DBConnection)
                    $DBAdapter = New-Object -TypeName System.Data.SqlClient.SqlDataAdapter
                    $DBDataSet = New-Object -TypeName System.Data.DataSet
                    $DBAdapter.SelectCommand = $DBCommand
                    $DBAdapter.Fill($DBDataSet) | Out-Null
                    # Returning result to CanPause
                    if ($DBDataSet.Tables[0].Rows[0].CanPause) {$true} else {$false}
                    try{$DBConnection.Close()} catch {}
                }
                Write-Verbose "Activity request is $CanPause"
                if ($CanPause) {
                    Write-Verbose "Calling suspend/pause"
                    Get-AzureRmSqlDatabase -ResourceGroup $DWDetail[4] -ServerName $DWDetail[8] -DatabaseName $DWDetail[10] | Suspend-AzureRmSqlDatabase
                } else {
                    Write-Error "Azure SQL Data Warehouse $DWName on server $ServerName has outstanding request and will not be paused at this time."
                }
            }
        }
        else {
            Write-Error "No Azure SQL Data Warehouse named $DWName exist on SQL Server $ServerName."
        }
}