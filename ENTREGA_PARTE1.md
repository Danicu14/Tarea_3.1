# 📄 ENTREGA PARTE 1: Configuración del Entorno de Producción

**Alumno:** [Tu nombre]  
**Fecha:** 9 de febrero de 2026  
**Tarea:** UT3.1 – Del desarrollo a producción: despliegue, automatización y seguridad  

---

## 1️⃣ Sistema Operativo o Plataforma Utilizada

### Plataforma Seleccionada
**Railway** - Platform as a Service (PaaS)

### Sistema Operativo Base
- **Contenedor Docker**: `python:3.11-slim`
- **Sistema Operativo**: Debian GNU/Linux 12 (bookworm)
- **Arquitectura**: linux/amd64

### Justificación de la Elección

He seleccionado **Railway** como plataforma de despliegue por las siguientes razones:

1. **Facilidad de despliegue**: Railway permite desplegar automáticamente desde un repositorio Git (GitHub, GitLab), lo que facilita enormemente el proceso de actualización continua de la aplicación.

2. **HTTPS automático**: La plataforma proporciona certificados SSL/TLS de forma automática y gratuita, garantizando conexiones seguras sin configuración manual.

3. **Escalabilidad**: Permite escalar tanto vertical como horizontalmente según las necesidades de la aplicación.

4. **Variables de entorno seguras**: Interfaz intuitiva para gestionar variables de entorno sensibles (claves secretas, credenciales) sin exponerlas en el código.

5. **Logs en tiempo real**: Consola integrada que permite monitorizar la aplicación en producción.

6. **Capa gratuita**: Ofrece 500 horas mensuales gratuitas más $5 de crédito, ideal para proyectos educativos y prototipos.

7. **Soporte Docker nativo**: Detecta y construye automáticamente contenedores Docker.

### Alternativas Consideradas

| Plataforma | Ventajas | Desventajas |
|------------|----------|-------------|
| **Render** | Similar a Railway, buen tier gratuito | Menor rendimiento en capa gratuita |
| **Heroku** | Muy popular, documentación extensa | Eliminó tier gratuito, requiere pago |
| **Fly.io** | Buena distribución geográfica | Configuración más compleja |
| **AWS/Azure** | Máximo control y escalabilidad | Curva de aprendizaje elevada, costos |

### Arquitectura de Contenedor

El contenedor Docker se configura con:

```dockerfile
FROM python:3.11-slim
```

**Beneficios de usar Debian Slim:**
- ✅ Imagen ligera (< 150 MB vs > 900 MB de la versión completa)
- ✅ Menos superficie de ataque (seguridad)
- ✅ Despliegues más rápidos
- ✅ Menor uso de recursos
- ✅ Mantenimiento oficial de Python

---

## 2️⃣ Lenguajes y Runtimes Instalados

### Backend (Servidor API)

#### Python 3.11+
**Versión instalada:** Python 3.14.0.final.0

Python se seleccionó por:
- Excelente ecosistema para desarrollo web
- Alto rendimiento con programación asíncrona
- Gran cantidad de librerías disponibles
- Compatibilidad con FastAPI

#### Framework y Librerías Principales

| Paquete | Versión | Propósito |
|---------|---------|-----------|
| **FastAPI** | 0.115.6 | Framework web asíncrono de alto rendimiento |
| **Uvicorn** | 0.34.0 | Servidor ASGI con soporte para async/await |
| **Pydantic** | 2.10.5 | Validación de datos y serialización |
| **Pydantic Settings** | 2.7.1 | Gestión de configuración y variables de entorno |
| **Python-Jose** | 3.3.0 | Manejo de tokens JWT para autenticación |
| **Passlib** | 1.7.4 | Hash seguro de contraseñas |
| **Python-Multipart** | 0.0.6 | Manejo de formularios y archivos |
| **Python-Dotenv** | 1.0.0 | Carga de variables de entorno desde .env |
| **Requests** | 2.31.0 | Cliente HTTP para consumir APIs externas |
| **Aiofiles** | 23.2.1 | Manejo asíncrono de archivos |
| **Gunicorn** | 21.2.0 | Gestor de procesos para producción |

**Justificación de FastAPI:**
- ⚡ Alto rendimiento (comparable a Node.js y Go)
- 📚 Documentación automática (Swagger/OpenAPI)
- ✅ Validación automática de datos
- 🔄 Soporte nativo para async/await
- 🛡️ Type hints y mejor mantenibilidad

#### Servidor ASGI: Uvicorn

Uvicorn es un servidor ASGI (Asynchronous Server Gateway Interface) optimizado para:
- Manejar conexiones asíncronas
- Alto throughput (miles de requests/segundo)
- Bajo consumo de recursos
- Compatible con WebSockets

**Configuración de producción:**
```bash
uvicorn app.main:app \
  --host 0.0.0.0 \
  --port 8000 \
  --workers 2 \
  --proxy-headers
```

