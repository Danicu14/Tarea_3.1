# 🚀 Script de Inicio Rápido - FastAPI
# Para Windows PowerShell

Write-Host "================================" -ForegroundColor Cyan
Write-Host "   FastAPI - Inicio Rápido" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# Verificar si existe el entorno virtual
if (-Not (Test-Path ".\venv")) {
    Write-Host "❌ No se encontró el entorno virtual." -ForegroundColor Red
    Write-Host "📦 Creando entorno virtual..." -ForegroundColor Yellow
    python -m venv venv
    Write-Host "✅ Entorno virtual creado" -ForegroundColor Green
}

# Activar entorno virtual
Write-Host "📂 Activando entorno virtual..." -ForegroundColor Yellow
& .\venv\Scripts\Activate.ps1

# Verificar si están instaladas las dependencias
Write-Host "🔍 Verificando dependencias..." -ForegroundColor Yellow
$fastapi_installed = & python -c "import fastapi" 2>$null
if (-Not $?) {
    Write-Host "📦 Instalando dependencias..." -ForegroundColor Yellow
    pip install -r requirements.txt
    Write-Host "✅ Dependencias instaladas" -ForegroundColor Green
}

# Verificar archivo .env
if (-Not (Test-Path ".\.env")) {
    Write-Host "⚠️  No se encontró archivo .env" -ForegroundColor Yellow
    Write-Host "📄 Copiando .env.example a .env..." -ForegroundColor Yellow
    Copy-Item .env.example .env
    Write-Host "✅ Archivo .env creado" -ForegroundColor Green
}

Write-Host ""
Write-Host "================================" -ForegroundColor Cyan
Write-Host "🎯 SERVIDOR INICIADO" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📍 URLs Disponibles:" -ForegroundColor White
Write-Host "   🌐 Cliente: http://localhost:8000/static/index.html" -ForegroundColor Cyan
Write-Host "   📚 API Docs: http://localhost:8000/docs" -ForegroundColor Cyan
Write-Host "   💚 Health: http://localhost:8000/health" -ForegroundColor Cyan
Write-Host "   📡 API Info: http://localhost:8000/api/info" -ForegroundColor Cyan
Write-Host ""
Write-Host "⚠️  Presiona Ctrl+C para detener el servidor" -ForegroundColor Yellow
Write-Host ""

# Iniciar servidor con auto-reload
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
