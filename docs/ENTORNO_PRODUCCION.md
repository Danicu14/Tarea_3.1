# 📋 Documentación del Entorno de Producción

## 1️⃣ Configuración del Entorno de Producción

### 🎯 Plataforma Seleccionada: **Railway** (PaaS)

#### ✅ Justificación de la Elección

| Criterio | Railway | Alternativas |
|----------|---------|--------------|
| **Facilidad de uso** | ⭐⭐⭐⭐⭐ Despliegue automático desde Git | Render (⭐⭐⭐⭐), Heroku (⭐⭐⭐) |
| **Costo** | Gratis hasta 500 hrs/mes + $5 crédito | Render (gratis limitado), Fly.io ($) |
| **HTTPS** | ✅ Automático con certificado SSL | ✅ Todas las PaaS modernas |
| **Variables de entorno** | ✅ Interfaz intuitiva | ✅ Todas soportan |
| **Logs en tiempo real** | ✅ Consola integrada | ✅ Render, Fly.io |
| **Escalabilidad** | ✅ Vertical y horizontal | ✅ Render, AWS |
| **Docker** | ✅ Soporte nativo | ✅ Fly.io, Render |

---

## 🖥️ Sistema Operativo y Runtime

### Contenedor Docker
```dockerfile
Base: python:3.11-slim
SO Base: Debian GNU/Linux 12 (bookworm)
Arquitectura: linux/amd64
```

**¿Por qué Debian Slim?**
- ✅ Imagen ligera (< 150 MB)
- ✅ Seguridad: menos paquetes = menos vulnerabilidades
- ✅ Rápido despliegue
- ✅ Mantenimiento oficial de Python

---

## 🔧 Lenguajes y Runtimes Instalados

### Backend (API)

#### Python 3.11+
```bash
# Verificar versión
python --version
# Python 3.11.7
```

**Librerías Principales:**
- **FastAPI** `0.109.0` - Framework web asíncrono
- **Uvicorn** `0.27.0` - Servidor ASGI de alto rendimiento
- **Pydantic** `2.5.3` - Validación de datos
- **Gunicorn** `21.2.0` - Gestor de procesos para producción

#### Gestor de Dependencias
```bash
pip 23.3.2
```

### Frontend (Cliente)

- **HTML5** - Estructura
- **CSS3** - Estilos (variables CSS, grid, flexbox)
- **JavaScript ES6+** - Lógica del cliente (Fetch API, async/await)

---

## 🌍 Variables de Entorno Configuradas

### Desarrollo (`.env` local)
```env
ENVIRONMENT=development
DEBUG=True
HOST=0.0.0.0
PORT=8000
SECRET_KEY=dev-secret-key-change-in-production
CORS_ORIGINS=http://localhost:3000,http://localhost:8000
```

### Producción (Railway Dashboard)
```env
ENVIRONMENT=production
DEBUG=False
HOST=0.0.0.0
PORT=${PORT}  # Railway asigna automáticamente
SECRET_KEY=<generado-con-secrets.token_urlsafe()>
CORS_ORIGINS=https://tu-app.up.railway.app
ALLOWED_ORIGINS=https://tu-app.up.railway.app
```

### ⚠️ Seguridad de Secretos
- ✅ **NUNCA** commits de `.env` al repositorio
- ✅ Usar variables de entorno en la plataforma
- ✅ `SECRET_KEY` generada aleatoriamente:
  ```python
  import secrets
  secrets.token_urlsafe(32)
  ```

---

## 🔌 Puertos y Servicios Utilizados

### Servicios Principales

| Servicio | Puerto | Protocolo | Uso | Accesible |
|----------|--------|-----------|-----|-----------|
| **FastAPI (Uvicorn)** | 8000 | HTTP/HTTPS | API REST principal | ✅ Público |
| **Health Check** | 8000 | HTTP | `/health` endpoint | ✅ Público |
| **Docs (Desarrollo)** | 8000 | HTTP | `/docs`, `/redoc` | ⚠️ Solo dev |

