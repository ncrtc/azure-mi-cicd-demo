param(
    [Parameter(Mandatory=$false)]
    [ValidateLength(5,128)]
    [string]$appName,
    [Parameter(Mandatory=$false)]
    [ValidatePattern('(\{|\()?[A-Za-z0-9]{4}([A-Za-z0-9]{4}\-?){4}[A-Za-z0-9]{12}(\}|\()?')]
    [string]$appId,
    [Parameter(Mandatory)]
    [ValidatePattern('(\{|\()?[A-Za-z0-9]{4}([A-Za-z0-9]{4}\-?){4}[A-Za-z0-9]{12}(\}|\()?')]
    [string]$clientId,
    [Parameter(Mandatory)]
    [ValidateLength(5,128)]
    [string]$clientSecret,
    [Parameter(Mandatory)]
    [ValidateLength(5,128)]
    [string]$sqlServerName,
    [Parameter(Mandatory)]
    [ValidateLength(5,128)]
    [string]$sqlDatabaseName,
    [Parameter(Mandatory)]
    [ValidatePattern('(\{|\()?[A-Za-z0-9]{4}([A-Za-z0-9]{4}\-?){4}[A-Za-z0-9]{12}(\}|\()?')]
    [string]$tenantId,
    [Parameter(Mandatory)]
    [string]$sqlFile
)
. $PSScriptRoot\helper-functions.ps1

Get-AccessToken -TenantID $tenantId -ServicePrincipalId $clientId -ServicePrincipalPwd $clientSecret `
    -OutVariable token -resourceAppIdURI 'https://database.windows.net/' | Out-null

Write-host "Got token $($token.Substring(0,10))..."
$sqlServerFQN = "$($sqlServerName).database.windows.net"
$conn = new-object System.Data.SqlClient.SqlConnection
$conn.ConnectionString = "Server=tcp:$($sqlServerFQN),1433;Initial Catalog=$($sqlDatabaseName);Persist Security Info=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;" 
$conn.AccessToken = $token

$stmt = Get-Content $sqlFile -Raw

if ($appId) {
    $sid = ConvertTo-Sid -appId $appId
    $stmt = $stmt.Replace('$sid', $sid)
}

if ($appName) {
    $stmt = $stmt.Replace('$appName', $appName)
}

Write-host "Connecting to database $($conn.ConnectionString)"
Write-SqlNonQuery -connection $conn -stmt $stmt | Out-Null 
$conn.Close()
