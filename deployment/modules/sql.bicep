param namingStructure string
param location string
@secure()
param databasePassword string

resource sqlServer 'Microsoft.Sql/servers@2021-02-01-preview' = {
  name: replace(namingStructure, '{rtype}', 'sql')
  location: location
  properties: {
    administratorLogin: 'dbadmin'
    administratorLoginPassword: databasePassword
    minimalTlsVersion: '1.2'
  }
}

resource sqlDb 'Microsoft.Sql/servers/databases@2021-02-01-preview' = {
  parent: sqlServer
  name: replace(namingStructure, '{rtype}', 'sqldb')
  location: location
  sku: {
    name: 'S1'
  }
}

output sqlServerUrl string = sqlServer.properties.fullyQualifiedDomainName
output sqlUserName string = sqlServer.properties.administratorLogin