### Servicios Externos (Opcionales)

| Servicio | Puerto | Uso | Proveedor |
|----------|--------|-----|-----------|
| PostgreSQL | 5432 | Base de datos | Railway Plugin |
| Redis | 6379 | Caché/Sesiones | Railway Plugin |

### 🔒 Configuración de Firewall

```
ENTRADA:
- Puerto 8000 (TCP) → ABIERTO (solo desde load balancer)
- Puerto 443 (HTTPS) → Railway Load Balancer
- Resto → CERRADO

SALIDA:
- HTTPS (443) → APIs externas
- PostgreSQL (5432) → Interna Railway
```

---

## 🏗️ Arquitectura de Despliegue

```
┌─────────────────────────────────────────────┐
│           INTERNET (Cliente)                │
└──────────────────┬──────────────────────────┘
                   │ HTTPS (443)
                   │
┌──────────────────▼──────────────────────────┐
│      Railway Load Balancer                  │
│  - Terminación SSL/TLS                      │
│  - Certificado automático                   │
│  - DDoS protection                          │
└──────────────────┬──────────────────────────┘
                   │ HTTP (8000)
                   │
┌──────────────────▼──────────────────────────┐
│         Contenedor Docker                   │
│  ┌────────────────────────────────────┐     │
│  │   Uvicorn ASGI Server              │     │
│  │   workers: 1-4 (según CPU)         │     │
│  │   timeout: 60s                     │     │
│  └────────────┬───────────────────────┘     │
│               │                             │
│  ┌────────────▼───────────────────────┐     │
│  │   FastAPI Application              │     │
│  │   - Routers                        │     │
│  │   - Middlewares (CORS, Security)   │     │
│  │   - Endpoints                      │     │
│  └────────────────────────────────────┘     │
└──────────────────┬──────────────────────────┘
                   │
         ┌─────────┴──────────┐
         │                    │
┌────────▼─────┐    ┌────────▼─────┐
│ PostgreSQL   │    │  Redis Cache │
│ (opcional)   │    │  (opcional)  │
└──────────────┘    └──────────────┘
```

---

## ⚙️ Configuración de Uvicorn para Producción

### Comando de Inicio
```bash
uvicorn app.main:app \
  --host 0.0.0.0 \
  --port 8000 \
  --workers 2 \
  --log-level info \
  --no-access-log \
  --proxy-headers
```

### Parámetros Explicados
- `--host 0.0.0.0` → Escucha en todas las interfaces
- `--port 8000` → Puerto del contenedor
- `--workers 2` → Procesos paralelos (CPU * 2 + 1 recomendado)
- `--log-level info` → Logs sin debug
- `--no-access-log` → Evita logs excesivos
- `--proxy-headers` → Confía en headers del load balancer

---

## 📊 Recursos Asignados

### Plan Gratuito Railway
| Recurso | Límite | Uso Estimado |
|---------|--------|--------------|
| RAM | 512 MB | 200-300 MB |
| CPU | 1 vCPU compartido | ~20-30% promedio |
| Almacenamiento | 1 GB | 50-100 MB |
| Ancho de banda | 100 GB/mes | Según tráfico |
| Horas de ejecución | 500 hrs/mes | ~16 hrs/día |

### Optimizaciones Aplicadas
```dockerfile
# En Dockerfile
ENV PYTHONUNBUFFERED=1          # Sin buffer, menos RAM
ENV PYTHONDONTWRITEBYTECODE=1   # Sin .pyc, menos disco
RUN pip install --no-cache-dir  # No cache pip
```

---

## 🔍 Monitorización y Logs

### Health Check Endpoint
```python
@app.get("/health")
async def health_check():
    return {
        "status": "healthy",
        "environment": settings.environment,
        "version": "1.0.0"
    }
```

### Docker Healthcheck
```dockerfile
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD python -c "import requests; requests.get('http://localhost:8000/health')"
```

