# Script de Comparación: Producción vs Desarrollo

Write-Host "================================" -ForegroundColor Cyan
Write-Host "   Analisis de Dependencias" -ForegroundColor Green
Write-Host "   Produccion vs Desarrollo" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# Función para contar líneas en archivo
function Count-Dependencies {
    param($file)
    if (Test-Path $file) {
        $lines = Get-Content $file | Where-Object { 
            $_ -notmatch '^\s*#' -and $_ -notmatch '^\s*$' -and $_ -notmatch '^-r '
        }
        return $lines.Count
    }
    return 0
}

# Contar dependencias
$prodDeps = Count-Dependencies "requirements-prod.txt"
$devDeps = Count-Dependencies "requirements-dev.txt"

Write-Host "Dependencias Directas:" -ForegroundColor Cyan
Write-Host ""
Write-Host "   Produccion:  " -NoNewline -ForegroundColor White
Write-Host "$prodDeps paquetes" -ForegroundColor Green
Write-Host "   Desarrollo:  " -NoNewline -ForegroundColor White
Write-Host "$devDeps paquetes" -ForegroundColor Yellow
Write-Host ""

# Calcular ahorro
$ahorro = [math]::Round((1 - $prodDeps / $devDeps) * 100, 1)
Write-Host "   Reduccion: " -NoNewline -ForegroundColor White
Write-Host "$ahorro% menos dependencias en produccion" -ForegroundColor Green
Write-Host ""

# Mostrar dependencias de producción
Write-Host "[OK] Dependencias de PRODUCCION:" -ForegroundColor Green
Write-Host ""
Get-Content "requirements-prod.txt" | Where-Object { 
    $_ -notmatch '^\s*#' -and $_ -notmatch '^\s*$' 
} | ForEach-Object {
    if ($_ -notmatch '^-r ') {
        Write-Host "   - $_" -ForegroundColor Gray
    }
}
Write-Host ""

# Mostrar dependencias solo de desarrollo
Write-Host "[DEV] Dependencias ADICIONALES de Desarrollo:" -ForegroundColor Yellow
Write-Host ""
Get-Content "requirements-dev.txt" | Where-Object { 
    $_ -notmatch '^\s*#' -and $_ -notmatch '^\s*$' -and $_ -notmatch '^-r '
} | ForEach-Object {
    Write-Host "   - $_" -ForegroundColor Gray
}
Write-Host ""

# Análisis de tamaño si hay entorno virtual
if (Test-Path "venv") {
    Write-Host "Analisis de Tamano (entorno virtual):" -ForegroundColor Cyan
    Write-Host ""
    
    $venvSize = (Get-ChildItem -Path "venv" -Recurse -Force | 
        Measure-Object -Property Length -Sum).Sum
    $venvSizeMB = [math]::Round($venvSize / 1MB, 2)
    
    Write-Host "   Tamaño actual: $venvSizeMB MB" -ForegroundColor Gray
    Write-Host ""
}

# Comparar imágenes Docker si existen
Write-Host "[DOCKER] Analisis de Imagenes Docker:" -ForegroundColor Cyan
Write-Host ""

$prodImage = docker images fastapi-app:prod --format "{{.Size}}" 2>$null
$devImage = docker images fastapi-app:dev --format "{{.Size}}" 2>$null

if ($prodImage) {
    Write-Host "   Produccion:  $prodImage" -ForegroundColor Green
} else {
    Write-Host "   Produccion:  (no construida)" -ForegroundColor Gray
    Write-Host "   Ejecuta: docker build -t fastapi-app:prod ." -ForegroundColor Yellow
}

if ($devImage) {
    Write-Host "   Desarrollo:  $devImage" -ForegroundColor Yellow
} else {
    Write-Host "   Desarrollo:  (no construida)" -ForegroundColor Gray
    Write-Host "   Ejecuta: docker build -t fastapi-app:dev -f Dockerfile.dev ." -ForegroundColor Yellow
}

Write-Host ""

# Recomendaciones
Write-Host "Recomendaciones:" -ForegroundColor Cyan
Write-Host ""
Write-Host "   [OK] Usar requirements-prod.txt en produccion" -ForegroundColor Green
Write-Host "   [DEV] Usar requirements-dev.txt en desarrollo local" -ForegroundColor Yellow
Write-Host "   [DOCKER] Dockerfile usa requirements-prod.txt automaticamente" -ForegroundColor Green
Write-Host "   [BUILD] Dockerfile.dev usa requirements-dev.txt" -ForegroundColor Yellow
Write-Host ""

# Verificar paquetes desactualizados (si venv existe)
if (Test-Path "venv/Scripts/python.exe") {
    Write-Host "Verificando actualizaciones disponibles..." -ForegroundColor Cyan
    Write-Host ""
    
    & venv/Scripts/python.exe -m pip list --outdated --format=columns 2>$null | Select-Object -First 10
    
    Write-Host ""
    Write-Host "   Para actualizar: pip install --upgrade <paquete>" -ForegroundColor Gray
}

Write-Host ""
Write-Host "================================" -ForegroundColor Cyan
Write-Host "   Analisis Completado" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Cyan
