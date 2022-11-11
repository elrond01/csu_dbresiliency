Register-AzResourceProvider -ProviderNamespace Microsoft.Cdn
New-AzResourceGroup -Name exampleRG -Location eastus
New-AzResourceGroupDeployment -ResourceGroupName exampleRG -TemplateFile .\functions_fd.bicep -appInsightsLocation "east us"