### Logs Estructurados
```python
import logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
```

**Acceso a logs:**
```bash
# En Railway CLI
railway logs

# O desde el Dashboard → Deploy → Logs
```

---

## 🚀 Proceso de Despliegue

### 1. Preparación Local
```bash
# Clonar repositorio
git clone <tu-repo>
cd Tarea_3.1

# Crear entorno virtual
python -m venv venv
venv\Scripts\activate  # Windows

# Instalar dependencias
pip install -r requirements.txt

# Configurar variables
cp .env.example .env
# Editar .env con tus valores

# Probar localmente
uvicorn app.main:app --reload
```

### 2. Despliegue en Railway

#### Opción A: Desde GitHub (Recomendado)
1. Push a GitHub:
   ```bash
   git add .
   git commit -m "Initial commit"
   git push origin main
   ```

2. En Railway Dashboard:
   - New Project → Deploy from GitHub repo
   - Seleccionar repositorio
   - Railway detecta automáticamente el Dockerfile
   - Configurar variables de entorno
   - Deploy

#### Opción B: Railway CLI
```bash
# Instalar Railway CLI
npm i -g @railway/cli

# Login
railway login

# Inicializar proyecto
railway init

# Desplegar
railway up
```

### 3. Verificación
```bash
# Obtener URL del deployment
railway domain

# Probar endpoints
curl https://tu-app.up.railway.app/health
curl https://tu-app.up.railway.app/api/info
```

---

## 🎯 Checklist de Producción

### ✅ Antes del Despliegue
- [ ] `DEBUG=False` en producción
- [ ] `SECRET_KEY` segura y única
- [ ] CORS configurado restrictivamente
- [ ] Dependencias actualizadas (`pip list --outdated`)
- [ ] `.env` en `.gitignore`
- [ ] Healthcheck funcionando
- [ ] Tests pasando (si hay)

### ✅ Después del Despliegue
- [ ] HTTPS activo
- [ ] Endpoints respondiendo correctamente
- [ ] Logs sin errores
- [ ] Variables de entorno cargadas
- [ ] Cliente (frontend) carga correctamente
- [ ] CORS permite requests del frontend

---

## 📚 Recursos y Referencias

### Documentación Oficial
- [FastAPI Deployment](https://fastapi.tiangolo.com/deployment/)
- [Uvicorn Deployment](https://www.uvicorn.org/deployment/)
- [Railway Docs](https://docs.railway.app/)

### Herramientas Útiles
- **Railway CLI**: Gestión desde terminal
- **Docker Desktop**: Pruebas locales de contenedores
- **Postman/Insomnia**: Testing de API

---

## 🆘 Troubleshooting

### Problema: Puerto incorrecto
```
Error: Port 8000 is already in use
```
**Solución:** Railway asigna automáticamente el puerto via `$PORT`
```python
port = int(os.getenv("PORT", 8000))
```

### Problema: CORS error
```
Access to fetch blocked by CORS policy
```
**Solución:** Añadir dominio de Railway a CORS_ORIGINS
```env
CORS_ORIGINS=https://tu-app.up.railway.app
```

### Problema: Dependencias no instaladas
```
ModuleNotFoundError: No module named 'fastapi'
```
**Solución:** Verificar `requirements.txt` y rebuild
```bash
railway up --detach
```

---

## 📝 Conclusión

Has configurado un entorno de producción completo con:
- ✅ **Plataforma**: Railway (PaaS)
- ✅ **SO**: Debian Linux (contenedor)
- ✅ **Runtime**: Python 3.11 + Uvicorn
- ✅ **Frontend**: HTML/CSS/JS estáticos
- ✅ **Variables**: Gestionadas de forma segura
- ✅ **Puertos**: 8000 (HTTP) → 443 (HTTPS load balancer)
- ✅ **Arquitectura**: Load Balancer → Contenedor → App

**Siguiente paso:** Automatización con CI/CD (GitHub Actions) 🚀
