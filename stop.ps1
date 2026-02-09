# 🛑 Script para Detener Servidor
# Para Windows PowerShell

Write-Host "🛑 Deteniendo servidor FastAPI..." -ForegroundColor Yellow

# Encontrar procesos de Python en el puerto 8000
$processes = Get-NetTCPConnection -LocalPort 8000 -ErrorAction SilentlyContinue | 
    Select-Object -ExpandProperty OwningProcess -Unique

if ($processes) {
    foreach ($pid in $processes) {
        $process = Get-Process -Id $pid -ErrorAction SilentlyContinue
        if ($process) {
            Write-Host "🔴 Deteniendo proceso: $($process.Name) (PID: $pid)" -ForegroundColor Red
            Stop-Process -Id $pid -Force
        }
    }
    Write-Host "✅ Servidor detenido" -ForegroundColor Green
} else {
    Write-Host "ℹ️  No hay servidor ejecutándose en el puerto 8000" -ForegroundColor Cyan
}
