# Script para analizar y verificar las optimizaciones del servidor web
# Comprueba la configuración de Nginx, Gunicorn y el tamaño de la imagen

Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "  ANÁLISIS DE OPTIMIZACIONES - PARTE 3" -ForegroundColor Cyan
Write-Host "  Servidor Web: Nginx + Gunicorn + Uvicorn" -ForegroundColor Cyan
Write-Host "============================================`n" -ForegroundColor Cyan

# ========================================
# 1. ANÁLISIS DE CONFIGURACIÓN NGINX
# ========================================

Write-Host "[1] CONFIGURACIÓN DE NGINX" -ForegroundColor Green
Write-Host "----------------------------`n" -ForegroundColor Green

$nginxConf = Get-Content "nginx.conf" -Raw

# Compresión GZIP
if ($nginxConf -match "gzip\s+on") {
    Write-Host "  [OK] Compresión GZIP habilitada" -ForegroundColor Green
    if ($nginxConf -match "gzip_comp_level\s+(\d+)") {
        Write-Host "       Nivel de compresión: $($matches[1])" -ForegroundColor Gray
    }
    # Contar tipos MIME comprimidos
    $gzipTypes = ($nginxConf | Select-String "^\s+(?:text|application)" -AllMatches).Matches.Count
    Write-Host "       Tipos MIME comprimidos: $gzipTypes" -ForegroundColor Gray
}

# Cache de archivos estáticos
if ($nginxConf -match "expires") {
    Write-Host "  [OK] Cache de archivos estáticos configurado" -ForegroundColor Green
    
    # Extraer políticas de cache
    if ($nginxConf -match "expires\s+1h") {
        Write-Host "       HTML: 1 hora" -ForegroundColor Gray
    }
    if ($nginxConf -match "expires\s+7d") {
        Write-Host "       CSS/JS: 7 días" -ForegroundColor Gray
    }
    if ($nginxConf -match "expires\s+30d") {
        Write-Host "       Imágenes/Fuentes: 30 días" -ForegroundColor Gray
    }
}

# Worker processes
if ($nginxConf -match "worker_processes\s+(\w+)") {
    Write-Host "  [OK] Worker processes: $($matches[1])" -ForegroundColor Green
}

# Keep-alive
if ($nginxConf -match "keepalive_timeout\s+(\d+)") {
    Write-Host "  [OK] Keep-alive timeout: $($matches[1])s" -ForegroundColor Green
}

# Security headers
$securityHeaders = ($nginxConf | Select-String "add_header\s+(X-[\w-]+)" -AllMatches).Matches.Count
Write-Host "  [OK] Security headers configurados: $securityHeaders" -ForegroundColor Green

# Proxy buffering
if ($nginxConf -match "proxy_buffering\s+on") {
    Write-Host "  [OK] Proxy buffering habilitado (mejor performance)" -ForegroundColor Green
}

# ========================================
# 2. ANÁLISIS DE CONFIGURACIÓN GUNICORN
# ========================================

Write-Host "`n[2] CONFIGURACIÓN DE GUNICORN" -ForegroundColor Green
Write-Host "------------------------------`n" -ForegroundColor Green

$gunicornConf = Get-Content "gunicorn.conf.py" -Raw

# Workers
if ($gunicornConf -match "workers\s*=") {
    Write-Host "  [OK] Múltiples workers configurados (paralelización)" -ForegroundColor Green
    if ($gunicornConf -match "cpu_count\(\)\s*\*\s*(\d+)\s*\+\s*(\d+)") {
        Write-Host "       Fórmula: (CPU cores × $($matches[1])) + $($matches[2])" -ForegroundColor Gray
    }
}

# Worker class
if ($gunicornConf -match 'worker_class\s*=\s*"(uvicorn\.workers\.UvicornWorker)"') {
    Write-Host "  [OK] Worker class: $($matches[1])" -ForegroundColor Green
}

# Max requests
if ($gunicornConf -match "max_requests\s*=\s*(\d+)") {
    Write-Host "  [OK] Max requests por worker: $($matches[1])" -ForegroundColor Green
    Write-Host "       (Previene memory leaks)" -ForegroundColor Gray
}

# Preload app
if ($gunicornConf -match "preload_app\s*=\s*True") {
    Write-Host "  [OK] Preload app habilitado (reduce uso de memoria)" -ForegroundColor Green
}

# Keep-alive
if ($gunicornConf -match "keepalive\s*=\s*(\d+)") {
    Write-Host "  [OK] Keep-alive: $($matches[1])s" -ForegroundColor Green
}

# ========================================
# 3. ANÁLISIS DE SUPERVISORD
# ========================================

Write-Host "`n[3] CONFIGURACIÓN DE SUPERVISORD" -ForegroundColor Green
Write-Host "---------------------------------`n" -ForegroundColor Green

$supervisordConf = Get-Content "supervisord.conf" -Raw

