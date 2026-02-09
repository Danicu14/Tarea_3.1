# Script de Rollback para Railway
# Permite volver a una versión anterior del deploy

param(
    [Parameter(Mandatory=$false)]
    [int]$Steps = 1,
    
    [Parameter(Mandatory=$false)]
    [switch]$Force = $false
)

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  ROLLBACK DE RAILWAY" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# ========================================
# 1. Verificar Railway CLI
# ========================================

Write-Host "[1/4] Verificando Railway CLI..." -ForegroundColor Yellow

$railwayInstalled = Get-Command railway -ErrorAction SilentlyContinue
if (-not $railwayInstalled) {
    Write-Host "[ERROR] Railway CLI no está instalado" -ForegroundColor Red
    exit 1
}

Write-Host "[OK] Railway CLI instalado" -ForegroundColor Green

# ========================================
# 2. Confirmar rollback
# ========================================

if (-not $Force) {
    Write-Host "`n[2/4] Confirmación requerida" -ForegroundColor Yellow
    Write-Host "¿Estás seguro de hacer rollback $Steps versión(es) atrás?" -ForegroundColor Yellow
    Write-Host "Esto revertirá el deploy actual" -ForegroundColor Yellow
    
    $confirmation = Read-Host "`nEscribe 'yes' para confirmar"
    
    if ($confirmation -ne "yes") {
        Write-Host "`n[CANCELADO] Rollback abortado" -ForegroundColor Yellow
        exit 0
    }
} else {
    Write-Host "`n[2/4] Confirmación omitida (-Force)" -ForegroundColor Gray
}

# ========================================
# 3. Ejecutar rollback
# ========================================

Write-Host "`n[3/4] Ejecutando rollback..." -ForegroundColor Yellow

# Railway rollback
railway rollback

if ($LASTEXITCODE -ne 0) {
    Write-Host "`n[ERROR] Rollback falló" -ForegroundColor Red
    Write-Host "Verifica los logs: railway logs" -ForegroundColor Yellow
    exit 1
}

Write-Host "[OK] Rollback ejecutado" -ForegroundColor Green

# ========================================
# 4. Verificar health check
# ========================================

Write-Host "`n[4/4] Verificando health check..." -ForegroundColor Yellow
Write-Host "Esperando 20 segundos..." -ForegroundColor Gray
Start-Sleep -Seconds 20

$RAILWAY_URL = $env:RAILWAY_URL
if ($RAILWAY_URL) {
    $healthUrl = "$RAILWAY_URL/health"
    
    try {
        $response = Invoke-WebRequest -Uri $healthUrl -Method GET -TimeoutSec 10
        
        if ($response.StatusCode -eq 200) {
            Write-Host "[OK] Health check exitoso tras rollback" -ForegroundColor Green
        } else {
            Write-Host "[WARNING] Health check retornó: $($response.StatusCode)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "[WARNING] No se pudo verificar health check" -ForegroundColor Yellow
        Write-Host "Verifica manualmente: $healthUrl" -ForegroundColor Gray
    }
}

# ========================================
# Resumen
# ========================================

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  ROLLBACK COMPLETADO" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "Versiones revertidas: $Steps" -ForegroundColor White

Write-Host "`n[INFO] Próximos pasos:" -ForegroundColor Yellow
Write-Host "  1. Verifica que la aplicación funciona correctamente" -ForegroundColor Gray
Write-Host "  2. Revisa los logs: railway logs" -ForegroundColor Gray
Write-Host "  3. Si necesitas volver al deploy anterior:" -ForegroundColor Gray
Write-Host "     railway up --detach" -ForegroundColor Gray

Write-Host "`n"
