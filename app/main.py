"""Aplicación FastAPI con seguridad y optimizaciones"""
from fastapi import FastAPI, Request, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.trustedhost import TrustedHostMiddleware
from fastapi.responses import JSONResponse
from fastapi.staticfiles import StaticFiles
from fastapi.exceptions import RequestValidationError
import time
import logging
from typing import Dict
from collections import defaultdict
from datetime import datetime, timedelta

from app.config import settings

# Configurar logging
logging.basicConfig(
    level=logging.INFO if not settings.debug else logging.DEBUG,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Crear aplicación FastAPI
app = FastAPI(
    title=settings.api_title,
    version=settings.api_version,
    description=settings.api_description,
    docs_url="/docs" if settings.debug else None,  # Deshabilitar docs en producción
    redoc_url="/redoc" if settings.debug else None,
)

# ========================================
# MIDDLEWARES
# ========================================

# Rate limiting en memoria
rate_limit_storage: Dict[str, list] = defaultdict(list)

def check_rate_limit(client_ip: str) -> bool:
    """Verifica si el cliente excede el rate limit"""
    if not settings.rate_limit_enabled:
        return True
    
    now = datetime.now()
    minute_ago = now - timedelta(minutes=1)
    
    # Limpiar requests antiguos
    rate_limit_storage[client_ip] = [
        req_time for req_time in rate_limit_storage[client_ip]
        if req_time > minute_ago
    ]
    
    # Verificar límite
    if len(rate_limit_storage[client_ip]) >= settings.rate_limit_per_minute:
        return False
    
    # Registrar request
    rate_limit_storage[client_ip].append(now)
    return True

@app.middleware("http")
async def rate_limit_middleware(request: Request, call_next):
    """Middleware de rate limiting"""
    client_ip = request.client.host if request.client else "unknown"
    
    if not check_rate_limit(client_ip):
        return JSONResponse(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            content={
                "error": "Too Many Requests",
                "message": "Has excedido el límite de peticiones. Intenta más tarde."
            }
        )
    
    response = await call_next(request)
    response.headers["X-RateLimit-Limit"] = str(settings.rate_limit_per_minute)
    return response

@app.middleware("http")
async def https_redirect_middleware(request: Request, call_next):
    """Forzar HTTPS en producción"""
    if settings.force_https and settings.environment == "production":
        if request.url.scheme != "https":
            url = request.url.replace(scheme="https")
            return JSONResponse(
                status_code=status.HTTP_301_MOVED_PERMANENTLY,
                headers={"Location": str(url)}
            )
    response = await call_next(request)
    return response

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins_list,
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allow_headers=["*"],
    max_age=3600,
)

@app.middleware("http")
async def add_process_time_header(request: Request, call_next):
    """Tiempo de procesamiento"""
    start_time = time.time()
    response = await call_next(request)
    process_time = time.time() - start_time
    response.headers["X-Process-Time"] = str(process_time)
    return response

@app.middleware("http")
async def add_security_headers(request: Request, call_next):
    """Headers de seguridad"""
    response = await call_next(request)
    response.headers["X-Content-Type-Options"] = "nosniff"
    response.headers["X-Frame-Options"] = "DENY"
    response.headers["X-XSS-Protection"] = "1; mode=block"
    if settings.environment == "production":
        response.headers["Strict-Transport-Security"] = "max-age=31536000; includeSubDomains"
    return response

# ========================================
# RUTAS
# ========================================

@app.get("/")
async def root():
    """Endpoint raíz"""
    return {
        "message": "API FastAPI en producción",
        "version": settings.api_version,
        "environment": settings.environment,
        "docs": "/docs" if settings.debug else "disabled in production"
    }

@app.get("/health")
async def health_check():
    """
    Health check para monitorización
    Usado por Docker, Kubernetes, load balancers, etc.
    """
    return {
        "status": "healthy",
        "environment": settings.environment,
        "version": settings.api_version
    }

@app.get("/api/info")
async def api_info():
    """Información de la API"""
    return {
        "name": settings.api_title,
        "version": settings.api_version,
        "description": settings.api_description,
        "environment": settings.environment
    }

