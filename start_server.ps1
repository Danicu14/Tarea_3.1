# Script para iniciar el servidor FastAPI
# Para Windows PowerShell

Write-Host "🚀 Iniciando servidor FastAPI..." -ForegroundColor Green

# Activar entorno virtual
& .\venv\Scripts\Activate.ps1

# Iniciar servidor
Write-Host "
✅ Servidor iniciado en: http://localhost:8000
📚 Documentación API: http://localhost:8000/docs  
🌐 Cliente web: http://localhost:8000/static/index.html
💚 Health check: http://localhost:8000/health

Presiona Ctrl+C para detener el servidor
" -ForegroundColor Cyan

python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
