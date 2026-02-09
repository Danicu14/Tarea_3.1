# 🐳 Guía Docker - Comandos y Uso

## 🚀 Inicio Rápido

### Construir Imagen de Producción
```powershell
docker build -t fastapi-app:prod -f Dockerfile .
```

### Ejecutar Contenedor
```powershell
docker run -d -p 8000:8000 --name fastapi-container fastapi-app:prod
```

### Acceder a la aplicación
```
http://localhost:8000
```

---

## 📦 Comandos Docker Esenciales

### Construcción

```powershell
# Imagen de PRODUCCIÓN (optimizada)
docker build -t fastapi-app:prod -f Dockerfile .

# Imagen de DESARROLLO (con herramientas)
docker build -t fastapi-app:dev -f Dockerfile.dev .

# Build forzando sin cache (para testing)
docker build --no-cache -t fastapi-app:prod .

# Ver progreso detallado
docker build --progress=plain -t fastapi-app:prod .
```

### Ejecución

```powershell
# Ejecutar en background (daemon)
docker run -d -p 8000:8000 --name fastapi-container fastapi-app:prod

# Ejecutar en foreground (ver logs directamente)
docker run -p 8000:8000 --name fastapi-container fastapi-app:prod

# Con variables de entorno
docker run -d -p 8000:8000 `
  -e ENVIRONMENT=production `
  -e DEBUG=False `
  --name fastapi-container fastapi-app:prod

# Con archivo .env
docker run -d -p 8000:8000 --env-file .env --name fastapi-container fastapi-app:prod

# Con volúmenes montados (para desarrollo)
docker run -d -p 8000:8000 `
  -v ${PWD}/app:/app/app `
  --name fastapi-container fastapi-app:dev
```

### Gestión de Contenedores

```powershell
# Listar contenedores en ejecución
docker ps

# Listar todos los contenedores (incluso detenidos)
docker ps -a

# Ver logs
docker logs fastapi-container

# Ver logs en tiempo real
docker logs -f fastapi-container

# Detener contenedor
docker stop fastapi-container

# Iniciar contenedor detenido
docker start fastapi-container

# Reiniciar contenedor
docker restart fastapi-container

# Eliminar contenedor
docker rm fastapi-container

# Eliminar contenedor en ejecución (forzar)
docker rm -f fastapi-container
```

### Inspección

```powershell
# Ver detalles del contenedor
docker inspect fastapi-container

# Ver estadísticas de recursos (CPU, RAM)
docker stats fastapi-container

# Ver procesos en el contenedor
docker top fastapi-container

# Ejecutar comando dentro del contenedor
docker exec fastapi-container python --version

# Abrir shell interactiva
docker exec -it fastapi-container /bin/bash

# Ver logs de healthcheck
docker inspect --format='{{json .State.Health}}' fastapi-container
```

### Imágenes

```powershell
# Listar imágenes
docker images

# Ver tamaño de imagen
docker images fastapi-app:prod

# Ver capas de la imagen
docker history fastapi-app:prod

# Ver capas con tamaños
docker history --human fastapi-app:prod

# Eliminar imagen
docker rmi fastapi-app:prod

# Limpiar imágenes no usadas
docker image prune

# Limpiar TODO (imágenes, contenedores, volúmenes)
docker system prune -a
```

---

## 🔧 Docker Compose

### Desarrollo (docker-compose.yml)

```powershell
# Iniciar servicios en background
docker-compose up -d

# Iniciar viendo logs
docker-compose up

# Ver logs de un servicio específico
docker-compose logs api

# Logs en tiempo real
docker-compose logs -f api

# Detener servicios
docker-compose down

# Detener y eliminar volúmenes
docker-compose down -v

# Reconstruir imágenes
docker-compose build

# Reconstruir sin cache
docker-compose build --no-cache

# Listar servicios
docker-compose ps
```

### Producción (docker-compose.prod.yml)

```powershell
# Iniciar con archivo específico
docker-compose -f docker-compose.prod.yml up -d

# Detener
docker-compose -f docker-compose.prod.yml down

# Ver logs
docker-compose -f docker-compose.prod.yml logs -f
```

---

## 🧪 Testing y Verificación

### Verificar que funciona

```powershell
# Health check
curl http://localhost:8000/health
# O con PowerShell
Invoke-RestMethod -Uri "http://localhost:8000/health"

# API info
curl http://localhost:8000/api/info

# Ver respuesta del servidor
curl -v http://localhost:8000/
```

### Comparar tamaños

```powershell
# Tamaño imagen producción
docker images fastapi-app:prod --format "{{.Size}}"

# Tamaño imagen desarrollo
docker images fastapi-app:dev --format "{{.Size}}"

