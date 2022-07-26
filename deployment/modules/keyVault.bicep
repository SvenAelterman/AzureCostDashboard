param location string
param kvName string
param tags object

resource kv 'Microsoft.KeyVault/vaults@2021-11-01-preview' = {
  name: kvName
  location: location
  properties: {
    sku: {
      name: 'standard'
      family: 'A'
    }
    tenantId: subscription().tenantId
    enableSoftDelete: false
    enableRbacAuthorization: true
  }
  tags: tags
}

output keyVaultName string = kv.name
