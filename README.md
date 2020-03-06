# azure-mi-cicd-demo

## Prerequisites

1. Create a AAD for SQL Admins
2. Add the ADO SP to AAD "SQL ADMIN" group

## Database Deployment Pipeline

### Step 1 - Resource Group Deployment

Template: $(System.DefaultWorkingDirectory)/_Build/Infrastructure/sql.json
Paramaters: -server_name_prefix "micicddbsrv" -database_name "def_db" -encryptionProtector_current_name "current" -firewallRules_AllowAllWindowsAzureIps_name "AllowAllWindowsAzureIps" -transparentDataEncryption_current_name "current" -aadAdminLogin "<AAD-SQL-ADMINS-GROUP>" -aadAdminOid "<AAD-SQL-ADMINS-GROUP-ID>" -db_admin_login <user> -db_admin_pass <password>

## App Deployment Pipeline

### Varaiables

- ado-az-sp-client-id
- ado-az-sp-client-secret
- app-name (eg: demo-mi-app)
- app-storage-account-name (eg: micicddbsrv2ugmgwdemg5t6)
- sql-server-name (eg: micicddbsrv2ugmgwdemg5t6)
- tenant-id (eg: 2e433d32-9cb5-4258-926b-1253c4de44dc)

### Step 1 - Resource Group Deployment

Template: $(System.DefaultWorkingDirectory)/_Build/Infrastructure/function-app-consumption.json
Parameters: -appName $(app-name) -storageAccountName $(app-storage-account-name)

### Step 2 - Get MI Application Id

Type: Azure Powershell
Script Path: $(System.DefaultWorkingDirectory)/_Build/Infrastructure/find-applicationid.ps1
Script Arguments: -appName $(app-name)

### Step 3 - Assign DB Premission

Type: Powershell
Script Path: $(System.DefaultWorkingDirectory)/_Build/Infrastructure/assign-db-permission.ps1
Script Arguments: -appName $(app-name) -appId $(appId) -clientId $(ado-az-sp-client-id) -clientSecret $(ado-az-sp-client-secret) -sqlServerName $(sql-server-name) -sqlDatabaseName def_db -tenantId $(tenant-id)

### Step 4 - Deploy App

Type: Azure App Service deploy
App Service name: $(app-name)
Package or folder: $(System.DefaultWorkingDirectory)/_Build/App/FunctionApi.zip
App settings: -SQLDataSource $(sql-server-name).database.windows.net