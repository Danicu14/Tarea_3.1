# 🧪 Guía de Pruebas Locales

## Antes de Desplegar a Producción

Esta guía te ayuda a probar todo localmente antes de desplegar.

## 📋 Prerrequisitos

```bash
# Verificar Python
python --version
# Debe ser Python 3.11 o superior

# Verificar pip
pip --version
```

## 🚀 Instalación y Configuración

### 1. Crear Entorno Virtual

```bash
# Windows
python -m venv venv
venv\Scripts\activate

# Linux/Mac
python3 -m venv venv
source venv/bin/activate
```

### 2. Instalar Dependencias

```bash
pip install -r requirements.txt
```

### 3. Configurar Variables de Entorno

```bash
# Copiar el archivo de ejemplo
copy .env.example .env    # Windows
cp .env.example .env      # Linux/Mac

# Editar .env con tus valores
# Usar tu editor favorito
```

## ▶️ Ejecutar la Aplicación

### Modo Desarrollo (con auto-reload)

```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### Modo Producción (simulado localmente)

```bash
# Cambiar en .env:
# ENVIRONMENT=production
# DEBUG=False

uvicorn app.main:app --host 0.0.0.0 --port 8000 --workers 2
```

## 🧪 Probar Endpoints

### Opción 1: Navegador
```
http://localhost:8000/           # Página principal
http://localhost:8000/health     # Health check
http://localhost:8000/api/info   # Información de la API
http://localhost:8000/docs       # Documentación interactiva (solo desarrollo)
```

### Opción 2: cURL

```bash
# Health check
curl http://localhost:8000/health

# API info
curl http://localhost:8000/api/info

# Get items
curl http://localhost:8000/api/items

# Get item específico
curl http://localhost:8000/api/items/1
```

### Opción 3: PowerShell

```powershell
# Health check
Invoke-WebRequest -Uri "http://localhost:8000/health" | Select-Object -Expand Content

# API info
Invoke-RestMethod -Uri "http://localhost:8000/api/info"

# Items
Invoke-RestMethod -Uri "http://localhost:8000/api/items"
```

## 🐳 Probar con Docker (Opcional)

### Construir imagen

```bash
docker build -t fastapi-app .
```

### Ejecutar contenedor

```bash
docker run -d -p 8000:8000 --name fastapi-container fastapi-app
```

### Ver logs

```bash
docker logs fastapi-container
```

### Detener y limpiar

```bash
docker stop fastapi-container
docker rm fastapi-container
```

## ✅ Checklist de Pruebas

- [ ] La aplicación inicia sin errores
- [ ] El endpoint `/` devuelve información correcta
- [ ] El endpoint `/health` devuelve `{"status": "healthy"}`
- [ ] El endpoint `/api/info` devuelve metadatos de la API
- [ ] El endpoint `/api/items` devuelve lista de items
- [ ] La página web cliente carga en `/static/index.html`
- [ ] Los botones del cliente funcionan correctamente
- [ ] No hay errores en la consola del navegador
- [ ] No hay errores en los logs del servidor
- [ ] Las variables de entorno se cargan correctamente

## 🐛 Problemas Comunes

### Puerto 8000 ya en uso

```bash
# Windows - encontrar y matar proceso
netstat -ano | findstr :8000
taskkill /PID <PID> /F

# Linux/Mac
lsof -ti:8000 | xargs kill -9
```

### Módulos no encontrados

```bash
# Verificar que el entorno virtual está activado
# Reinstalar dependencias
pip install -r requirements.txt --force-reinstall
```

### Error al importar app.main

```bash
# Asegúrate de estar en el directorio raíz del proyecto
# Verifica que existe app/__init__.py
```

## 📊 Verificar Rendimiento

### Tiempo de respuesta

```bash
# Windows PowerShell
Measure-Command { Invoke-WebRequest -Uri "http://localhost:8000/health" }

# Linux/Mac
time curl http://localhost:8000/health
```

### Múltiples peticiones concurrentes

Puedes usar herramientas como:
- **Apache Bench (ab)**
  ```bash
  ab -n 1000 -c 10 http://localhost:8000/health
  ```
- **wrk** (Linux/Mac)
  ```bash
  wrk -t4 -c100 -d30s http://localhost:8000/health
  ```

## 🎯 Próximos Pasos

Una vez que todo funcione correctamente en local:

1. ✅ Commit a Git
2. ✅ Push a GitHub
3. ✅ Desplegar a Railway/Render
4. ✅ Configurar variables de entorno en producción
5. ✅ Verificar que funciona en producción

---

**¡Listo para producción!** 🚀
