targetScope = 'subscription'

@allowed([
  'eastus2'
  'eastus'
])
param location string
@allowed([
  'test'
  'demo'
  'prod'
])
param environment string
param workloadName string

// Optional parameters
param tags object = {}
param sequence int = 1
param namingConvention string = '{rtype}-{wloadname}-{env}-{loc}-{seq}'

var sequenceFormatted = format('{0:00}', sequence)

// Naming structure only needs the resource type ({rtype}) replaced
var namingStructure = replace(replace(replace(replace(namingConvention, '{env}', environment), '{loc}', location), '{seq}', sequenceFormatted), '{wloadname}', workloadName)

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: replace(namingStructure, '{rtype}', 'rg')
  location: location
  tags: tags
}

module kvShortname 'modules/shortname.bicep' = {
  name: 'kv-shortname'
  scope: rg
  params: {
    location: location
    namingConvention: namingConvention
    resourceType: 'kv'
    environment: environment
    workloadName: workloadName
    sequence: sequence
  }
}

module keyVault 'modules/keyVault.bicep' = {
  name: 'kv'
  scope: rg
  params: {
    location: location
    kvName: kvShortname.outputs.shortName
    tags: {}
  }
}

module sql 'modules/sql.bicep' = {
  name: 'sql'
  scope: rg
  params: {
    location: location
    databasePassword: 'Ch@ngeMe123'
    namingStructure: namingStructure
  }
}

module adf 'modules/adf.bicep' = {
  name: 'adf'
  scope: rg
  params: {
    location: location
    namingStructure: namingStructure
  }
}

output namingStructure string = namingStructure
