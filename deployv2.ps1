Connect-AzAccount

$adminLogin = "adminuser"
$resourceGroupName = "rgdbresiliencylab"
$location = "eastus"
$databaseName = "dbapp1"
$drLocation = "westus"
$password = "SqlPasswd1234567"
$storageaccountname = "storagecsu"

# Set-AzContext -TenantId 16b3c013-d300-468d-ac64-7eda0820b6d3

New-AzResourceGroup -Name $resourceGroupName  -Location $location

Write-host "Creating DB Principal"
New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName  -TemplateFile ./main.bicep -administratorLogin $adminLogin

$failoverGroupName = (Get-AzResource -ResourceGroupName $resourceGroupName -ResourceType Microsoft.Sql/servers).Name |  Select-Object -First 1
$failoverGroupName = $failoverGroupName+"fog"

Write-host "Creating Functions and Frontdoor"
Register-AzResourceProvider -ProviderNamespace Microsoft.Cdn
New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile .\functions_fdv2.bicep -failoverGroupName $failoverGroupName -databaseName $databaseName -adminLogin $adminLogin -contra $password

Write-Output $failoverGroupName

$subscriptionId = (Get-AzContext).Subscription.Id
Write-Output $subscriptionId

$serverName = (Get-AzResource -ResourceGroupName $resourceGroupName -ResourceType Microsoft.Sql/servers).Name|  Select-Object -First 1

$drServerName = (Get-AzResource -ResourceGroupName $resourceGroupName -ResourceType Microsoft.Sql/servers).Name|  Select-Object -First 1
$drServerName = $drServerName + "dr"

$storageaccountname = $storageaccountname + $serverName

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


Write-host "Creating StorageAccount"

$StorageHT = @{
   ResourceGroupName = $resourceGroupName
   Name              = $storageaccountname
   SkuName           = 'Standard_LRS'
   Location          =  $Location
 }
 $StorageAccount = New-AzStorageAccount @StorageHT
 $Context = $StorageAccount.Context

 $ContainerName = 'databasebackup'
New-AzStorageContainer -Name $ContainerName -Context $Context -Permission Blob

Write-host "Adding bacpac to storage account"
$Blob1HT = @{
   File             = '.\database.bacpac'
   Container        = $ContainerName
   Blob             = "database.bacpac"
   Context          = $Context
   StandardBlobTier = 'Hot'
 }
 Set-AzStorageBlobContent @Blob1HT

$storageuri = "https://"+$storageaccountname+".blob.core.windows.net/databasebackup/database.bacpac"


Write-host "Importing bacpac to primary database"

 $importRequest = New-AzSqlDatabaseImport -ResourceGroupName $resourceGroupName `
 -ServerName $serverName -DatabaseName $databaseName `
 -DatabaseMaxSizeBytes 5000000 -StorageKeyType StorageAccessKey `
 -StorageKey $(Get-AzStorageAccountKey `
     -ResourceGroupName $resourcegroupname -StorageAccountName $storageaccountname).Value[0] `
     -StorageUri $storageuri `
     -Edition "Standard" -ServiceObjectiveName "P6" `
     -AdministratorLogin $adminLogin `
     -AdministratorLoginPassword $(ConvertTo-SecureString -String $password -AsPlainText -Force)

   Write-host "Failover group:"
   $failoverGroupName= $failoverGroupName + ".database.windows.net"
     Write-Output $failoverGroupName 
     
