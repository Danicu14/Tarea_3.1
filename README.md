# Tarea 3.1 - Del Desarrollo a Producción

Aplicación web con FastAPI desplegada en producción con Docker, Nginx y CI/CD.

## Descripción

Aplicación web desarrollada con FastAPI que implementa un entorno de producción completo, incluyendo gestión de dependencias, optimización del servidor web, despliegue automatizado y medidas de seguridad.

## Tecnologías

- **Backend**: Python 3.11, FastAPI
- **Servidor Web**: Nginx + Gunicorn
- **Contenedores**: Docker
- **Despliegue**: Railway
- **CI/CD**: GitHub Actions

## Instalación

1. Crear entorno virtual:
```bash
python -m venv venv
venv\Scripts\activate
```

2. Instalar dependencias:
```bash
pip install -r requirements.txt
```

3. Configurar variables de entorno:
```bash
copy .env.example .env
# Editar .env con tus valores
```

4. Iniciar servidor:
```bash
.\start.ps1
```

## Uso

- **Web**: http://localhost:8000/static/index.html
- **API Docs**: http://localhost:8000/docs
- **Health Check**: http://localhost:8000/health

## Docker

Build y ejecución en producción:
```bash
docker-compose -f docker-compose.prod.yml build
docker-compose -f docker-compose.prod.yml up
```

## Despliegue

El proyecto se despliega automáticamente en Railway al hacer push a main. GitHub Actions ejecuta tests, análisis de seguridad y construye la imagen Docker.

## Características Implementadas

- Gestión de dependencias separadas (producción/desarrollo)
- Optimización con Nginx (GZIP, cache, proxy)
- CI/CD automatizado
- Medidas de seguridad (HTTPS, rate limiting, headers)
- Tests automáticos
- Monitoreo con health checks

---

**Tarea 3.1 - Despliegue y Producción**  
Febrero 2026
