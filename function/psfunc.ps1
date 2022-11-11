Register-AzResourceProvider -ProviderNamespace Microsoft.Cdn
New-AzResourceGroupDeployment -ResourceGroupName rgdbresiliency -TemplateFile .\functions_fd.bicep -appInsightsLocation "east us"
