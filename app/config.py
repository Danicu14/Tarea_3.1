"""
Configuración de la aplicación usando Pydantic Settings
Carga variables de entorno de forma segura
"""
from pydantic_settings import BaseSettings
from typing import List
from functools import lru_cache


class Settings(BaseSettings):
    """Configuración de la aplicación"""
    
    # Entorno
    environment: str = "development"
    debug: bool = True
    
    # Servidor
    host: str = "0.0.0.0"
    port: int = 8000
    
    # Seguridad
    secret_key: str = "change-this-secret-key-in-production"
    allowed_origins: str = "http://localhost:3000,http://localhost:8000"
    
    # CORS
    cors_origins: str = "http://localhost:3000,http://localhost:8000"
    
    # API
    api_title: str = "FastAPI Application"
    api_version: str = "1.0.0"
    api_description: str = "API desarrollada con FastAPI para producción"
    
    # Base de datos (opcional)
    database_url: str = "sqlite:///./app.db"
    
    @property
    def cors_origins_list(self) -> List[str]:
        """Convierte string de orígenes CORS en lista"""
        return [origin.strip() for origin in self.cors_origins.split(",")]
    
    @property
    def allowed_origins_list(self) -> List[str]:
        """Convierte string de orígenes permitidos en lista"""
        return [origin.strip() for origin in self.allowed_origins.split(",")]
    
    class Config:
        env_file = ".env"
        case_sensitive = False


@lru_cache()
def get_settings() -> Settings:
    """
    Retorna instancia singleton de configuración
    El decorador lru_cache asegura que solo se crea una instancia
    """
    return Settings()


# Instancia global de configuración
settings = get_settings()