### Frontend (Cliente)

#### Tecnologías Web Estándar

| Tecnología | Versión | Uso |
|------------|---------|-----|
| **HTML5** | - | Estructura del cliente web |
| **CSS3** | - | Estilos y diseño responsive |
| **JavaScript** | ES6+ | Lógica del cliente, peticiones a la API |

**Características implementadas:**
- Variables CSS para theming
- CSS Grid y Flexbox para layouts
- Fetch API para comunicación asíncrona con el backend
- Async/await para manejo de promesas
- Responsive design (compatible con móviles)

### Gestor de Dependencias

**pip** - Gestor oficial de paquetes de Python

El archivo `requirements.txt` especifica todas las dependencias con sus versiones:

```txt
fastapi>=0.109.0
uvicorn[standard]>=0.27.0
pydantic>=2.6.0
...
```

**Instalación:**
```bash
pip install -r requirements.txt
```

---

## 3️⃣ Variables de Entorno Configuradas

Las variables de entorno permiten configurar la aplicación sin modificar el código, separando la configuración del código fuente.

### Entorno de Desarrollo (.env local)

```env
# Configuración del entorno
ENVIRONMENT=development
DEBUG=True

# Servidor
HOST=0.0.0.0
PORT=8000

# Seguridad
SECRET_KEY=dev-secret-key-change-in-production

# CORS - Orígenes permitidos
CORS_ORIGINS=http://localhost:3000,http://localhost:8000
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:8000
```

### Entorno de Producción (Railway/Render)

```env
# Configuración del entorno
ENVIRONMENT=production
DEBUG=False

# Servidor
HOST=0.0.0.0
PORT=${PORT}  # Asignado automáticamente por Railway

# Seguridad
SECRET_KEY=<token-aleatorio-generado-con-secrets.token_urlsafe(32)>

# CORS - Solo origen de producción
CORS_ORIGINS=https://tu-app.up.railway.app
ALLOWED_ORIGINS=https://tu-app.up.railway.app

# Base de datos (si se usa)
DATABASE_URL=postgresql://user:password@host:port/dbname
```

### Descripción de Variables

| Variable | Tipo | Descripción |
|----------|------|-------------|
| `ENVIRONMENT` | String | Entorno de ejecución (development/production) |
| `DEBUG` | Boolean | Modo debug (desactivado en producción) |
| `HOST` | String | IP donde escucha el servidor (0.0.0.0 = todas) |
| `PORT` | Integer | Puerto del servidor (8000 local, variable en producción) |
| `SECRET_KEY` | String | Clave secreta para firmar tokens y sesiones |
| `CORS_ORIGINS` | String (CSV) | Orígenes permitidos para CORS |
| `ALLOWED_ORIGINS` | String (CSV) | Orígenes de confianza |

### Gestión Segura de Secretos

**Desarrollo:**
- Archivo `.env` en local (NO versionado en Git)
- `.env.example` como plantilla (SÍ versionado)

**Producción:**
- Variables configuradas en el Dashboard de Railway
- Nunca expuestas en el código fuente
- Rotación periódica de `SECRET_KEY`

**Generación de SECRET_KEY segura:**
```python
import secrets
secrets.token_urlsafe(32)
# Ejemplo: 'a8f5f167f44f4964e6c998dee827110c'
```

### Carga de Variables en la Aplicación

Utilizamos **Pydantic Settings** para cargar y validar variables:

```python
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    environment: str = "development"
    debug: bool = True
    secret_key: str
    cors_origins: str
    
    class Config:
        env_file = ".env"
```

**Beneficios:**
- ✅ Validación automática de tipos
- ✅ Valores por defecto
- ✅ Documentación integrada
- ✅ Type hints para mejor desarrollo

---

## 4️⃣ Puertos y Servicios Utilizados

### Puerto Principal: 8000

**Servicio:** FastAPI sobre Uvicorn (servidor ASGI)

| Protocolo | Puerto Local | Puerto Producción | Uso |
|-----------|--------------|-------------------|-----|
| HTTP | 8000 | Variable (Railway) | API REST |
| HTTPS | - | 443 (Load Balancer) | Conexiones seguras |

### Endpoints y Servicios Expuestos

#### Endpoints de la API

| Endpoint | Método | Puerto | Descripción |
|----------|--------|--------|-------------|
| `/` | GET | 8000 | Información general de la API |
| `/health` | GET | 8000 | Health check para monitorización |
| `/api/info` | GET | 8000 | Metadatos de la aplicación |
| `/api/items` | GET | 8000 | Lista de items (ejemplo) |
| `/api/items/{id}` | GET | 8000 | Item específico por ID |
| `/docs` | GET | 8000 | Documentación interactiva (dev) |
| `/redoc` | GET | 8000 | Documentación alternativa (dev) |
| `/static/*` | GET | 8000 | Archivos estáticos del cliente |

