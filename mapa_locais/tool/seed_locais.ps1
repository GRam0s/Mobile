# Cadastra os locais iniciais (ou completa as coordenadas dos que já existem).
# As regras definitivas só deixam o administrador gravar, então o script publica
# regras temporárias, grava sem login pela API REST e republica firestore.rules.
param([string]$ProjectId = 'mapa-locais-4741')
$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot)
$env:Path += ";$env:APPDATA\npm"
$tmp = New-Item -ItemType Directory -Force "$env:TEMP\mapa_locais_seed"

@'
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /locais/{id} { allow read, create, update: if true; }
  }
}
'@ | Set-Content "$tmp\seed.rules" -Encoding ascii
'{"firestore": {"rules": "seed.rules"}}' | Set-Content "$tmp\firebase.json" -Encoding ascii

try {
  Write-Host '=== Regras temporarias ==='
  Push-Location $tmp
  firebase deploy --only firestore:rules --project $ProjectId
  Pop-Location
  if ($LASTEXITCODE) { throw 'Falha ao publicar regras temporarias' }
  Start-Sleep 10  # as regras levam alguns segundos para valer

  $apiKey = [regex]::Match((Get-Content lib\firebase_options.dart -Raw), "apiKey: '([^']+)'").Groups[1].Value
  $url = "https://firestore.googleapis.com/v1/projects/$ProjectId/databases/(default)/documents/locais"
  $existentes = @((Invoke-RestMethod "$url`?key=$apiKey&pageSize=300").documents)
  $locais = [IO.File]::ReadAllText("$PWD\tool\seed_locais.json", [Text.Encoding]::UTF8) | ConvertFrom-Json

  Write-Host '=== Locais ==='
  foreach ($l in $locais) {
    $doc = $existentes | Where-Object { $_.fields.nome.stringValue -eq $l.nome } | Select-Object -First 1
    $coords = @{ latitude = @{ doubleValue = [double]$l.latitude }; longitude = @{ doubleValue = [double]$l.longitude } }
    if ($doc) {
      $body = @{ fields = $coords } | ConvertTo-Json -Depth 5
      $mask = 'updateMask.fieldPaths=latitude&updateMask.fieldPaths=longitude'
      Invoke-RestMethod -Method Patch "https://firestore.googleapis.com/v1/$($doc.name)?key=$apiKey&$mask" -ContentType 'application/json; charset=utf-8' -Body ([Text.Encoding]::UTF8.GetBytes($body)) | Out-Null
      Write-Host "  ~ $($l.nome) (coordenadas)"
    } elseif ($existentes.Count -eq 0) {
      $campos = @{
        nome = @{ stringValue = $l.nome }; categoria = @{ stringValue = $l.categoria }
        cidade = @{ stringValue = $l.cidade }; horario = @{ stringValue = $l.horario }
        descricao = @{ stringValue = $l.descricao }; favorito = @{ booleanValue = $false }
        avaliacao = @{ doubleValue = [double]$l.avaliacao }; distancia = @{ doubleValue = [double]$l.distancia }
      } + $coords
      $body = @{ fields = $campos } | ConvertTo-Json -Depth 5
      Invoke-RestMethod -Method Post "$url`?key=$apiKey" -ContentType 'application/json; charset=utf-8' -Body ([Text.Encoding]::UTF8.GetBytes($body)) | Out-Null
      Write-Host "  + $($l.nome)"
    }
  }
}
finally {
  # Sempre volta às regras definitivas, mesmo se algo falhar acima.
  Write-Host '=== Regras definitivas ==='
  firebase deploy --only 'firestore' --project $ProjectId
  Remove-Item $tmp -Recurse -Force
}
Write-Host '=== Pronto ==='
