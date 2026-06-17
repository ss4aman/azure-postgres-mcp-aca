#!/usr/bin/env sh
# Printed automatically by `azd up` (postprovision hook).
# It tells you EXACTLY what to do next: nothing to figure out, just copy/paste.

container_app_url="${CONTAINER_APP_URL:-}"
identity_name="${CONTAINER_APP_IDENTITY_NAME:-}"
entra_client_id="${ENTRA_APP_CLIENT_ID:-}"
subscription_id="${AZURE_SUBSCRIPTION_ID:-}"
postgres_id="${POSTGRES_RESOURCE_ID:-}"

# Derive Postgres server name + resource group from its resource ID.
pg_server="<your-postgres-server>"
pg_group="<your-postgres-resource-group>"
if [ -n "$postgres_id" ]; then
  pg_group=$(printf '%s' "$postgres_id" | sed -n 's#.*/resourceGroups/\([^/]*\)/.*#\1#p')
  pg_server=$(printf '%s' "$postgres_id" | sed -n 's#.*/flexibleServers/\([^/]*\).*#\1#p')
  [ -z "$pg_group" ] && pg_group="<your-postgres-resource-group>"
  [ -z "$pg_server" ] && pg_server="<your-postgres-server>"
fi

bar="========================================================================"
echo ""
echo "$bar"
echo "  MCP SERVER DEPLOYED. TWO STEPS LEFT."
echo "$bar"
echo ""
echo "STEP 1 - Give the MCP server access to your database"
echo "  Connect to your Postgres server with psql (Entra ID auth), then run:"
echo ""
echo "    -- run this in the 'postgres' database:"
echo "    SELECT * FROM pgaadauth_create_principal('$identity_name', false, false);"
echo ""
echo "    -- run this in the database that holds your tables:"
echo "    GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"$identity_name\";"
echo "    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO \"$identity_name\";"
echo ""
echo "STEP 2 - Add the tool to your agent in the Foundry portal"
echo "  Tools -> Add -> Catalog -> \"Azure Database for PostgreSQL\" -> Create,"
echo "  then \"Connect tool with endpoint\" and paste these values:"
echo ""
echo "    Remote MCP Server endpoint : $container_app_url"
echo "    Authentication             : Microsoft Entra -> Project Managed Identity"
echo "    Audience                   : $entra_client_id"
echo ""
echo "  Then paste these agent instructions (fill in <DATABASE_NAME> / <TABLE_NAME>):"
echo ""
echo "    You are a helpful agent that uses MCP tools to answer questions about the database."
echo "    \"parameters\": {"
echo "        \"database\": \"<DATABASE_NAME>\","
echo "        \"resource-group\": \"$pg_group\","
echo "        \"server\": \"$pg_server\","
echo "        \"subscription\": \"$subscription_id\","
echo "        \"table\": \"<TABLE_NAME>\","
echo "        \"user\": \"$identity_name\""
echo "    }"
echo ""
echo "Tip: re-print this anytime with:  azd hooks run postprovision"
echo "$bar"
echo ""
