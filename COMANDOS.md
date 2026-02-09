# ⚡ Comandos Rápidos - Guía de Referencia

## 🚀 Iniciar Servidor

### Opción 1: Script Automático (Recomendado)
```powershell
.\start.ps1
```
Este script:
- ✅ Crea el entorno virtual si no existe
- ✅ Activa el entorno virtual
- ✅ Instala dependencias si faltan
- ✅ Copia `.env.example` a `.env` si no existe
- ✅ Inicia el servidor con auto-reload

### Opción 2: Manual
```powershell
# Activar entorno virtual
.\venv\Scripts\Activate.ps1

# Iniciar servidor
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

---

## 🛑 Detener Servidor

### Opción 1: Script Automático
```powershell
.\stop.ps1
```

### Opción 2: Manual
```
Presionar Ctrl+C en la ventana donde está corriendo
```

---

## 📦 Gestión de Dependencias

### Ver dependencias instaladas
```powershell
pip list
```

### Analizar dependencias (Parte 2)
```powershell
# Comparar producción vs desarrollo
.\analyze-deps.ps1

# Probar configuración de producción
.\test-prod-deps.ps1
```

### Instalar solo dependencias de PRODUCCIÓN
```powershell
pip install -r requirements-prod.txt
```

### Instalar dependencias de DESARROLLO (incluye producción)
```powershell
pip install -r requirements-dev.txt
```

### Agregar nueva dependencia
```powershell
# Instalar
pip install nombre-paquete

# Actualizar requirements según el tipo
pip freeze | grep nombre-paquete >> requirements-prod.txt  # Si es de producción
pip freeze | grep nombre-paquete >> requirements-dev.txt   # Si es de desarrollo
```

### Ver dependencias instaladas
```powershell
pip list
```

### Ver dependencias desactualizadas  
```powershell
pip list --outdated
```

### Actualizar dependencias
```powershell
pip install --upgrade -r requirements.txt
```

---

## 🐳 Docker (Parte 2)

### Construir imágenes

```powershell
# Imagen de PRODUCCIÓN (optimizada, multi-stage)
docker build -t fastapi-app:prod .

# Imagen de DESARROLLO (con herramientas)
docker build -t fastapi-app:dev -f Dockerfile.dev .

# Script automático de build y test
.\docker-build.ps1
```

### Ejecutar contenedores

```powershell
# Producción
docker run -d -p 8000:8000 --name fastapi-app fastapi-app:prod

# Desarrollo (con hot-reload)
docker run -d -p 8000:8000 `
  -v ${PWD}/app:/app/app `
  --name fastapi-app fastapi-app:dev
```

### Docker Compose

```powershell
# Desarrollo
docker-compose up -d

# Producción
docker-compose -f docker-compose.prod.yml up -d

# Ver logs
docker-compose logs -f

# Detener
docker-compose down
```

### Gestión de contenedores

```powershell
# Listar contenedores
docker ps

# Ver logs
docker logs -f fastapi-app

# Detener y eliminar
docker stop fastapi-app
docker rm fastapi-app

# Limpiar todo
docker system prune -a
```

### Inspección

```powershell
# Ver tamaño de imagen
docker images fastapi-app:prod

# Ver capas de la imagen
docker history fastapi-app:prod

# Ver estadísticas
docker stats fastapi-app
```

---

## 🧪 Probar la Aplicación

### Desde el navegador
```
🌐 Cliente web: http://localhost:8000/static/index.html
📚 Documentación interactiva: http://localhost:8000/docs
```

### Desde PowerShell
```powershell
# Health check
Invoke-RestMethod -Uri "http://localhost:8000/health"

# API Info
Invoke-RestMethod -Uri "http://localhost:8000/api/info"

# Items
Invoke-RestMethod -Uri "http://localhost:8000/api/items"

