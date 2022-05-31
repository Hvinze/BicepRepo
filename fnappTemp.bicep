@description('The name of the function app that you wish to create.')
param appName string = 'demo-fnapp'

@description('Location for all resources.')
@allowed([
  'australiacentral'
  'australiaeast'
  'australiasoutheast'
  'brazilsouth'
  'canadacentral'
  'canadaeast'
  'centralindia'
  'centralus'
  'eastasia'
  'eastus'
  'eastus2'
  'francecentral'
  'germanywestcentral'
  'japaneast'
  'japanwest'
  'koreacentral'
  'northcentralus'
  'northeurope'
  'norwayeast'
  'southafricanorth'
  'southcentralus'
  'southindia'
  'southeastasia'
  'switzerlandnorth'
  'uaenorth'
  'uksouth'
  'ukwest'
  'westcentralus'
  'westeurope'
  'westindia'
  'westus'
  'westus2'
  'westus3'
])
param location string = 'eastus2'

@description('Name of the App Service Plan.')
param hostingPlanName string

@description('The SKU of App Service Plan.')
@allowed([
  'F1'
  'B1'
  'P1V2'
  'P1V3'
  'P2V2'
  'P2V3'
  'P3V2'
  'P3V3'
  'I1V2'
  'I2V2'
  'I3V2'
])
param sku string = 'F1'

@description('Storage Account type')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
])
param storageAccountType string = 'Standard_LRS'

@description('Storage Account name')
param storageAccountName string = ''

@description('The language worker runtime to load in the function app.')
@allowed([
  'node'
  'dotnet'
  'java'
])
param runtime string = 'node'

@description('The owner of resource.')
param ServiceOwner string

@description('Purpose of the resource.')
param Purpose string

@description('Cost Centre of the resource.')
param CostCentre string

@description('Department of the resource')
param Department string

@description('The environment of the resource.')
@allowed([
  'dev'
  'test'
  'pre-prod'
  'prod'
])
param Environment string

var functionAppName_var = appName
var hostingPlanName_var = hostingPlanName
var functionWorkerRuntime = runtime

resource storageAccountName_resource 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountType
  }
  kind: 'Storage'
  tags: {
    Owner: ServiceOwner
    Purpose: Purpose
    CostCentre: CostCentre
    Department: Department
    Enviornment: Environment
  }
}

resource hostingPlanName_resource 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: hostingPlanName_var
  location: location
  sku: {
    name: sku
    tier: 'Dynamic'
  }
  properties: {
    name: hostingPlanName_var
    computeMode: 'Dynamic'
  }
  tags: {
    Owner: ServiceOwner
    Purpose: Purpose
    CostCentre: CostCentre
    Department: Department
    Enviornment: Environment
  }
}

resource functionAppName 'Microsoft.Web/sites@2020-06-01' = {
  name: functionAppName_var
  location: location
  kind: 'functionapp'
  properties: {
    serverFarmId: hostingPlanName_resource.id
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccountName_resource.id, '2019-06-01').keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccountName_resource.id, '2019-06-01').keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower(functionAppName_var)
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~2'
        }
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '~10'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: functionWorkerRuntime
        }
      ]
    }
  }
  tags: {
    Owner: ServiceOwner
    Purpose: Purpose
    CostCentre: CostCentre
    Department: Department
    Enviornment: Environment
  }
}
