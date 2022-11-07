# Common Bicep operations

## Install Bicep CLI in Azure CLI

```bash
az bicep install

az bicep version

az bicep upgrade
```

## Convert .bicep to .json

```bash
bicep build .\main.bicep --outfile .\arm-main.json

az bicep build --file .\main.bicep
```

## Convert .json to .bicep

```bash
bicep decompile .\arm-main.json --outfile .\arm.bicep

az bicep decompile --file .\arm-main.json
```

## Resource group deployments

### PowerShell

```powershell
New-AzResourceGroupDeployment -ResourceGroupName 'test-rg' -TemplateFile '.\main.bicep' -WhatIf
```

#### Azure CLI

```bash
az deployment group create --resource-group 'test-rg' --template-file '.\main.bicep'
```

### Bicep PowerShell Module

#### Installation and discovery

```powershell
Install-Module -Name Bicep -Verbose -Force

Update-Help -Force -ErrorAction SilentlyContinue

Get-Command -Module Bicep

```

#### Create JSON parameter file from a Bicep file

```powershell
New-BicepParameterFile -Path '.\AzureFirewall.bicep' -Parameters All
```

#### Validate a Bicep file

```powershell
PS C:\> Test-BicepFile -Path 'MyBicep.bicep' -AcceptDiagnosticLevel 'Warning'
```

## Links

Best Practices <https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/best-practices>
Vpn y Conecciones <https://www.cloudninja.nu/post/2021/06/getting-started-with-github-actions-and-bicep-part-4/>