# Item específico
Invoke-RestMethod -Uri "http://localhost:8000/api/items/1"
```

### Desde cURL (si lo tienes instalado)
```bash
curl http://localhost:8000/health
curl http://localhost:8000/api/info
curl http://localhost:8000/api/items
```

---

## 🐳 Docker (Producción)

### Construir imagen
```powershell
docker build -t fastapi-app .
```

### Ejecutar contenedor
```powershell
docker run -d -p 8000:8000 --name fastapi-app-container fastapi-app
```

### Ver logs
```powershell
docker logs fastapi-app-container
```

### Detener contenedor
```powershell
docker stop fastapi-app-container
docker rm fastapi-app-container
```

---

## 📝 Git

### Commit inicial
```powershell
git init
git add .
git commit -m "Initial commit: FastAPI app configurada"
```

### Push a GitHub
```powershell
# Crear repositorio en GitHub primero, luego:
git remote add origin https://github.com/tu-usuario/tu-repo.git
git branch -M main
git push -u origin main
```

---

## 🚀 Despliegue a Railway

### Opción 1: Desde GitHub (Recomendado)
1. Push a GitHub (ver arriba)
2. Ir a [railway.app](https://railway.app)
3. New Project → Deploy from GitHub repo
4. Seleccionar tu repositorio
5. Configurar variables de entorno
6. Deploy automático

### Opción 2: Railway CLI
```powershell
# Instalar Railway CLI (requiere Node.js)
npm install -g @railway/cli

# Login
railway login

# Inicializar proyecto
railway init

# Desplegar
railway up

# Ver logs
railway logs

# Abrir en navegador
railway open
```

---

## 🔧 Troubleshooting

### Puerto 8000 ocupado
```powershell
# Ver qué proceso usa el puerto
Get-NetTCPConnection -LocalPort 8000 | Select-Object OwningProcess

# Matar proceso por PID
Stop-Process -Id <PID> -Force

# O usar el script
.\stop.ps1
```

### Módulos no encontrados
```powershell
# Asegurarte de estar en el entorno virtual
.\venv\Scripts\Activate.ps1

# Reinstalar dependencias
pip install -r requirements.txt --force-reinstall
```

### Error al crear entorno virtual
```powershell
# Verificar versión de Python
python --version

# Debe ser 3.11 o superior
# Si no, descargar de python.org
```

### CORS errors en producción
```powershell
# Editar .env y agregar el dominio de producción
CORS_ORIGINS=https://tu-app.railway.app,http://localhost:8000
```

---

## 📚 Archivos Importantes

| Archivo | Descripción |
|---------|-------------|
| `app/main.py` | Punto de entrada de la aplicación |
| `app/config.py` | Configuración y variables de entorno |
| `requirements.txt` | Dependencias de Python |
| `.env` | Variables de entorno (NO commitear) |
| `Dockerfile` | Configuración para producción |
| `README.md` | Documentación principal |

---

## 🎯 URLs Útiles (Servidor Local)

| Recurso | URL |
|---------|-----|
| **Cliente Web** | http://localhost:8000/static/index.html |
| **API Docs (Swagger)** | http://localhost:8000/docs |
| **API Docs (ReDoc)** | http://localhost:8000/redoc |
| **Health Check** | http://localhost:8000/health |
| **API Info** | http://localhost:8000/api/info |
| **Items** | http://localhost:8000/api/items |

---

## 💡 Tips

### Ver logs en tiempo real
```powershell
# Si usas el script start.ps1, los logs se muestran automáticamente
# Si ejecutas manualmente, también aparecen en la consola
```

### Auto-reload durante desarrollo
El flag `--reload` hace que el servidor se reinicie automáticamente cuando detecta cambios en el código.

### Testing rápido
Usa `/docs` para probar todos los endpoints de forma interactiva sin necesidad de Postman.

---

## 📞 Ayuda

- 📖 [Documentación FastAPI](https://fastapi.tiangolo.com/)
- 🐳 [Docker docs](https://docs.docker.com/)
- 🚂 [Railway docs](https://docs.railway.app/)
- 📚 [Ver docs/ENTORNO_PRODUCCION.md](docs/ENTORNO_PRODUCCION.md) para más detalles
