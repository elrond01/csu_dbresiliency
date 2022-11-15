# Set variables
$resourceGroupName = "rgdbresiliencylab"
$serverName = "ato5cabrad3we"
$failoverGroupName = $serverName+"fog"
$drServerName = $serverName + "dr"

# Check role of secondary replica
Write-host "Confirming the secondary replica is secondary...."
(Get-AzSqlDatabaseFailoverGroup `
   -FailoverGroupName $failoverGroupName `
   -ResourceGroupName $resourceGroupName `
   -ServerName $drServerName).ReplicationRole

# Failover to secondary server
Write-host "Failing over failover group to the secondary..."
Switch-AzSqlDatabaseFailoverGroup `
   -ResourceGroupName $resourceGroupName `
   -ServerName $drServerName `
   -FailoverGroupName $failoverGroupName
Write-host "Failed failover group successfully to" $drServerName

# Revert failover to primary server
Write-host "Failing over failover group to the primary...."
Switch-AzSqlDatabaseFailoverGroup `
   -ResourceGroupName $resourceGroupName `
   -ServerName $serverName `
   -FailoverGroupName $failoverGroupName
Write-host "Failed failover group successfully back to" $serverName
