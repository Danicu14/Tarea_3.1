# Generador de secretos para producción

Write-Host "Generando secretos seguros..." -ForegroundColor Cyan
Write-Host ""

# SECRET_KEY
Write-Host "SECRET_KEY (64 caracteres):" -ForegroundColor Yellow
$secretKey = -join ((65..90) + (97..122) + (48..57) + @(45,95) | Get-Random -Count 64 | ForEach-Object {[char]$_})
Write-Host "SECRET_KEY=$secretKey" -ForegroundColor Green
Write-Host ""

# Database Password
Write-Host "Database Password (32 caracteres):" -ForegroundColor Yellow
$dbPassword = -join ((65..90) + (97..122) + (48..57) + @(33,35,36,37,38,42,43,45,61,63,64) | Get-Random -Count 32 | ForEach-Object {[char]$_})
Write-Host "DATABASE_PASSWORD=$dbPassword" -ForegroundColor Green
Write-Host ""

# API Key
Write-Host "API Key (UUID):" -ForegroundColor Yellow
$apiKey = [guid]::NewGuid().ToString()
Write-Host "API_KEY=$apiKey" -ForegroundColor Green
Write-Host ""

# JWT Secret
Write-Host "JWT Secret (base64):" -ForegroundColor Yellow
$jwtSecret = [Convert]::ToBase64String([System.Security.Cryptography.RandomNumberGenerator]::GetBytes(48))
Write-Host "JWT_SECRET=$jwtSecret" -ForegroundColor Green
Write-Host ""

Write-Host "Copiar estos valores a .env o variables de entorno de Railway" -ForegroundColor Cyan
