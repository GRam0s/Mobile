# Instala cmdline-tools e uma imagem de sistema do Android e cria o emulador "mapa_locais".
$ErrorActionPreference = 'Stop'
$sdk = "$env:LOCALAPPDATA\Android\Sdk"
$env:JAVA_HOME = 'C:\Program Files\Android\Android Studio\jbr'
$env:ANDROID_HOME = $sdk
$imagem = 'system-images;android-36;google_apis;x86_64'
[Environment]::SetEnvironmentVariable('JAVA_HOME', $env:JAVA_HOME, 'User')
[Environment]::SetEnvironmentVariable('ANDROID_HOME', $sdk, 'User')

$bin = "$sdk\cmdline-tools\latest\bin"
if (-not (Test-Path "$bin\sdkmanager.bat")) {
  Write-Host 'Baixando cmdline-tools...'
  $zip = "$env:TEMP\cmdline-tools.zip"
  Invoke-WebRequest 'https://dl.google.com/android/repository/commandlinetools-win-13114758_latest.zip' -OutFile $zip
  Expand-Archive $zip "$env:TEMP\cmdline-tools-x" -Force
  New-Item -ItemType Directory -Force "$sdk\cmdline-tools" | Out-Null
  Move-Item "$env:TEMP\cmdline-tools-x\cmdline-tools" "$sdk\cmdline-tools\latest"
  Remove-Item $zip, "$env:TEMP\cmdline-tools-x" -Recurse -Force
}

Write-Host 'Aceitando licencas e instalando pacotes (download grande)...'
$ErrorActionPreference = 'Continue'
(1..30 | ForEach-Object { 'y' }) | & "$bin\sdkmanager.bat" --licenses | Out-Null
& "$bin\sdkmanager.bat" 'platform-tools' 'emulator' 'platforms;android-36' $imagem
if ($LASTEXITCODE) { throw 'Falha no sdkmanager' }

if (-not ((& "$sdk\emulator\emulator.exe" -list-avds) -contains 'mapa_locais')) {
  'no' | & "$bin\avdmanager.bat" create avd -n mapa_locais -k $imagem -d pixel_7
  if ($LASTEXITCODE) { throw 'Falha ao criar o emulador' }
}
flutter doctor --android-licenses *> $null
Write-Host '=== Android pronto ==='
