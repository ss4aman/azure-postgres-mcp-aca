#!/usr/bin/env pwsh
# Printed automatically by `azd up` (postprovision hook).
# It tells you EXACTLY what to do next: nothing to figure out, just copy/paste.

$ErrorActionPreference = 'SilentlyContinue'

function Get-Val($name) { [Environment]::GetEnvironmentVariable($name) }

$containerAppUrl   = Get-Val 'CONTAINER_APP_URL'
$identityName      = Get-Val 'CONTAINER_APP_IDENTITY_NAME'
$entraClientId     = Get-Val 'ENTRA_APP_CLIENT_ID'
$subscriptionId    = Get-Val 'AZURE_SUBSCRIPTION_ID'
$postgresId        = Get-Val 'POSTGRES_RESOURCE_ID'

# Derive Postgres server name + resource group from its resource ID.
$pgServer = '<your-postgres-server>'
$pgGroup  = '<your-postgres-resource-group>'
if ($postgresId) {
    $parts = $postgresId.Trim('/').Split('/')
    for ($i = 0; $i -lt $parts.Length - 1; $i++) {
        if ($parts[$i] -eq 'resourceGroups') { $pgGroup = $parts[$i + 1] }
        if ($parts[$i] -eq 'flexibleServers') { $pgServer = $parts[$i + 1] }
    }
}

$bar = '=' * 72
Write-Host ''
Write-Host $bar -ForegroundColor Cyan
Write-Host '  MCP SERVER DEPLOYED. TWO STEPS LEFT.' -ForegroundColor Cyan
Write-Host $bar -ForegroundColor Cyan
Write-Host ''
Write-Host 'STEP 1 - Give the MCP server access to your database' -ForegroundColor Yellow
Write-Host '  Connect to your Postgres server with psql (Entra ID auth), then run:'
Write-Host ''
Write-Host "    -- run this in the 'postgres' database:" -ForegroundColor DarkGray
Write-Host "    SELECT * FROM pgaadauth_create_principal('$identityName', false, false);" -ForegroundColor Green
Write-Host ''
Write-Host "    -- run this in the database that holds your tables:" -ForegroundColor DarkGray
Write-Host "    GRANT SELECT ON ALL TABLES IN SCHEMA public TO ""$identityName"";" -ForegroundColor Green
Write-Host "    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO ""$identityName"";" -ForegroundColor Green
Write-Host ''
Write-Host 'STEP 2 - Add the tool to your agent in the Foundry portal' -ForegroundColor Yellow
Write-Host '  Tools -> Add -> Catalog -> "Azure Database for PostgreSQL" -> Create,'
Write-Host '  then "Connect tool with endpoint" and paste these values:'
Write-Host ''
Write-Host "    Remote MCP Server endpoint : $containerAppUrl" -ForegroundColor Green
Write-Host '    Authentication             : Microsoft Entra -> Project Managed Identity'
Write-Host "    Audience                   : $entraClientId" -ForegroundColor Green
Write-Host ''
Write-Host '  Then paste these agent instructions (fill in <DATABASE_NAME> / <TABLE_NAME>):' -ForegroundColor Yellow
Write-Host ''
Write-Host '    You are a helpful agent that uses MCP tools to answer questions about the database.' -ForegroundColor Green
Write-Host '    "parameters": {' -ForegroundColor Green
Write-Host '        "database": "<DATABASE_NAME>",' -ForegroundColor Green
Write-Host "        ""resource-group"": ""$pgGroup""," -ForegroundColor Green
Write-Host "        ""server"": ""$pgServer""," -ForegroundColor Green
Write-Host "        ""subscription"": ""$subscriptionId""," -ForegroundColor Green
Write-Host '        "table": "<TABLE_NAME>",' -ForegroundColor Green
Write-Host "        ""user"": ""$identityName""" -ForegroundColor Green
Write-Host '    }' -ForegroundColor Green
Write-Host ''
Write-Host 'Tip: re-print this anytime with:  azd hooks run postprovision' -ForegroundColor DarkGray
Write-Host $bar -ForegroundColor Cyan
Write-Host ''
