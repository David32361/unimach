param(
  [Parameter(Mandatory = $true)]
  [string]$Email,

  [switch]$Remove
)

$ErrorActionPreference = 'Stop'
$projectId = 'unimatch-daniel-2026'
$firebaseConfig = Join-Path $env:USERPROFILE '.config\configstore\firebase-tools.json'

if (-not (Test-Path -LiteralPath $firebaseConfig)) {
  throw 'Inicia sesion primero con: firebase login'
}

$accessToken = (Get-Content -LiteralPath $firebaseConfig | ConvertFrom-Json).tokens.access_token
$headers = @{ Authorization = "Bearer $accessToken" }
$lookupBody = @{ email = @($Email.Trim().ToLowerInvariant()) } | ConvertTo-Json
$baseUrl = "https://identitytoolkit.googleapis.com/v1/projects/$projectId/accounts"
$lookup = Invoke-RestMethod -Method Post -Uri "$baseUrl`:lookup" -Headers $headers -ContentType 'application/json' -Body $lookupBody

if ($null -eq $lookup.users -or $lookup.users.Count -ne 1) {
  throw "No se encontro exactamente una cuenta para $Email."
}

$user = $lookup.users[0]
$claims = @{}
if (-not [string]::IsNullOrWhiteSpace($user.customAttributes)) {
  $existing = $user.customAttributes | ConvertFrom-Json
  $existing.PSObject.Properties | ForEach-Object { $claims[$_.Name] = $_.Value }
}

if ($Remove) {
  $claims.Remove('admin')
} else {
  $claims['admin'] = $true
}

$updateBody = @{
  localId = $user.localId
  customAttributes = ($claims | ConvertTo-Json -Compress)
} | ConvertTo-Json

Invoke-RestMethod -Method Post -Uri "$baseUrl`:update" -Headers $headers -ContentType 'application/json' -Body $updateBody | Out-Null
$action = if ($Remove) { 'revocado' } else { 'concedido' }
Write-Output "Permiso de administrador $action para $($user.email)."
Write-Output 'La cuenta debe cerrar sesion y volver a entrar para renovar su token.'
