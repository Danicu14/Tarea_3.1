# Script para probar la configuración de producción localmente
# Simula el entorno de Railway con Docker

Write-Host "`n[BUILD] Construyendo imagen de producción con Nginx..." -ForegroundColor Cyan

# Verificar si Docker está instalado
$dockerInstalled = Get-Command docker -ErrorAction SilentlyContinue
if (-not $dockerInstalled) {
    Write-Host "[ERROR] Docker no está instalado" -ForegroundColor Red
    Write-Host "Instala Docker Desktop desde: https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
    exit 1
}

# Verificar si Docker está corriendo
$dockerRunning = docker ps 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Docker no está corriendo" -ForegroundColor Red
    Write-Host "Inicia Docker Desktop primero" -ForegroundColor Yellow
    exit 1
}

# Construir imagen de producción
Write-Host "`n[DOCKER] Construyendo Dockerfile.prod..." -ForegroundColor Green
docker build -f Dockerfile.prod -t fastapi-nginx-prod:latest .

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n[OK] Imagen construida exitosamente" -ForegroundColor Green
    
    # Mostrar tamaño de la imagen
    Write-Host "`n[INFO] Tamaño de la imagen:" -ForegroundColor Cyan
    docker images fastapi-nginx-prod:latest --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
    
    Write-Host "`n[RUN] Iniciando contenedor de producción..." -ForegroundColor Cyan
    Write-Host "Puerto expuesto: http://localhost:8000" -ForegroundColor Yellow
    Write-Host "Presiona Ctrl+C para detener el contenedor`n" -ForegroundColor Yellow
    
    # Ejecutar contenedor
    docker run --rm -it `
        --name fastapi-nginx-test `
        -p 8000:8000 `
        -e ENVIRONMENT=production `
        -e DEBUG=False `
        -e GUNICORN_WORKERS=4 `
        fastapi-nginx-prod:latest
        
} else {
    Write-Host "`n[ERROR] Falló la construcción de la imagen" -ForegroundColor Red
    Write-Host "Revisa los errores arriba" -ForegroundColor Yellow
    exit 1
}
