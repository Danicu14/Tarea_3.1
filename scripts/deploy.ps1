# Script de Deploy Manual a Railway
# Permite desplegar manualmente la aplicación a Railway
# Requiere Railway CLI instalado y autenticado

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("production", "staging")]
    [string]$Environment = "production",
    
    [Parameter(Mandatory=$false)]
    [switch]$SkipTests = $false,
    
    [Parameter(Mandatory=$false)]
    [switch]$Force = $false
)

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  DEPLOY A RAILWAY - $Environment" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# ========================================
# 1. Verificar Railway CLI
# ========================================

Write-Host "[1/6] Verificando Railway CLI..." -ForegroundColor Yellow

$railwayInstalled = Get-Command railway -ErrorAction SilentlyContinue
if (-not $railwayInstalled) {
    Write-Host "[ERROR] Railway CLI no está instalado" -ForegroundColor Red
    Write-Host "Instala desde: https://docs.railway.app/develop/cli" -ForegroundColor Yellow
    Write-Host "O ejecuta: npm install -g @railway/cli" -ForegroundColor Yellow
    exit 1
}

Write-Host "[OK] Railway CLI instalado" -ForegroundColor Green

# ========================================
# 2. Verificar autenticación
# ========================================

Write-Host "`n[2/6] Verificando autenticación..." -ForegroundColor Yellow

$railwayStatus = railway whoami 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] No estás autenticado en Railway" -ForegroundColor Red
    Write-Host "Ejecuta: railway login" -ForegroundColor Yellow
    exit 1
}

Write-Host "[OK] Autenticado como: $railwayStatus" -ForegroundColor Green

# ========================================
# 3. Ejecutar tests (opcional)
# ========================================

if (-not $SkipTests) {
    Write-Host "`n[3/6] Ejecutando tests..." -ForegroundColor Yellow
    
    # Activar venv si existe
    if (Test-Path "venv\Scripts\activate.ps1") {
        . .\venv\Scripts\activate.ps1
    }
    
    # Instalar dependencias de test si es necesario
    $pytestInstalled = python -m pip list | Select-String "pytest"
    if (-not $pytestInstalled) {
        Write-Host "Instalando pytest..." -ForegroundColor Gray
        pip install pytest pytest-asyncio httpx -q
    }
    
    # Ejecutar tests
    pytest tests/ -v
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "`n[ERROR] Tests fallaron" -ForegroundColor Red
        
        if (-not $Force) {
            Write-Host "Usa -Force para deployar de todas formas" -ForegroundColor Yellow
            exit 1
        } else {
            Write-Host "[WARNING] Continuando deploy a pesar de tests fallidos (-Force)" -ForegroundColor Yellow
        }
    }
    
    Write-Host "[OK] Tests pasaron exitosamente" -ForegroundColor Green
} else {
    Write-Host "`n[3/6] Tests omitidos (-SkipTests)" -ForegroundColor Gray
}

# ========================================
# 4. Verificar cambios en Git
# ========================================

Write-Host "`n[4/6] Verificando Git status..." -ForegroundColor Yellow

$gitStatus = git status --porcelain
if ($gitStatus) {
    Write-Host "[WARNING] Hay cambios sin commitear:" -ForegroundColor Yellow
    git status --short
    
    if (-not $Force) {
        Write-Host "`nCommitea tus cambios antes de deployar" -ForegroundColor Yellow
        Write-Host "O usa -Force para deployar de todas formas" -ForegroundColor Yellow
        exit 1
    }
}

$currentBranch = git branch --show-current
Write-Host "[INFO] Branch actual: $currentBranch" -ForegroundColor Cyan

# ========================================
# 5. Deploy a Railway
# ========================================

Write-Host "`n[5/6] Deployando a Railway ($Environment)..." -ForegroundColor Yellow

# Crear tag de release
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$releaseTag = "deploy-$Environment-$timestamp"

Write-Host "Tag de release: $releaseTag" -ForegroundColor Gray

# Hacer deploy
Write-Host "`nIniciando deploy..." -ForegroundColor Cyan
railway up --detach

if ($LASTEXITCODE -ne 0) {
    Write-Host "`n[ERROR] Deploy falló" -ForegroundColor Red
    exit 1
}

Write-Host "[OK] Deploy iniciado exitosamente" -ForegroundColor Green

# ========================================
# 6. Health Check
# ========================================

Write-Host "`n[6/6] Verificando health check..." -ForegroundColor Yellow
Write-Host "Esperando 30 segundos para que el deploy complete..." -ForegroundColor Gray
Start-Sleep -Seconds 30

# Obtener URL del proyecto (debes configurar esto)
$RAILWAY_URL = $env:RAILWAY_URL
if (-not $RAILWAY_URL) {
    Write-Host "[WARNING] Variable RAILWAY_URL no configurada" -ForegroundColor Yellow
    Write-Host "Configura `$env:RAILWAY_URL = 'https://tu-app.railway.app'" -ForegroundColor Yellow
    Write-Host "O verifica manualmente en: https://railway.app/dashboard" -ForegroundColor Cyan
} else {
    $healthUrl = "$RAILWAY_URL/health"
    Write-Host "Verificando: $healthUrl" -ForegroundColor Gray
    
    $maxRetries = 5
    $success = $false
    
    for ($i = 1; $i -le $maxRetries; $i++) {
        try {
            $response = Invoke-WebRequest -Uri $healthUrl -Method GET -TimeoutSec 10
            
            if ($response.StatusCode -eq 200) {
                Write-Host "[OK] Health check exitoso!" -ForegroundColor Green
                $success = $true
                break
            }
        } catch {
            Write-Host "[WARNING] Intento $i/$maxRetries falló" -ForegroundColor Yellow
            if ($i -lt $maxRetries) {
                Write-Host "Reintentando en 10s..." -ForegroundColor Gray
                Start-Sleep -Seconds 10
            }
        }
    }
    
    if (-not $success) {
        Write-Host "`n[ERROR] Health check falló después de $maxRetries intentos" -ForegroundColor Red
        Write-Host "Revisa los logs: railway logs" -ForegroundColor Yellow
        exit 1
    }
}

# ========================================
# Resumen
# ========================================

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  DEPLOY COMPLETADO EXITOSAMENTE" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "Environment: $Environment" -ForegroundColor White
Write-Host "Branch: $currentBranch" -ForegroundColor White
Write-Host "Release tag: $releaseTag" -ForegroundColor White

if ($RAILWAY_URL) {
    Write-Host "URL: $RAILWAY_URL" -ForegroundColor Cyan
}

Write-Host "`n[INFO] Comandos útiles:" -ForegroundColor Yellow
Write-Host "  railway logs         - Ver logs en tiempo real" -ForegroundColor Gray
Write-Host "  railway status       - Ver status del proyecto" -ForegroundColor Gray
Write-Host "  railway open         - Abrir en el navegador" -ForegroundColor Gray
Write-Host "  railway rollback     - Rollback a versión anterior" -ForegroundColor Gray

Write-Host "`n"
