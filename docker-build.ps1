# 🐳 Script de Construcción y Prueba de Docker

Write-Host "================================" -ForegroundColor Cyan
Write-Host "   Docker Build & Test Script" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# Verificar que Docker está instalado
try {
    docker --version | Out-Null
} catch {
    Write-Host "❌ Docker no está instalado o no está en el PATH" -ForegroundColor Red
    Write-Host "Por favor instala Docker Desktop desde: https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Docker encontrado" -ForegroundColor Green
Write-Host ""

# Limpiar contenedores anteriores si existen
Write-Host "🧹 Limpiando contenedores anteriores..." -ForegroundColor Yellow
docker stop fastapi-container 2>$null
docker rm fastapi-container 2>$null
Write-Host "✅ Limpieza completada" -ForegroundColor Green
Write-Host ""

# Construir imagen de PRODUCCIÓN
Write-Host "📦 Construyendo imagen de PRODUCCIÓN..." -ForegroundColor Cyan
Write-Host "   (Esto puede tardar 1-2 minutos la primera vez)" -ForegroundColor Gray
$buildStart = Get-Date
docker build -t fastapi-app:prod -f Dockerfile .
$buildEnd = Get-Date
$buildTime = ($buildEnd - $buildStart).TotalSeconds

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Imagen construida exitosamente en $([math]::Round($buildTime, 2)) segundos" -ForegroundColor Green
} else {
    Write-Host "❌ Error al construir la imagen" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Mostrar tamaño de la imagen
Write-Host "📊 Información de la imagen:" -ForegroundColor Cyan
docker images fastapi-app:prod --format "   Tamaño: {{.Size}}"
docker images fastapi-app:prod --format "   Creada: {{.CreatedSince}}"
Write-Host ""

# Ejecutar contenedor
Write-Host "🚀 Iniciando contenedor..." -ForegroundColor Cyan
docker run -d -p 8000:8000 `
  -e ENVIRONMENT=production `
  -e DEBUG=False `
  --name fastapi-container `
  fastapi-app:prod

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Contenedor iniciado" -ForegroundColor Green
} else {
    Write-Host "❌ Error al iniciar contenedor" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Esperar a que el servidor esté listo
Write-Host "⏳ Esperando a que el servidor esté listo..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# Probar endpoints
Write-Host "🧪 Probando endpoints..." -ForegroundColor Cyan
Write-Host ""

# Test 1: Health check
Write-Host "   1️⃣  Health Check:" -ForegroundColor White
try {
    $health = Invoke-RestMethod -Uri "http://localhost:8000/health"
    Write-Host "      ✅ Status: $($health.status)" -ForegroundColor Green
    Write-Host "      📍 Environment: $($health.environment)" -ForegroundColor Gray
    Write-Host "      📦 Version: $($health.version)" -ForegroundColor Gray
} catch {
    Write-Host "      ❌ Health check falló" -ForegroundColor Red
}

Write-Host ""

# Test 2: API Info
Write-Host "   2️⃣  API Info:" -ForegroundColor White
try {
    $info = Invoke-RestMethod -Uri "http://localhost:8000/api/info"
    Write-Host "      ✅ Name: $($info.name)" -ForegroundColor Green
    Write-Host "      📦 Version: $($info.version)" -ForegroundColor Gray
} catch {
    Write-Host "      ❌ API info falló" -ForegroundColor Red
}

Write-Host ""

# Test 3: Items
Write-Host "   3️⃣  Items Endpoint:" -ForegroundColor White
try {
    $items = Invoke-RestMethod -Uri "http://localhost:8000/api/items"
    $itemCount = $items.items.Count
    Write-Host "      ✅ Items obtenidos: $itemCount" -ForegroundColor Green
} catch {
    Write-Host "      ❌ Items endpoint falló" -ForegroundColor Red
}

Write-Host ""
Write-Host "================================" -ForegroundColor Cyan
Write-Host "   ✅ Docker Build Completado" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# Mostrar información útil
Write-Host "📍 URLs Disponibles:" -ForegroundColor White
Write-Host "   🌐 Cliente: http://localhost:8000/static/index.html" -ForegroundColor Cyan
Write-Host "   💚 Health: http://localhost:8000/health" -ForegroundColor Cyan
Write-Host "   📡 API Info: http://localhost:8000/api/info" -ForegroundColor Cyan
Write-Host ""

Write-Host "🐳 Comandos útiles:" -ForegroundColor White
Write-Host "   Ver logs:     docker logs -f fastapi-container" -ForegroundColor Gray
Write-Host "   Detener:      docker stop fastapi-container" -ForegroundColor Gray
Write-Host "   Reiniciar:    docker restart fastapi-container" -ForegroundColor Gray
Write-Host "   Eliminar:     docker rm -f fastapi-container" -ForegroundColor Gray
Write-Host ""

Write-Host "⚠️  Para detener el contenedor, ejecuta:" -ForegroundColor Yellow
Write-Host "   docker stop fastapi-container" -ForegroundColor White
Write-Host ""
