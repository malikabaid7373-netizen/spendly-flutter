$ErrorActionPreference = "Stop"
Write-Host "Spendly setup" -ForegroundColor Cyan

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
  throw "Flutter was not found in PATH. Install Flutter or add it to PATH first."
}

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $Root
$Temp = Join-Path $Root "_spendly_platform_scaffold"

if ((-not (Test-Path (Join-Path $Root "android"))) -or (-not (Test-Path (Join-Path $Root "ios")))) {
  if (Test-Path $Temp) { Remove-Item $Temp -Recurse -Force }
  Write-Host "Generating current Flutter Android/iOS wrappers..." -ForegroundColor Yellow
  flutter create --project-name spendly --org com.malikabaid.portfolio --platforms=android,ios $Temp

  if (-not (Test-Path (Join-Path $Root "android"))) { Copy-Item (Join-Path $Temp "android") (Join-Path $Root "android") -Recurse }
  if (-not (Test-Path (Join-Path $Root "ios"))) { Copy-Item (Join-Path $Temp "ios") (Join-Path $Root "ios") -Recurse }
  if (Test-Path (Join-Path $Temp ".metadata")) { Copy-Item (Join-Path $Temp ".metadata") (Join-Path $Root ".metadata") -Force }
  Remove-Item $Temp -Recurse -Force
}

Write-Host "Getting packages..." -ForegroundColor Yellow
flutter pub get
Write-Host "Running analyzer..." -ForegroundColor Yellow
flutter analyze
Write-Host "Setup complete. Run: flutter run" -ForegroundColor Green
