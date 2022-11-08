@description('The name of the SQL primary logical server.')
param serverName string = uniqueString('sql', resourceGroup().id)

// @description('The name of the SQL secondary logical server.')
// param serverNameSec string = uniqueString('sql', resourceGroup().id)

@description('The name of the SQL Database.')
param sqlDBName string = 'dbapp1'

@description('Location for all resources.')
param location string = resourceGroup().location

// @description('Location for DR resources.')
// param locationDR string = 'westus'

@description('The administrator username of the SQL logical server.')
param administratorLogin string

@description('The administrator password of the SQL logical server.')
@secure() 
param administratorLoginPassword string = 'SqlPasswd1234567'

resource sqlServer 'Microsoft.Sql/servers@2021-08-01-preview' = {
  name: serverName
  location: location
  properties: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
  }
  
}

resource sqlDB 'Microsoft.Sql/servers/databases@2021-08-01-preview' = {
  parent: sqlServer
  name: sqlDBName
  location: location
  sku: {
    name: 'Standard'
    tier: 'Standard'
  }
}

