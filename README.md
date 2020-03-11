# azure-mi-cicd-demo

## Prerequisites

1. Create an Azure AD Group for SQL Admins
2. Add the Graph API "Directory.Read.All" to the Azure DevOps Service Principal
3. Add the Azure DevOps Service Principal to the AAD "SQL ADMIN" group

#TODO: add notes about how to do/gather these things

#TODO: add notes about adding the graph permission. NB: This must be done with the v1 Azure Active Directory Graph, not the Microsoft Graph!

#TODO: create script to delete the user from the DB upon recreation

## Builds

Each service has a corresponding build YAML file in its folder. Please refer to those folders for specific README instructions. 

## Database Deployment Pipeline (i.e., Release)

### General

When creating this release, start with an empty job. Select your artificate from the Shared Service build.  

### Step 1 - Azure Resource Group Deployment task

- Authorize the task to your subscription with the service principal that you added to the "SQL Admin" group.
- Provide a resource group name (new or existing) and location for where these resources will be deployed.

- Template: $(System.DefaultWorkingDirectory)/_Build/Infrastructure/sql.json
- Paramaters: -server_name_prefix "micicddbsrv" -database_name "def_db" -encryptionProtector_current_name "current" -firewallRules_AllowAllWindowsAzureIps_name "AllowAllWindowsAzureIps" -transparentDataEncryption_current_name "current" -aadAdminLogin "<AAD-SQL-ADMINS-GROUP>" -aadAdminOid "<AAD-SQL-ADMINS-GROUP-ID>" -db_admin_login <user> -db_admin_pass <password>
#TODO
  add information around how to get the object id
  
## App Deployment Pipeline (i.e., Release)

### General

When creating this release, start with an empty job. Select your artificate from the App build.  

### Varaiables

- ado-az-sp-client-id (GUID)
- ado-az-sp-client-secret (secret from the app registration)
- app-name (eg: demo-mi-app)
- app-storage-account-name (eg: micicddbsrv2ugmgwdemg5t6)
- sql-server-name (eg: micicddbsrv2ugmgwdemg5t6)
- tenant-id (eg: 2e433d32-9cb5-4258-926b-1253c4de44dc)

#TODO: show how to get tenant ID, ado client id, and secret

#TODO: clarify which of these you are defining and which ones you need to pull

### Step 1 - Resource Group Deployment

- Template: $(System.DefaultWorkingDirectory)/_Build/Infrastructure/function-app-consumption.json
- Parameters: -appName $(app-name) -storageAccountName $(app-storage-account-name)

### Step 2 - Get MI Application Id

- Type: Azure Powershell
- Script Path: $(System.DefaultWorkingDirectory)/_Build/Infrastructure/find-applicationid.ps1
- Script Arguments: -appName $(app-name)
- Version: Latest Installed

#TODO: Rename function to PowerShell standard cmdlet verbs

### Step 3 - Assign DB Permission

- Type: Powershell
- Script Path: $(System.DefaultWorkingDirectory)/_Build/Infrastructure/assign-db-permission.ps1
- Script Arguments: -appName $(app-name) -appId $(appId) -clientId $(ado-az-sp-client-id) -clientSecret $(ado-az-sp-client-secret) -sqlServerName $(sql-server-name) -sqlDatabaseName def_db -tenantId $(tenant-id)

#TODO: Rename function to PowerShell standard cmdlet verbs

### Step 4 - Deploy App

- Type: Azure App Service deploy
- App Service name: $(app-name)
- Package or folder: $(System.DefaultWorkingDirectory)/_Build/App/FunctionApi.zip
- App settings: -SQLDataSource $(sql-server-name).database.windows.net
