# Script para instalar Git Hooks personalizados
# Los hooks se ejecutan automáticamente en ciertos eventos de Git

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  INSTALACIÓN DE GIT HOOKS" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# ========================================
# 1. Verificar que estamos en un repo Git
# ========================================

if (-not (Test-Path ".git")) {
    Write-Host "[ERROR] No estás en un repositorio Git" -ForegroundColor Red
    Write-Host "Inicializa con: git init" -ForegroundColor Yellow
    exit 1
}

# ========================================
# 2. Crear directorio de hooks si no existe
# ========================================

$gitHooksDir = ".git\hooks"
if (-not (Test-Path $gitHooksDir)) {
    New-Item -ItemType Directory -Path $gitHooksDir | Out-Null
}

# ========================================
# 3. Copiar hooks personalizados
# ========================================

$customHooksDir = ".githooks"

if (-not (Test-Path $customHooksDir)) {
    Write-Host "[ERROR] Directorio .githooks no encontrado" -ForegroundColor Red
    exit 1
}

Write-Host "[INFO] Instalando hooks personalizados..." -ForegroundColor Yellow

$hooks = Get-ChildItem $customHooksDir -File

foreach ($hook in $hooks) {
    $source = $hook.FullName
    $destination = Join-Path $gitHooksDir $hook.Name
    
    # Copiar hook
    Copy-Item -Path $source -Destination $destination -Force
    
    Write-Host "  [OK] Instalado: $($hook.Name)" -ForegroundColor Green
}

# ========================================
# 4. Configurar Git para usar el directorio de hooks
# ========================================

Write-Host "`n[INFO] Configurando Git..." -ForegroundColor Yellow

git config core.hooksPath .githooks

Write-Host "  [OK] core.hooksPath configurado" -ForegroundColor Green

# ========================================
# 5. Dar permisos de ejecución (en Git Bash)
# ========================================

Write-Host "`n[INFO] Configurando permisos..." -ForegroundColor Yellow

foreach ($hook in $hooks) {
    $hookPath = Join-Path $customHooksDir $hook.Name
    git update-index --chmod=+x $hookPath 2>$null
}

Write-Host "  [OK] Permisos configurados" -ForegroundColor Green

# ========================================
# Resumen
# ========================================

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  HOOKS INSTALADOS EXITOSAMENTE" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "Hooks instalados:" -ForegroundColor White
foreach ($hook in $hooks) {
    Write-Host "  - $($hook.Name)" -ForegroundColor Gray
}

Write-Host "`n[INFO] Los hooks se ejecutarán automáticamente:" -ForegroundColor Yellow
Write-Host "  pre-commit  -> Antes de cada commit" -ForegroundColor Gray
Write-Host "  pre-push    -> Antes de cada push" -ForegroundColor Gray

Write-Host "`n[TIP] Para omitir hooks temporalmente:" -ForegroundColor Cyan
Write-Host "  git commit --no-verify" -ForegroundColor Gray
Write-Host "  git push --no-verify" -ForegroundColor Gray

Write-Host "`n[TIP] Para desinstalar hooks:" -ForegroundColor Cyan
Write-Host "  git config --unset core.hooksPath" -ForegroundColor Gray

Write-Host "`n"
