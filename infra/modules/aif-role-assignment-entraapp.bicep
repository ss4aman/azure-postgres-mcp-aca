extension microsoftGraphV1

@description('AI Foundry project resource ID')
@metadata({
  example: '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/myResourceGroup/providers/Microsoft.CognitiveServices/accounts/myAccount/projects/firstProject'
})
param aifProjectResourceId string

@description('Entra App Service Principal Object ID (resourceId in Graph API)')
param entraAppServicePrincipalObjectId string

@description('Entra App Role ID to assign')
param entraAppRoleId string

// Expected format: /subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.CognitiveServices/accounts/{accountName}/projects/{projectName}
var resourceIdParts = split(aifProjectResourceId, '/')
var aifSubscriptionId = resourceIdParts[2]
var projectResourceGroup = resourceIdParts[4]
var accountName = resourceIdParts[8]
var projectName = resourceIdParts[10]

// Reference the AI Foundry project in its own subscription + resource group.
// Including the subscription ID enables cross-subscription lookup (the Foundry
// project can live in a different subscription than the Container Apps).
resource aifProject 'Microsoft.CognitiveServices/accounts/projects@2025-04-01-preview' existing = {
  scope: resourceGroup(aifSubscriptionId, projectResourceGroup)
  name: '${accountName}/${projectName}'
}

var aifProjectMIPrincipalId = aifProject.identity.principalId

resource appRoleAssignment 'Microsoft.Graph/appRoleAssignedTo@v1.0' = {
  principalId: aifProjectMIPrincipalId
  resourceId: entraAppServicePrincipalObjectId
  appRoleId: entraAppRoleId
}

output roleAssignmentId string = appRoleAssignment.id
output aifProjectMIPrincipalId string = aifProjectMIPrincipalId
