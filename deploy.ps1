Connect-AzAccount

$adminLogin = "adminuser"
$resourceGroupName = "rgdbresiliency4"
$location = "eastus"
$databaseName = "dbapp1"
$drLocation = "westus"
$password = "SqlPasswd1234567"

# Set-AzContext -TenantId 16b3c013-d300-468d-ac64-7eda0820b6d3

New-AzResourceGroup -Name $resourceGroupName  -Location $location
New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName  -TemplateFile ./main.bicep -administratorLogin $adminLogin

$failoverGroupName = (Get-AzResource -ResourceGroupName $resourceGroupName -ResourceType Microsoft.Sql/servers).Name |  Select-Object -First 1
$failoverGroupName = $failoverGroupName+"fog"

Write-Output $failoverGroupName

$subscriptionId = (Get-AzContext).Subscription.Id
Write-Output $subscriptionId

$serverName = (Get-AzResource -ResourceGroupName $resourceGroupName -ResourceType Microsoft.Sql/servers).Name|  Select-Object -First 1

$drServerName = (Get-AzResource -ResourceGroupName $resourceGroupName -ResourceType Microsoft.Sql/servers).Name|  Select-Object -First 1
$drServerName = $drServerName + "dr"

# Create a secondary server in the failover region
Write-host "Creating a secondary server in the failover region..."
$drServer = New-AzSqlServer -ResourceGroupName $resourceGroupName `
   -ServerName $drServerName `
   -Location $drLocation `
   -SqlAdministratorCredentials $(New-Object -TypeName System.Management.Automation.PSCredential `
      -ArgumentList $adminlogin, $(ConvertTo-SecureString -String $password -AsPlainText -Force))
$drServer

# Create a failover group between the servers
$failovergroup = Write-host "Creating a failover group between the primary and secondary server..."
New-AzSqlDatabaseFailoverGroup `
   -ResourceGroupName $resourceGroupName `
   -ServerName $serverName `
   -PartnerServerName $drServerName  `
   -FailoverGroupName $failoverGroupName `
   -FailoverPolicy Automatic `
   -GracePeriodWithDataLossHours 1
$failovergroup

# Add the database to the failover group
Write-host "Adding the database to the failover group..."
Get-AzSqlDatabase `
   -ResourceGroupName $resourceGroupName `
   -ServerName $serverName `
   -DatabaseName $databaseName | `
Add-AzSqlDatabaseToFailoverGroup `
   -ResourceGroupName $resourceGroupName `
   -ServerName $serverName `
   -FailoverGroupName $failoverGroupName
Write-host "Successfully added the database to the failover group..."

$myIP = (Invoke-WebRequest -uri "https://api.ipify.org/").Content

Write-host "Adding database rules for client and Azure ips..."

New-AzSqlServerFirewallRule -ResourceGroupName $resourceGroupName -ServerName $serverName -AllowAllAzureIPs
New-AzSqlServerFirewallRule -ResourceGroupName $resourceGroupName -ServerName $drServerName -AllowAllAzureIPs
New-AzSqlServerFirewallRule -FirewallRuleName "Rule01" -ResourceGroupName $resourceGroupName -ServerName $serverName -StartIpAddress $myIP -EndIpAddress $myIP 
New-AzSqlServerFirewallRule -FirewallRuleName "Rule01" -ResourceGroupName $resourceGroupName -ServerName $drServerName -StartIpAddress $myIP -EndIpAddress $myIP