# ========================================
# EJEMPLOS DE ENDPOINTS (Añade los tuyos)
# ========================================

@app.get("/api/items")
async def get_items():
    """Endpoint de ejemplo - reemplaza con los tuyos"""
    return {
        "items": [
            {"id": 1, "name": "Item 1"},
            {"id": 2, "name": "Item 2"},
            {"id": 3, "name": "Item 3"}
        ]
    }

@app.get("/api/items/{item_id}")
async def get_item(item_id: int):
    """Obtener un item específico"""
    return {
        "id": item_id,
        "name": f"Item {item_id}",
        "description": "Este es un item de ejemplo"
    }

# ========================================
# MANEJO DE ERRORES SEGURO
# ========================================

@app.exception_handler(404)
async def not_found_handler(request: Request, exc):
    """Manejo personalizado de 404 - No expone paths en producción"""
    content = {
        "error": "Not Found",
        "message": "El recurso solicitado no existe"
    }
    
    # Solo en desarrollo mostramos el path
    if settings.debug:
        content["path"] = str(request.url)
    
    return JSONResponse(
        status_code=404,
        content=content
    )

@app.exception_handler(500)
async def internal_error_handler(request: Request, exc):
    """Manejo personalizado de errores internos - Oculta detalles en producción"""
    logger.error(f"Error interno: {exc}", exc_info=True)
    
    content = {
        "error": "Internal Server Error",
        "message": "Ha ocurrido un error interno. Por favor contacta al soporte."
    }
    
    # Solo en desarrollo mostramos detalles del error
    if settings.debug:
        content["detail"] = str(exc)
        content["type"] = type(exc).__name__
    
    return JSONResponse(
        status_code=500,
        content=content
    )

@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    """Manejo de errores de validación - Mensajes sanitizados"""
    logger.warning(f"Error de validación: {exc}")
    
    content = {
        "error": "Validation Error",
        "message": "Los datos enviados no son válidos"
    }
    
    # Solo en desarrollo mostramos detalles de validación
    if settings.debug:
        content["details"] = exc.errors()
    
    return JSONResponse(
        status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
        content=content
    )

@app.exception_handler(Exception)
async def general_exception_handler(request: Request, exc: Exception):
    """Catch-all para errores no manejados - NUNCA expone stack traces en producción"""
    logger.error(f"Error no manejado: {exc}", exc_info=True)
    
    content = {
        "error": "Server Error",
        "message": "Ha ocurrido un error inesperado"
    }
    
    # Solo en desarrollo mostramos información de debug
    if settings.debug:
        content["detail"] = str(exc)
        content["type"] = type(exc).__name__
    else:
        # En producción, solo mensaje genérico
        content["support_id"] = f"ERR-{int(time.time())}"
    
    return JSONResponse(
        status_code=500,
        content=content
    )

# ========================================
# ARCHIVOS ESTÁTICOS (Cliente/Frontend)
# ========================================

# Montar archivos estáticos del cliente
try:
    app.mount("/static", StaticFiles(directory="static"), name="static")
    logger.info("Archivos estáticos montados en /static")
except Exception as e:
    logger.warning(f"No se pudieron montar archivos estáticos: {e}")

# ========================================
# EVENTOS DE INICIO/CIERRE
# ========================================

@app.on_event("startup")
async def startup_event():
    """Ejecutar al iniciar la aplicación"""
    logger.info(f"🚀 Iniciando aplicación en modo {settings.environment}")
    logger.info(f"📍 CORS origins: {settings.cors_origins_list}")

@app.on_event("shutdown")
async def shutdown_event():
    """Ejecutar al cerrar la aplicación"""
    logger.info("👋 Cerrando aplicación")

# ========================================
# PUNTO DE ENTRADA
# ========================================

if __name__ == "__main__":
    import uvicorn
    
    uvicorn.run(
        "app.main:app",
        host=settings.host,
        port=settings.port,
        reload=settings.debug,
        log_level="info"
    )