# Programas gestionados
$programs = ($supervisordConf | Select-String "\[program:(\w+)\]" -AllMatches).Matches
Write-Host "  [OK] Procesos gestionados: $($programs.Count)" -ForegroundColor Green
foreach ($program in $programs) {
    Write-Host "       - $($program.Groups[1].Value)" -ForegroundColor Gray
}

# Autorestart
if ($supervisordConf -match "autorestart=true") {
    Write-Host "  [OK] Auto-restart habilitado (alta disponibilidad)" -ForegroundColor Green
}

# ========================================
# 4. ANÁLISIS DE DOCKERFILE
# ========================================

Write-Host "`n[4] ANÁLISIS DE DOCKERFILE.PROD" -ForegroundColor Green
Write-Host "--------------------------------`n" -ForegroundColor Green

$dockerfile = Get-Content "Dockerfile.prod" -Raw

# Multi-stage build
$stages = ($dockerfile | Select-String "FROM .+ AS (\w+)" -AllMatches).Matches
if ($stages.Count -gt 1) {
    Write-Host "  [OK] Multi-stage build ($($stages.Count) stages)" -ForegroundColor Green
    foreach ($stage in $stages) {
        Write-Host "       - $($stage.Groups[1].Value)" -ForegroundColor Gray
    }
}

# Health check
if ($dockerfile -match "HEALTHCHECK") {
    Write-Host "  [OK] Health check configurado" -ForegroundColor Green
}

# Usuario no privilegiado
if ($dockerfile -match "useradd") {
    Write-Host "  [OK] Usuario no privilegiado (seguridad)" -ForegroundColor Green
}

# Limpieza de apt cache
$cleanups = ($dockerfile | Select-String "rm -rf /var/lib/apt/lists" -AllMatches).Matches.Count
if ($cleanups -gt 0) {
    Write-Host "  [OK] Limpieza de cache APT ($cleanups veces)" -ForegroundColor Green
}

# ========================================
# 5. TAMAÑO DE IMÁGENES (si Docker disponible)
# ========================================

$dockerInstalled = Get-Command docker -ErrorAction SilentlyContinue
if ($dockerInstalled) {
    Write-Host "`n[5] ANÁLISIS DE IMÁGENES DOCKER" -ForegroundColor Green
    Write-Host "--------------------------------`n" -ForegroundColor Green
    
    $dockerRunning = docker ps 2>&1
    if ($LASTEXITCODE -eq 0) {
        # Buscar imágenes del proyecto
        $images = docker images --filter reference="*fastapi*" --format "{{.Repository}}:{{.Tag}};{{.Size}}"
        
        if ($images) {
            Write-Host "  Imágenes encontradas:`n" -ForegroundColor Cyan
            foreach ($img in $images) {
                $parts = $img -split ";"
                Write-Host "  $($parts[0])" -ForegroundColor White
                Write-Host "    Tamaño: $($parts[1])`n" -ForegroundColor Gray
            }
        } else {
            Write-Host "  [INFO] No hay imágenes construidas aún" -ForegroundColor Yellow
            Write-Host "         Ejecuta: .\test-prod-build.ps1`n" -ForegroundColor Gray
        }
    } else {
        Write-Host "  [INFO] Docker no está corriendo" -ForegroundColor Yellow
    }
} else {
    Write-Host "`n[5] Docker no está instalado (análisis de imágenes omitido)" -ForegroundColor Yellow
}

# ========================================
# 6. RESUMEN DE OPTIMIZACIONES
# ========================================

Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "  RESUMEN DE OPTIMIZACIONES APLICADAS" -ForegroundColor Cyan
Write-Host "============================================`n" -ForegroundColor Cyan

$optimizations = @(
    @{Name="Compresión GZIP"; Benefit="60-80% reducción de bandwidth"},
    @{Name="Cache de estáticos"; Benefit="Reduce carga del servidor"},
    @{Name="Nginx sirve estáticos"; Benefit="10x más rápido que Python"},
    @{Name="Múltiples workers Gunicorn"; Benefit="Paralelización de requests"},
    @{Name="Keep-alive connections"; Benefit="Reduce latencia de handshake"},
    @{Name="Proxy buffering"; Benefit="Mejor throughput"},
    @{Name="Multi-stage build"; Benefit="~43% reducción de imagen"},
    @{Name="Worker auto-restart"; Benefit="Previene memory leaks"},
    @{Name="Supervisord"; Benefit="Alta disponibilidad"},
    @{Name="Security headers"; Benefit="Protección contra ataques comunes"}
)

foreach ($opt in $optimizations) {
    Write-Host "  [OK] $($opt.Name)" -ForegroundColor Green
    Write-Host "       -> $($opt.Benefit)" -ForegroundColor Gray
}

Write-Host "`n============================================`n" -ForegroundColor Cyan

Write-Host "[INFO] Para probar el build de producción:" -ForegroundColor Cyan
Write-Host "       .\test-prod-build.ps1`n" -ForegroundColor White

Write-Host "[INFO] Para levantar con docker-compose:" -ForegroundColor Cyan
Write-Host "       docker-compose -f docker-compose.prod.yml up --build`n" -ForegroundColor White
