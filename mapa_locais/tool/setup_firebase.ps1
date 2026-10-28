# Cria o projeto Firebase, o Firestore, conecta o app (FlutterFire), publica as regras e cadastra os locais iniciais.
param([string]$ProjectId = 'mapa-locais-4741')
$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot)
$env:Path += ";$env:APPDATA\npm;$env:LOCALAPPDATA\Pub\Cache\bin"

function Passo($t) { Write-Host "`n=== $t ===" -ForegroundColor Cyan }

Passo 'Projeto Firebase'
$existe = (firebase projects:list --json | ConvertFrom-Json).result | Where-Object projectId -eq $ProjectId
if (-not $existe) { firebase projects:create $ProjectId --display-name 'Mapa Locais'; if ($LASTEXITCODE) { throw 'Falha ao criar o projeto' } }

Passo 'FlutterFire configure'
if (-not (Get-Command flutterfire -ErrorAction SilentlyContinue)) { dart pub global activate flutterfire_cli }
flutterfire configure --project=$ProjectId --platforms=android,web --yes
if ($LASTEXITCODE) { throw 'Falha no flutterfire configure' }

Passo 'Banco Firestore'
$cfg = if (Test-Path firebase.json) { Get-Content firebase.json -Raw | ConvertFrom-Json } else { [pscustomobject]@{} }
$cfg | Add-Member -Force firestore ([pscustomobject]@{ rules = 'firestore.rules'; indexes = 'firestore.indexes.json' })
$cfg | Add-Member -Force auth ([pscustomobject]@{ providers = [pscustomobject]@{ emailPassword = $true } })
[IO.File]::WriteAllText("$PWD\firebase.json", ($cfg | ConvertTo-Json -Depth 20), (New-Object Text.UTF8Encoding $false))
$bancos = firebase firestore:databases:list --project $ProjectId 2>&1 | Out-String
if ($bancos -notmatch '\(default\)') {
  # Um projeto novo vem com a API do Firestore desligada; o deploy da CLI a ativa.
  $ErrorActionPreference = 'Continue'
  firebase deploy --only firestore:rules --project $ProjectId *> $null
  $ErrorActionPreference = 'Stop'
  foreach ($tentativa in 1..6) {
    firebase firestore:databases:create '(default)' --location southamerica-east1 --project $ProjectId
    if (-not $LASTEXITCODE) { break }
    if ($tentativa -eq 6) { throw 'Falha ao criar o Firestore' }
    Write-Host 'Aguardando a API do Firestore ativar...'; Start-Sleep 30
  }
}

Passo 'Login por e-mail (Authentication)'
firebase deploy --only auth --project $ProjectId
if ($LASTEXITCODE) { throw 'Falha ao ativar o login por e-mail' }

Passo 'Locais iniciais, regras e indices'
& "$PSScriptRoot\seed_locais.ps1" -ProjectId $ProjectId
Passo 'Pronto'
