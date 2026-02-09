# 📂 Índice de Archivos del Proyecto

## 📋 Estructura del Proyecto

```
Tarea_3.1/
│
├── 📄 README.md                      ⭐ Inicio - Lee esto primero
├── 📄 ENTREGA_PARTE1.md              📝 Documento oficial de entrega
├── 📄 COMANDOS.md                    ⚡ Referencia rápida de comandos
│
├── 🚀 start.ps1                      ▶️  Inicia el servidor (recomendado)
├── 🚀 start_server.ps1               ▶️  Inicia el servidor (básico)
├── 🛑 stop.ps1                       ⏹️  Detiene el servidor
│
├── 📦 requirements.txt               📚 Dependencias de Python
├── 🐳 Dockerfile                     🐋 Configuración para producción
├── 🔒 .env                           🔐 Variables de entorno (NO compartir)
├── 📋 .env.example                   📑 Plantilla de variables
├── 🚫 .gitignore                     🙈 Archivos ignorados por Git
│
├── 📁 app/                           💻 Código de la aplicación
│   ├── __init__.py
│   ├── main.py                       ⭐ Punto de entrada FastAPI
│   └── config.py                     ⚙️  Configuración
│
├── 📁 static/                        🌐 Cliente web (frontend)
│   ├── index.html                    📄 Página principal
│   ├── css/
│   │   └── style.css                 🎨 Estilos
│   └── js/
│       └── app.js                    ⚡ Lógica del cliente
│
├── 📁 docs/                          📚 Documentación completa
│   ├── ENTORNO_PRODUCCION.md         📖 Guía detallada del entorno
│   ├── PRUEBAS_LOCALES.md            🧪 Cómo probar localmente
│   └── ESTADO_CONFIGURACION.md       ✅ Estado del proyecto
│
└── 📁 venv/                          🐍 Entorno virtual de Python

```

---

## 🎯 Guía de Navegación Rápida

### 🚀 Para Empezar

1. **Primera vez:**
   ```powershell
   .\start.ps1
   ```
   Este script hace todo automáticamente.

2. **Acceder a la aplicación:**
   - Cliente Web: http://localhost:8000/static/index.html
   - API Docs: http://localhost:8000/docs

### 📖 Para Entender el Proyecto

| Si quieres... | Lee este archivo |
|---------------|------------------|
| Vista general rápida | [README.md](README.md) |
| Detalles para la entrega | [ENTREGA_PARTE1.md](ENTREGA_PARTE1.md) ⭐ |
| Comandos útiles | [COMANDOS.md](COMANDOS.md) |
| Entender la arquitectura | [docs/ENTORNO_PRODUCCION.md](docs/ENTORNO_PRODUCCION.md) |
| Saber cómo probar | [docs/PRUEBAS_LOCALES.md](docs/PRUEBAS_LOCALES.md) |
| Ver el progreso | [docs/ESTADO_CONFIGURACION.md](docs/ESTADO_CONFIGURACION.md) |

### 💻 Para Desarrollar

| Archivo | Propósito |
|---------|-----------|
| [app/main.py](app/main.py) | Agregar nuevos endpoints y lógica |
| [app/config.py](app/config.py) | Modificar configuración |
| [static/index.html](static/index.html) | Cambiar la interfaz web |
| [static/css/style.css](static/css/style.css) | Modificar estilos |
| [static/js/app.js](static/js/app.js) | Añadir funcionalidad JavaScript |

### 🚀 Para Desplegar

| Archivo | Uso |
|---------|-----|
| [Dockerfile](Dockerfile) | Define el contenedor para producción |
| [requirements.txt](requirements.txt) | Lista todas las dependencias |
| [.env.example](.env.example) | Plantilla para variables de entorno |

---

## 📝 Documentos de Entrega

### ✅ Parte 1: Configuración del Entorno (COMPLETADA)

**Documento principal:** [ENTREGA_PARTE1.md](ENTREGA_PARTE1.md)

Este documento incluye:
- ✅ Sistema operativo y plataforma utilizada
- ✅ Lenguajes y runtimes instalados
- ✅ Variables de entorno configuradas
- ✅ Puertos y servicios utilizados
- ✅ Evidencias y capturas

### ⏳ Próximas Partes

- [ ] Parte 2: Despliegue del servidor y cliente
- [ ] Parte 3: Automatización del despliegue (CI/CD)
- [ ] Parte 4: Medidas de seguridad adicionales

---

## 🔍 Archivos Importantes

### No Modificar (Generados)
- `venv/` - Entorno virtual de Python
- `__pycache__/` - Archivos compilados de Python

### No Compartir (Sensibles)
- `.env` - Variables de entorno con secretos
- `*.log` - Archivos de logs

### Sí Compartir (Git)
- Todos los demás archivos excepto los del `.gitignore`

---

## 🆘 ¿Perdido?

1. **¿Primera vez aquí?** → Lee [README.md](README.md)
2. **¿Quieres arrancar el servidor?** → Ejecuta `.\start.ps1`
3. **¿Necesitas comandos?** → Consulta [COMANDOS.md](COMANDOS.md)
4. **¿Problemas?** → Revisa [docs/PRUEBAS_LOCALES.md](docs/PRUEBAS_LOCALES.md)
5. **¿Para la entrega?** → Abre [ENTREGA_PARTE1.md](ENTREGA_PARTE1.md)

---

## 📊 Estado del Proyecto

| Componente | Estado |
|------------|--------|
| Entorno virtual | ✅ Configurado |
| Dependencias | ✅ Instaladas |
| API FastAPI | ✅ Funcionando |
| Cliente Web | ✅ Funcionando |
| Documentación | ✅ Completa |
| Docker | ✅ Configurado |
| Git | ⏳ Pendiente commit |
| Despliegue | ⏳ Parte 2 |

---

**Última actualización:** 9 de febrero de 2026
