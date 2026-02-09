# Script para probar dependencias de PRODUCCIÓN

Write-Host "================================" -ForegroundColor Cyan
Write-Host "   Test: Dependencias de Produccion" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "[INFO] Este script creara un entorno virtual temporal" -ForegroundColor Cyan
Write-Host "       para probar SOLO las dependencias de produccion" -ForegroundColor Cyan
Write-Host ""

# Crear entorno temporal
$tempVenv = "venv-prod-test"

if (Test-Path $tempVenv) {
    Write-Host "[CLEAN] Eliminando entorno temporal anterior..." -ForegroundColor Yellow
    Remove-Item -Recurse -Force $tempVenv
}

Write-Host "[CREATE] Creando entorno virtual temporal..." -ForegroundColor Cyan
python -m venv $tempVenv

if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] No se pudo crear el entorno virtual" -ForegroundColor Red
    exit 1
}

Write-Host "[OK] Entorno virtual creado" -ForegroundColor Green
Write-Host ""

# Instalar dependencias de producción
Write-Host "[INSTALL] Instalando dependencias de PRODUCCION..." -ForegroundColor Cyan
Write-Host "            (esto puede tardar 20-30 segundos)" -ForegroundColor Gray
Write-Host ""

$installStart = Get-Date
& "$tempVenv\Scripts\pip.exe" install --quiet -r requirements-prod.txt
$installEnd = Get-Date
$installTime = ($installEnd - $installStart).TotalSeconds

if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] Instalacion completada en $([math]::Round($installTime, 2)) segundos" -ForegroundColor Green
} else {
    Write-Host "[ERROR] Fallo la instalacion" -ForegroundColor Red
    Remove-Item -Recurse -Force $tempVenv
    exit 1
}

Write-Host ""

# Contar paquetes instalados
Write-Host "[ANALYZE] Analizando paquetes instalados..." -ForegroundColor Cyan
$packages = & "$tempVenv\Scripts\pip.exe" list --format=columns
$packageCount = ($packages | Measure-Object -Line).Lines - 2  # -2 por el header

Write-Host "[RESULT] Paquetes instalados: $packageCount" -ForegroundColor Green
Write-Host ""

# Mostrar tamaño
$venvSize = (Get-ChildItem -Path $tempVenv -Recurse -Force | 
    Measure-Object -Property Length -Sum).Sum
$venvSizeMB = [math]::Round($venvSize / 1MB, 2)

Write-Host "[RESULT] Tamano del entorno: $venvSizeMB MB" -ForegroundColor Green
Write-Host ""

# Comparar con entorno actual
if (Test-Path "venv") {
    $currentSize = (Get-ChildItem -Path "venv" -Recurse -Force | 
        Measure-Object -Property Length -Sum).Sum
    $currentSizeMB = [math]::Round($currentSize / 1MB, 2)
    $currentPackages = (& "venv\Scripts\pip.exe" list --format=columns | Measure-Object -Line).Lines - 2
    
    Write-Host "================================" -ForegroundColor Cyan
    Write-Host "   Comparativa" -ForegroundColor White
    Write-Host "================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Entorno ACTUAL (dev):" -ForegroundColor Yellow
    Write-Host "  Paquetes: $currentPackages" -ForegroundColor Gray
    Write-Host "  Tamano: $currentSizeMB MB" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Entorno PRODUCCION:" -ForegroundColor Green
    Write-Host "  Paquetes: $packageCount" -ForegroundColor Gray
    Write-Host "  Tamano: $venvSizeMB MB" -ForegroundColor Gray
    Write-Host ""
    
    $pkgDiff = $currentPackages - $packageCount
    $sizeDiff = $currentSizeMB - $venvSizeMB
    $pkgPercent = [math]::Round(($pkgDiff / $currentPackages) * 100, 1)
    $sizePercent = [math]::Round(($sizeDiff / $currentSizeMB) * 100, 1)
    
    Write-Host "Reduccion en PRODUCCION:" -ForegroundColor Cyan
    Write-Host "  Paquetes: -$pkgDiff ($pkgPercent%)" -ForegroundColor Green
    Write-Host "  Tamano: -$sizeDiff MB ($sizePercent%)" -ForegroundColor Green
    Write-Host ""
}

# Verificar que FastAPI funciona
Write-Host "[TEST] Verificando que FastAPI funciona..." -ForegroundColor Cyan
$testResult = & "$tempVenv\Scripts\python.exe" -c "import fastapi; import uvicorn; print('OK')" 2>&1

if ($testResult -eq "OK") {
    Write-Host "[OK] FastAPI y Uvicorn funcionan correctamente" -ForegroundColor Green
} else {
    Write-Host "[ERROR] Problema al importar FastAPI" -ForegroundColor Red
}

Write-Host ""

# Limpiar
Write-Host "[CLEAN] Limpiando entorno temporal..." -ForegroundColor Yellow
Remove-Item -Recurse -Force $tempVenv
Write-Host "[OK] Entorno temporal eliminado" -ForegroundColor Green

Write-Host ""
Write-Host "================================" -ForegroundColor Cyan
Write-Host "   Test Completado" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "[INFO] El entorno de PRODUCCION tiene solo lo necesario" -ForegroundColor Cyan
Write-Host "       para ejecutar la aplicacion FastAPI" -ForegroundColor Cyan
Write-Host ""
