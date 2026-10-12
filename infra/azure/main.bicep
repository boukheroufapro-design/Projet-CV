param location string = resourceGroup().location
param acrName string
param environmentName string
param apiName string
param frontendName string
param apiImage string
param frontendImage string

var acrPullRoleDefinitionId = subscriptionResourceId(
  'Microsoft.Authorization/roleDefinitions',
  '7f951dda-4ed3-4680-a7ca-43fe172d538d'
)
var apiFqdn = '${apiName}.${managedEnvironment.properties.defaultDomain}'

resource registry 'Microsoft.ContainerRegistry/registries@2023-07-01' existing = {
  name: acrName
}

resource managedEnvironment 'Microsoft.App/managedEnvironments@2024-03-01' = {
  name: environmentName
  location: location
  properties: {}
}

resource api 'Microsoft.App/containerApps@2024-03-01' = {
  name: apiName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    managedEnvironmentId: managedEnvironment.id
    configuration: {
      activeRevisionsMode: 'Single'
      ingress: {
        external: false
        targetPort: 8080
        transport: 'http'
      }
      registries: [
        {
          server: registry.properties.loginServer
          identity: 'system'
        }
      ]
    }
    template: {
      containers: [
        {
          name: 'api'
          image: apiImage
          resources: {
            cpu: 0.5
            memory: '1Gi'
          }
          env: [
            {
              name: 'ASPNETCORE_HTTP_PORTS'
              value: '8080'
            }
            {
              name: 'ASPNETCORE_ENVIRONMENT'
              value: 'Production'
            }
          ]
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 3
      }
    }
  }
}

resource frontend 'Microsoft.App/containerApps@2024-03-01' = {
  name: frontendName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    managedEnvironmentId: managedEnvironment.id
    configuration: {
      activeRevisionsMode: 'Single'
      ingress: {
        external: true
        targetPort: 8080
        transport: 'http'
      }
      registries: [
        {
          server: registry.properties.loginServer
          identity: 'system'
        }
      ]
    }
    template: {
      containers: [
        {
          name: 'frontend'
          image: frontendImage
          resources: {
            cpu: 0.25
            memory: '0.5Gi'
          }
          env: [
            {
              name: 'API_UPSTREAM'
              value: 'https://${apiFqdn}'
            }
            {
              name: 'NGINX_ENVSUBST_FILTER'
              value: '^API_UPSTREAM$'
            }
          ]
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 3
      }
    }
  }
}

resource apiAcrPull 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(registry.id, api.identity.principalId, acrPullRoleDefinitionId)
  scope: registry
  properties: {
    roleDefinitionId: acrPullRoleDefinitionId
    principalId: api.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

resource frontendAcrPull 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(registry.id, frontend.identity.principalId, acrPullRoleDefinitionId)
  scope: registry
  properties: {
    roleDefinitionId: acrPullRoleDefinitionId
    principalId: frontend.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

output frontendFqdn string = frontend.properties.configuration.ingress.fqdn
output apiFqdn string = apiFqdn
