$ErrorActionPreference = "Stop"
Write-Host "Cleaning Spendly Android build..." -ForegroundColor Cyan
flutter clean
if (Test-Path ".\android\.gradle") { Remove-Item ".\android\.gradle" -Recurse -Force }
Write-Host "Resolving packages..." -ForegroundColor Yellow
flutter pub get
Write-Host "Running analyzer..." -ForegroundColor Yellow
flutter analyze
Write-Host "Launching on connected Android device..." -ForegroundColor Green
flutter run