# Diferencia
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
```

### Escanear seguridad

```powershell
# Con Docker scan (requiere login)
docker scan fastapi-app:prod

# Con Trivy (más completo)
docker run aquasec/trivy image fastapi-app:prod
```

---

## 🎯 Workflows Comunes

### Desarrollo Local con Docker

```powershell
# 1. Construir imagen de desarrollo
docker build -t fastapi-app:dev -f Dockerfile.dev .

# 2. Ejecutar con hot-reload
docker run -d -p 8000:8000 `
  -v ${PWD}/app:/app/app `
  -v ${PWD}/static:/app/static `
  --name fastapi-dev fastapi-app:dev

# 3. Ver logs
docker logs -f fastapi-dev

# 4. Cuando termines
docker stop fastapi-dev
docker rm fastapi-dev
```

### Testing de Imagen de Producción

```powershell
# 1. Construir
docker build -t fastapi-app:prod .

# 2. Ejecutar
docker run -d -p 8000:8000 --name fastapi-test fastapi-app:prod

# 3. Probar
Invoke-RestMethod -Uri "http://localhost:8000/health"

# 4. Ver tamaño
docker images fastapi-app:prod

# 5. Limpiar
docker stop fastapi-test
docker rm fastapi-test
```

### Actualización de Código

```powershell
# 1. Detener contenedor actual
docker stop fastapi-container

# 2. Reconstruir imagen con cambios
docker build -t fastapi-app:prod .

# 3. Eliminar contenedor viejo
docker rm fastapi-container

# 4. Iniciar con nueva imagen
docker run -d -p 8000:8000 --name fastapi-container fastapi-app:prod
```

---

## 🐛 Troubleshooting

### Problema: Puerto ya en uso

```
Error: bind: address already in use
```

**Solución:**
```powershell
# Encontrar proceso en puerto 8000
Get-NetTCPConnection -LocalPort 8000

# Matar contenedor usando ese puerto
docker ps
docker stop <container-id>
```

### Problema: Build falla

```
Error: failed to compute cache key
```

**Solución:**
```powershell
# Limpiar cache de Docker
docker builder prune

# Build sin cache
docker build --no-cache -t fastapi-app:prod .
```

### Problema: Contenedor se detiene inmediatamente

```powershell
# Ver logs para identificar el error
docker logs fastapi-container

# Ver exit code
docker ps -a
```

### Problema: Dependencias no se encuentran

```
ModuleNotFoundError: No module named 'fastapi'
```

**Solución:**
```powershell
# Verificar que se copió requirements-prod.txt
docker run --rm fastapi-app:prod ls -la /install

# Reconstruir forzando
docker build --no-cache -t fastapi-app:prod .
```

---

## 📊 Comparación de Imágenes

### Script de Comparación

```powershell
# Construir ambas versiones
docker build -t fastapi-app:prod -f Dockerfile .
docker build -t fastapi-app:dev -f Dockerfile.dev .

# Comparar tamaños
Write-Host "Imagen de Producción:"
docker images fastapi-app:prod --format "Size: {{.Size}}"

Write-Host "Imagen de Desarrollo:"
docker images fastapi-app:dev --format "Size: {{.Size}}"

# Ver capas
Write-Host "`nCapas de Producción:"
docker history fastapi-app:prod --human --format "{{.Size}}`t{{.CreatedBy}}"
```

---

## 🎨 Alias Útiles (PowerShell)

Agregar a tu `$PROFILE`:

```powershell
# Alias Docker
function dps { docker ps $args }
function dpsa { docker ps -a $args }
function dim { docker images $args }
function dlog { docker logs -f $args }
function dexec { docker exec -it $args /bin/bash }
function dstop { docker stop $args }
function drm { docker rm $args }
function drmi { docker rmi $args }

# Alias proyecto
function fastapi-build { docker build -t fastapi-app:prod . }
function fastapi-run { docker run -d -p 8000:8000 --name fastapi-container fastapi-app:prod }
function fastapi-stop { docker stop fastapi-container; docker rm fastapi-container }
function fastapi-logs { docker logs -f fastapi-container }
```

Usar:
```powershell
fastapi-build
fastapi-run
fastapi-logs
```

---

## 🚀 Para Railway/Producción

Railway detecta automáticamente el Dockerfile y lo construye.

**Lo que hace Railway:**
```bash
# Railway ejecuta esto automáticamente
docker build -t app .
docker run -p $PORT:8000 app
```

**Variables de entorno en Railway:**
- Se configuran en el Dashboard
- Railway inyecta `$PORT` automáticamente
- No necesitas `docker run` manual

---

## 📚 Recursos

- [Docker Docs](https://docs.docker.com/)
- [Dockerfile Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [Docker Compose Docs](https://docs.docker.com/compose/)

---

**Próximo paso:** Desplegar a Railway 🚀