#### Servicios Auxiliares (Opcionales)

| Servicio | Puerto | Protocolo | Uso |
|----------|--------|-----------|-----|
| PostgreSQL | 5432 | TCP | Base de datos relacional |
| Redis | 6379 | TCP | Caché y sesiones |

### Arquitectura de Red en Producción

```
                    INTERNET
                       │
                       ▼
           ┌───────────────────────┐
           │   Railway CDN/CDN     │
           │   Load Balancer       │
           │   - Puerto 443 (HTTPS)│
           │   - Certificado SSL   │
           └───────────┬───────────┘
                       │
                       ▼
           ┌───────────────────────┐
           │  Contenedor Docker    │
           │                       │
           │  ┌─────────────────┐  │
           │  │ Uvicorn:8000    │  │
           │  │   ▲             │  │
           │  │   │             │  │
           │  │   ▼             │  │
           │  │ FastAPI App     │  │
           │  └─────────────────┘  │
           └───────────────────────┘
                       │
         ┌─────────────┴──────────────┐
         ▼                            ▼
  ┌──────────────┐          ┌──────────────┐
  │ PostgreSQL   │          │   Redis      │
  │ Puerto: 5432 │          │ Puerto: 6379 │
  └──────────────┘          └──────────────┘
```

### Configuración de Firewall y Seguridad

**Railway maneja automáticamente:**
- ✅ Firewall con solo puerto HTTPS expuesto públicamente
- ✅ DDoS protection
- ✅ Rate limiting básico
- ✅ Terminación SSL/TLS

**En el contenedor:**
- Solo puerto 8000 expuesto internamente
- Acceso a bases de datos por red privada interna
- Sin acceso SSH directo (seguridad por diseño)

### Health Check

```python
@app.get("/health")
async def health_check():
    return {
        "status": "healthy",
        "environment": settings.environment,
        "version": "1.0.0"
    }
```

**Uso:**
- Monitorización automática de Railway
- Docker healthcheck
- Alertas ante caídas del servicio

**Configuración Docker:**
```dockerfile
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD python -c "import requests; requests.get('http://localhost:8000/health')"
```

---

## 📊 Resumen de Configuración

| Aspecto | Configuración |
|---------|---------------|
| **Plataforma** | Railway (PaaS) |
| **SO** | Debian 12 (contenedor Docker) |
| **Lenguaje** | Python 3.11+ |
| **Framework** | FastAPI 0.115+ |
| **Servidor** | Uvicorn (ASGI) |
| **Frontend** | HTML5/CSS3/JavaScript |
| **Puerto** | 8000 (interno), 443 (HTTPS externo) |
| **Variables** | Gestionadas con Pydantic Settings |
| **Seguridad** | HTTPS, CORS, headers de seguridad |
| **Documentación** | Swagger UI automática en `/docs` |

---

## ✅ Evidencias

### Capturas de Pantalla

1. **Cliente web funcionando** - `localhost:8000/static/index.html`
2. **Documentación API** - `localhost:8000/docs`
3. **Health check** - `localhost:8000/health`
4. **Estructura de archivos** - Explorador de VS Code

### Pruebas Realizadas

```powershell
# Health Check
PS> Invoke-RestMethod -Uri "http://localhost:8000/health"
status  environment version
------  ----------- -------
healthy development 1.0.0

# API Info
PS> Invoke-RestMethod -Uri "http://localhost:8000/api/info"
name                version description
----                ------- -----------
FastAPI Application 1.0.0   API desarrollada con FastAPI...

# Items
PS> Invoke-RestMethod -Uri "http://localhost:8000/api/items"
items
-----
{@{id=1; name=Item 1}, @{id=2; name=Item 2}, ...}
```

### Archivos Entregables

- ✅ Código fuente completo en `app/`
- ✅ Cliente web en `static/`
- ✅ `Dockerfile` para producción
- ✅ `requirements.txt` con dependencias
- ✅ `.env.example` como plantilla
- ✅ Documentación completa en `docs/`
- ✅ Scripts de inicio/parada

---

## 🎯 Conclusión

Se ha configurado exitosamente un entorno de producción profesional para la aplicación FastAPI, cumpliendo con todos los requisitos solicitados:

✅ **Plataforma**: Railway (PaaS) con contenedor Docker  
✅ **SO**: Debian Linux 12 (Slim)  
✅ **Runtime**: Python 3.11+ con FastAPI y Uvicorn  
✅ **Variables**: Gestionadas de forma segura con Pydantic Settings  
✅ **Puertos**: Puerto 8000 (interno), HTTPS 443 (externo)  
✅ **Frontend**: Cliente HTML/CSS/JS completamente funcional  
✅ **Documentación**: Completa y detallada

La aplicación está lista para ser desplegada a producción en la siguiente fase de la tarea.

---

**Firma:** [Tu nombre]  
**Fecha:** 9 de febrero de 2026
