# Tarea 3.1 - Despliegue a Producción

## 📋 Descripción del Proyecto
Aplicación web completa con backend FastAPI y frontend, desplegada en entorno de producción.

## 🖥️ Configuración del Entorno de Producción

### Plataforma Seleccionada
**Railway / Render** (PaaS)

#### Justificación:
- ✅ Despliegue automático desde repositorio Git
- ✅ HTTPS gratuito
- ✅ Escalabilidad automática
- ✅ Variables de entorno seguras
- ✅ Logs en tiempo real
- ✅ Reinicio automático ante fallos

### Sistema Operativo
- **Contenedor Docker** basado en `python:3.11-slim`
- Sistema: Debian Linux (slim)

### Lenguajes y Runtimes

#### Backend (API)
- **Python**: 3.11+
- **Framework**: FastAPI
- **Servidor ASGI**: Uvicorn
- **Gestor de dependencias**: pip / Poetry

#### Frontend (Cliente)
- **HTML5 / CSS3 / JavaScript** (Vanilla o framework usado anteriormente)

### Variables de Entorno Configuradas

```env
# Configuración de la aplicación
ENVIRONMENT=production
DEBUG=False

# Servidor
HOST=0.0.0.0
PORT=8000

# Base de datos (si aplica)
DATABASE_URL=postgresql://user:password@host:port/dbname

# Seguridad
SECRET_KEY=your-secret-key-here
ALLOWED_ORIGINS=https://yourdomain.com

# CORS
CORS_ORIGINS=["https://yourdomain.com"]
```

### Puertos y Servicios

| Servicio | Puerto | Protocolo | Descripción |
|----------|--------|-----------|-------------|
| Nginx (Proxy/Static) | 8000 | HTTP/HTTPS | Servidor web y proxy inverso |
| Gunicorn (Internal) | 8001 | HTTP | Servidor de aplicación (interno) |
| PostgreSQL | 5432 | TCP | Base de datos (si se usa) |
| Redis | 6379 | TCP | Caché (opcional) |

### Arquitectura de Despliegue (✨ Optimizada - Parte 3)

```
Internet (HTTPS)
    ↓
Load Balancer (Railway)
    ↓
Contenedor Docker
    ├─ Supervisord (Gestor de procesos)
    │   ├─ Nginx :8000 (Proxy inverso + Archivos estáticos)
    │   │   ├─ Compresión GZIP (60-80% reducción)
    │   │   ├─ Cache de estáticos
    │   │   └─ Security headers
    │   │
    │   └─ Gunicorn :8001 (4-5 workers Uvicorn)
    │       └─ FastAPI Application
```

## 📦 Estructura del Proyecto

```
Tarea_3.1/
├── app/
│   ├── __init__.py
│   ├── main.py                 # Punto de entrada FastAPI
│   ├── config.py               # Configuración y variables de entorno
│   ├── routers/                # Endpoints de la API
│   ├── models/                 # Modelos de datos
│   ├── services/               # Lógica de negocio
│   └── middleware/             # Middlewares (CORS, seguridad)
├── static/                     # Archivos estáticos del cliente
│   ├── index.html
│   ├── css/
│   └── js/
├── requirements.txt            # Dependencias Python
├── Dockerfile                  # Configuración del contenedor
├── .env.example               # Plantilla de variables de entorno
├── .gitignore                 # Archivos a ignorar en Git
└── README.md                  # Este archivo
```

## 🚀 Instrucciones de Despliegue

### 1. Preparación Local
```bash
# Crear entorno virtual
python -m venv venv
source venv/bin/activate  # En Windows: venv\Scripts\activate

# Instalar dependencias
pip install -r requirements.txt

# Copiar variables de entorno
cp .env.example .env
# Editar .env con tus valores
```

### 2. Prueba Local
```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### 3. Despliegue en Producción
Ver documentación específica en `docs/deployment.md`

## 🔒 Medidas de Seguridad Implementadas

- ✅ Variables de entorno para datos sensibles
- ✅ HTTPS obligatorio
- ✅ CORS configurado restrictivamente
- ✅ Headers de seguridad (HSTS, X-Frame-Options)
- ✅ Rate limiting
- ✅ Validación de datos con Pydantic
- ✅ Logs sin información sensible

## 📊 Monitorización

- Logs de aplicación
- Métricas de rendimiento
- Alertas de errores

## � Documentación Adicional

### 📦 Documentos de Entrega Oficiales

| Parte | Documento | Estado |
|-------|-----------|--------|
| **Parte 1** | [📄 ENTREGA_PARTE1.md](ENTREGA_PARTE1.md) | ✅ Completa |
| **Parte 2** | [📄 ENTREGA_PARTE2.md](ENTREGA_PARTE2.md) | ✅ Completa |
| **Parte 3** | [📄 ENTREGA_PARTE3.md](ENTREGA_PARTE3.md) | ✅ Completa |

### 📖 Documentación Técnica

| Documento | Descripción |
|-----------|-------------|
| [🔧 COMANDOS.md](COMANDOS.md) | Referencia rápida de comandos |
| [📖 docs/ENTORNO_PRODUCCION.md](docs/ENTORNO_PRODUCCION.md) | Documentación detallada del entorno |
| [🧪 docs/PRUEBAS_LOCALES.md](docs/PRUEBAS_LOCALES.md) | Guía de testing local |
| [🌐 docs/FLUJO_REQUESTS.md](docs/FLUJO_REQUESTS.md) | **Flujo visual de requests Nginx+Gunicorn** |
| [🐳 docs/DOCKER_GUIA.md](docs/DOCKER_GUIA.md) | Guía de Docker y contenedores |
| [📊 docs/ANALISIS_DEPENDENCIAS.md](docs/ANALISIS_DEPENDENCIAS.md) | Análisis de dependencias prod vs dev |

## ⚡ Scripts Disponibles

### 🚀 Desarrollo

| Script | Uso | Descripción |
|--------|-----|-------------|
| `start.ps1` | `.\start.ps1` | Inicia el servidor (configuración automática) |
| `stop.ps1` | `.\stop.ps1` | Detiene el servidor |

### 🔍 Análisis

| Script | Uso | Descripción |
|--------|-----|-------------|
| `analyze-deps.ps1` | `.\analyze-deps.ps1` | Análisis de dependencias prod vs dev |
| `analyze-server-config.ps1` | `.\analyze-server-config.ps1` | **Análisis de optimizaciones Nginx/Gunicorn** |

### 🐳 Docker

| Script | Uso | Descripción |
|--------|-----|-------------|
| `docker-build.ps1` | `.\docker-build.ps1` | Build básico de imagen Docker |
| `test-prod-build.ps1` | `.\test-prod-build.ps1` | **Build y test de imagen de producción (Nginx)** |
| `test-prod-deps.ps1` | `.\test-prod-deps.ps1` | Test de dependencias de producción |

## 🌐 URLs Locales

| Recurso | URL |
|---------|-----|
| 🌐 Cliente Web | http://localhost:8000/static/index.html |
| 📚 API Docs (Swagger) | http://localhost:8000/docs |
| 💚 Health Check | http://localhost:8000/health |
| 📡 API Info | http://localhost:8000/api/info |

## �👨‍💻 Autor
[Tu nombre]

## 📅 Fecha
Febrero 2026
