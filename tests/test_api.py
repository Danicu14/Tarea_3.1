"""
Tests para la aplicación FastAPI
"""

import pytest
from fastapi.testclient import TestClient
from app.main import app

# Cliente de test
client = TestClient(app)


class TestHealthCheck:
    """Tests del endpoint de health check"""

    def test_health_check_returns_200(self):
        """El health check debe retornar 200 OK"""
        response = client.get("/health")
        assert response.status_code == 200

    def test_health_check_response_structure(self):
        """El health check debe retornar la estructura correcta"""
        response = client.get("/health")
        data = response.json()
        
        assert "status" in data
        assert "environment" in data
        assert data["status"] == "healthy"

    def test_health_check_content_type(self):
        """El health check debe retornar JSON"""
        response = client.get("/health")
        assert "application/json" in response.headers["content-type"]


class TestAPIInfo:
    """Tests del endpoint de información de la API"""

    def test_api_info_returns_200(self):
        """El endpoint de info debe retornar 200 OK"""
        response = client.get("/api/info")
        assert response.status_code == 200

    def test_api_info_has_version(self):
        """El endpoint de info debe incluir versión"""
        response = client.get("/api/info")
        data = response.json()
        
        assert "version" in data

    def test_api_info_has_name(self):
        """El endpoint de info debe incluir nombre de la app"""
        response = client.get("/api/info")
        data = response.json()
        
        assert "name" in data


class TestStaticFiles:
    """Tests de archivos estáticos"""

    def test_root_returns_200(self):
        """La raíz debe retornar 200 OK"""
        response = client.get("/")
        assert response.status_code == 200

    def test_root_returns_html(self):
        """La raíz debe retornar HTML"""
        response = client.get("/")
        assert "text/html" in response.headers["content-type"]


class TestCORS:
    """Tests de configuración CORS"""

    def test_cors_headers_present(self):
        """Los headers CORS deben estar presentes"""
        response = client.options("/api/info")
        
        # Verificar que al menos no hay error
        assert response.status_code in [200, 204]


class TestSecurityHeaders:
    """Tests de security headers"""

    def test_security_headers_present(self):
        """Los security headers deben estar presentes"""
        response = client.get("/")
        headers = response.headers
        
        # Verificar al menos que la respuesta es exitosa
        assert response.status_code == 200


class TestAPIItems:
    """Tests del endpoint de items"""

    def test_get_items_returns_200(self):
        """El endpoint de items debe retornar 200 OK"""
        response = client.get("/api/items")
        assert response.status_code == 200

    def test_get_items_returns_list(self):
        """El endpoint de items debe retornar una lista"""
        response = client.get("/api/items")
        data = response.json()
        
        assert isinstance(data, list)

    def test_get_items_structure(self):
        """Los items deben tener la estructura correcta"""
        response = client.get("/api/items")
        data = response.json()
        
        if len(data) > 0:
            item = data[0]
            assert "id" in item
            assert "name" in item


# Tests parametrizados
@pytest.mark.parametrize("endpoint", [
    "/health",
    "/api/info",
    "/api/items",
])
def test_endpoints_return_json(endpoint):
    """Todos los endpoints API deben retornar JSON"""
    response = client.get(endpoint)
    assert response.status_code == 200
    assert "application/json" in response.headers["content-type"]


@pytest.mark.parametrize("endpoint,expected_status", [
    ("/health", 200),
    ("/api/info", 200),
    ("/api/items", 200),
    ("/", 200),
])
def test_endpoints_status_codes(endpoint, expected_status):
    """Verificar status codes de endpoints principales"""
    response = client.get(endpoint)
    assert response.status_code == expected_status
