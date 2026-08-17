$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $Root
if (-not (Test-Path ".\android")) { .\setup.ps1 }
flutter pub get
flutter run
