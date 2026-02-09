"""
Punto de entrada principal de la aplicación FastAPI
Configuración de middlewares, CORS, rutas y seguridad
"""
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.trustedhost import TrustedHostMiddleware
from fastapi.responses import JSONResponse
from fastapi.staticfiles import StaticFiles
import time
import logging

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

# CORS - Configuración restrictiva para producción
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins_list,
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allow_headers=["*"],
    max_age=3600,  # Cache de preflight requests
)

# Middleware de tiempo de respuesta
@app.middleware("http")
async def add_process_time_header(request: Request, call_next):
    """Añade header con tiempo de procesamiento"""
    start_time = time.time()
    response = await call_next(request)
    process_time = time.time() - start_time
    response.headers["X-Process-Time"] = str(process_time)
    return response

# Middleware de seguridad - Headers
@app.middleware("http")
async def add_security_headers(request: Request, call_next):
    """Añade headers de seguridad"""
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
# MANEJO DE ERRORES
# ========================================

@app.exception_handler(404)
async def not_found_handler(request: Request, exc):
    """Manejo personalizado de 404"""
    return JSONResponse(
        status_code=404,
        content={
            "error": "Not Found",
            "message": "El recurso solicitado no existe",
            "path": str(request.url)
        }
    )

@app.exception_handler(500)
async def internal_error_handler(request: Request, exc):
    """Manejo personalizado de errores internos"""
    logger.error(f"Error interno: {exc}")
    return JSONResponse(
        status_code=500,
        content={
            "error": "Internal Server Error",
            "message": "Ha ocurrido un error interno" if settings.environment == "production" else str(exc)
        }
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
