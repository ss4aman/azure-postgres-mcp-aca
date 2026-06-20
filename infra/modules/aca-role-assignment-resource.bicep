@description('Full resource ID of the Postgres resource')
@metadata({
  example: '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/myResourceGroup/providers/Microsoft.DBforPostgreSQL/flexibleServers/myPostgresServer'
})
param postgresResourceId string

@description('Azure Container App Managed Identity *principal/object* ID (GUID)')
param acaPrincipalId string

@description('Role definition ID (GUID) for the Azure RBAC role (e.g., Contributor = b24988ac-6180-42a0-ab88-20f7382dd24c)')
param roleDefinitionId string

// Expected format: /subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.DBforPostgreSQL/flexibleServers/{name}
var resourceIdParts = split(postgresResourceId, '/')
var postgresSubscriptionId = resourceIdParts[2]
var resourceGroupName = resourceIdParts[4]

// Scope the role assignment to the Postgres server's subscription + resource group.
// Including the subscription ID enables cross-subscription deployment (the Postgres
// server can live in a different subscription than the Container Apps).
module postgresRoleAssignment './aca-role-assignment-resource-postgres.bicep' = {
  name: 'aca-role-assignment-module'
  scope: resourceGroup(postgresSubscriptionId, resourceGroupName)
  params: {
    postgresResourceId: postgresResourceId
    acaPrincipalId: acaPrincipalId
    roleDefinitionId: roleDefinitionId
  }
}

output roleAssignmentId string = postgresRoleAssignment.outputs.roleAssignmentId
output roleAssignmentName string = postgresRoleAssignment.outputs.roleAssignmentName
