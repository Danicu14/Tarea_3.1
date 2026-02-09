# Dockerfile para Producción - Optimizado para Dependencias
# Multi-stage build para reducir tamaño de imagen final

# ============================================
# Stage 1: Builder - Instalar dependencias
# ============================================
FROM python:3.11-slim as builder

# Información del mantenedor
LABEL maintainer="tu-email@example.com"
LABEL description="FastAPI Application - Production Build"

# Variables de entorno para Python
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_DEFAULT_TIMEOUT=100

# Instalar dependencias del sistema necesarias para compilación
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    gcc \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# Crear directorio para las dependencias
WORKDIR /install

# Copiar SOLO archivos de dependencias (para aprovechar cache de Docker)
COPY requirements-prod.txt .

# Instalar dependencias en un directorio separado
RUN pip install --prefix=/install --no-warn-script-location -r requirements-prod.txt

# ============================================
# Stage 2: Runtime - Imagen final
# ============================================
FROM python:3.11-slim

# Variables de entorno para producción
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PATH="/install/bin:${PATH}" \
    PYTHONPATH="/install/lib/python3.11/site-packages:${PYTHONPATH}"

# Establecer directorio de trabajo
WORKDIR /app

# Copiar dependencias instaladas desde el stage builder
COPY --from=builder /install /install

# Copiar el código de la aplicación
COPY ./app ./app
COPY ./static ./static

# Crear usuario no-root para mayor seguridad
RUN useradd -m -u 1000 appuser && \
    chown -R appuser:appuser /app

# Cambiar a usuario no-root
USER appuser

# Exponer el puerto
EXPOSE 8000

# Healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')"

# Comando para ejecutar la aplicación
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "2"]
