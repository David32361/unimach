param([string]$ProjectId = 'unimatch-daniel-2026', [switch]$Apply)

$ErrorActionPreference = 'Stop'
$configPath = Join-Path $env:USERPROFILE '.config\configstore\firebase-tools.json'
if (-not (Test-Path -LiteralPath $configPath)) {
  throw 'Inicia sesión con firebase login antes de configurar la política.'
}
$session = Get-Content -LiteralPath $configPath | ConvertFrom-Json
$headers = @{ Authorization = "Bearer $($session.tokens.access_token)" }
$uri = "https://identitytoolkit.googleapis.com/admin/v2/projects/$ProjectId/config"
try {
  if ($Apply) {
    $policy = @{
      passwordPolicyConfig = @{
        passwordPolicyEnforcementState = 'ENFORCE'
        forceUpgradeOnSignin = $false
        passwordPolicyVersions = @(@{
          customStrengthOptions = @{
            minPasswordLength = 8
            maxPasswordLength = 128
            containsUppercaseCharacter = $true
            containsLowercaseCharacter = $true
            containsNumericCharacter = $true
            containsNonAlphanumericCharacter = $true
          }
        })
      }
    } | ConvertTo-Json -Depth 8
    Invoke-RestMethod -Method Patch -Uri "$uri`?updateMask=passwordPolicyConfig" -Headers $headers -ContentType 'application/json' -Body $policy -TimeoutSec 30 | Out-Null
  }
  $config = Invoke-RestMethod -Method Get -Uri $uri -Headers $headers -TimeoutSec 30
  # Never print OAuth tokens or unrelated project configuration.
  $config.passwordPolicyConfig | ConvertTo-Json -Depth 8
} catch {
  throw 'No se pudo consultar/aplicar la política. Revisa la sesión (firebase login --reauth) y los permisos del proyecto. No se imprimen credenciales.'
}
