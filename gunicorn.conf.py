"""
Configuración de Gunicorn para producción
FastAPI con workers Uvicorn
"""

import multiprocessing
import os

# ========================================
# BIND
# ========================================

# Puerto interno (Nginx hace proxy a este puerto)
bind = "127.0.0.1:8001"

# ========================================
# WORKERS
# ========================================

# Número de workers: (2 x CPU cores) + 1
# Railway típicamente da 1-2 vCPUs, así que 3-5 workers
workers = int(os.getenv("GUNICORN_WORKERS", multiprocessing.cpu_count() * 2 + 1))

# Tipo de worker: Uvicorn para FastAPI (ASGI)
worker_class = "uvicorn.workers.UvicornWorker"

# Threads por worker (solo si worker_class lo soporta)
threads = 1

# ========================================
# WORKER MANAGEMENT
# ========================================

# Reiniciar workers después de N requests (previene memory leaks)
max_requests = 1000
max_requests_jitter = 50  # Randomización para evitar restart simultáneo

# Timeout: 30s para requests normales
timeout = 30

# Graceful timeout: tiempo para terminar requests existentes
graceful_timeout = 30

# Keep-alive: mantener conexiones abiertas 2 segundos
keepalive = 2

# ========================================
# LOGGING
# ========================================

# Nivel de log
loglevel = os.getenv("LOG_LEVEL", "info")

# Access log
accesslog = "-"  # stdout
access_log_format = '%(h)s %(l)s %(u)s %(t)s "%(r)s" %(s)s %(b)s "%(f)s" "%(a)s" %(D)s'

# Error log
errorlog = "-"  # stderr

# ========================================
# PROCESS NAMING
# ========================================

proc_name = "gunicorn_fastapi"

# ========================================
# SERVER MECHANICS
# ========================================

# Daemon mode: No (Railway ejecuta en foreground)
daemon = False

# PID file
pidfile = None

# User/Group (correr como usuario no privilegiado)
# user = "nobody"
# group = "nogroup"

# ========================================
# HOOKS
# ========================================

def on_starting(server):
    """Se ejecuta cuando el servidor maestro arranca"""
    server.log.info("Gunicorn iniciando con %d workers", workers)

def on_reload(server):
    """Se ejecuta cuando se recarga la configuración"""
    server.log.info("Gunicorn recargando configuración")

def when_ready(server):
    """Se ejecuta cuando el servidor está listo para recibir requests"""
    server.log.info("Gunicorn listo para recibir conexiones en %s", bind)

def worker_int(worker):
    """Se ejecuta cuando un worker recibe SIGINT o SIGQUIT"""
    worker.log.info("Worker recibió señal de terminación")

def pre_fork(server, worker):
    """Se ejecuta antes de hacer fork de un worker"""
    pass

def post_fork(server, worker):
    """Se ejecuta después de hacer fork de un worker"""
    server.log.info("Worker spawned (pid: %s)", worker.pid)

def pre_exec(server):
    """Se ejecuta antes de ejecutar un nuevo binario"""
    server.log.info("Forked child, re-executing.")

def worker_exit(server, worker):
    """Se ejecuta cuando un worker termina"""
    server.log.info("Worker exiting (pid: %s)", worker.pid)

def child_exit(server, worker):
    """Se ejecuta en el proceso maestro cuando muere un worker hijo"""
    pass

def on_exit(server):
    """Se ejecuta cuando el servidor maestro se apaga"""
    server.log.info("Gunicorn terminando")

# ========================================
# SECURITY
# ========================================

# Limitar el tamaño del header
limit_request_line = 4094
limit_request_fields = 100
limit_request_field_size = 8190

# ========================================
# PERFORMANCE TUNING
# ========================================

# Worker temp directory (usar memoria para mejor performance en Railway)
worker_tmp_dir = "/dev/shm" if os.path.exists("/dev/shm") else None

# Preload app (cargar código antes de fork)
# Reduce memoria pero hace reloads más lentos
preload_app = True
