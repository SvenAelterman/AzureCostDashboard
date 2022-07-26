param location string
param namingStructure string
param tags object = {}

var managedVnetName = 'default'
var autoResolveIntegrationRuntimeName = 'AutoResolveIntegrationRuntime'

resource adf 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: replace(namingStructure, '{rtype}', 'adf')
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  tags: tags
}

// deployment script to stop triggers
// module deploymentScript 'deploymentScript.bicep' = {
//   name: 'StopTrigger-${replace(deploymentNameStructure, '{rtype}', 'dplscr')}'
//   params: {
//     location: location
//     subwloadname: 'StopTriggers'
//     namingStructure: namingStructure
//     arguments: ' -ResourceGroupName ${resourceGroup().name} -azureDataFactoryName ${adf.name}'
//     scriptContent: '\r\n          param(\r\n            [string] [Parameter(Mandatory=$true)] $ResourceGroupName,\r\n            [string] [Parameter(Mandatory=$true)] $azureDataFactoryName\r\n            )\r\n\r\n          Connect-AzAccount -Identity\r\n\r\n          # Stop Triggers\r\n          Get-AzDataFactoryV2Trigger -DataFactoryName $azureDataFactoryName -ResourceGroupName $ResourceGroupName | Where-Object { $_.RuntimeState -eq \'Started\' } | Stop-AzDataFactoryV2Trigger -Force | Out-Null\r\n'
//     userAssignedIdentityId: userAssignedIdentityId
//   }
// }

resource managedVnet 'Microsoft.DataFactory/factories/managedVirtualNetworks@2018-06-01' = {
  name: '${adf.name}/${managedVnetName}'
  properties: {}
}

resource integrationRuntime 'Microsoft.DataFactory/factories/integrationRuntimes@2018-06-01' = {
  name: '${adf.name}/${autoResolveIntegrationRuntimeName}'
  dependsOn: [
    managedVnet
  ]
  properties: {
    type: 'Managed'
    managedVirtualNetwork: {
      type: 'ManagedVirtualNetworkReference'
      referenceName: managedVnetName
    }
    typeProperties: {
      computeProperties: {
        location: 'AutoResolve'
      }
    }
  }
}

// resource adfPrivateStgRole 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
//   name: guid('rbac-${privateStorageAcct.name}-adf')
//   scope: privateStorageAcct
//   properties: {
//     roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')
//     principalId: adf.identity.principalId
//     principalType: 'ServicePrincipal'
//   }
// }

output principalId string = adf.identity.principalId
output name string = adf.name
