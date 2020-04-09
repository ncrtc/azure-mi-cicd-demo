param(
    [Parameter(Mandatory)]
    $appName
)
$servicePrincipal = Get-AzADServicePrincipal  -SearchString $appName
$appId = $servicePrincipal.ApplicationId

Write-Output "Application id for application with name $appName is $appId"
Write-Output ("##vso[task.setvariable variable=appId;]$appId")