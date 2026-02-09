// Cliente JavaScript para interactuar con la API FastAPI

// Configuración de la API
const API_BASE_URL = window.location.origin;

// Utilidad para hacer peticiones fetch
async function fetchAPI(endpoint, options = {}) {
    try {
        const response = await fetch(`${API_BASE_URL}${endpoint}`, {
            ...options,
            headers: {
                'Content-Type': 'application/json',
                ...options.headers,
            },
        });

        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }

        return await response.json();
    } catch (error) {
        console.error('Error en la petición:', error);
        throw error;
    }
}

// Cargar información de la API
async function loadAPIInfo() {
    const container = document.getElementById('api-info-container');
    container.innerHTML = '<div class="loading"></div> Cargando...';

    try {
        const data = await fetchAPI('/api/info');
        container.innerHTML = `
            <div class="api-info-details">
                <p><strong>📛 Nombre:</strong> ${data.name}</p>
                <p><strong>📦 Versión:</strong> ${data.version}</p>
                <p><strong>📝 Descripción:</strong> ${data.description}</p>
                <p><strong>🌍 Entorno:</strong> <span style="color: ${data.environment === 'production' ? '#4CAF50' : '#FF9800'}">${data.environment}</span></p>
            </div>
        `;
    } catch (error) {
        container.innerHTML = `
            <div style="color: var(--error-color);">
                ❌ Error al cargar la información de la API
            </div>
        `;
    }
}

// Cargar items
async function loadItems() {
    const container = document.getElementById('items-container');
    container.innerHTML = '<div class="loading"></div> Cargando items...';

    try {
        const data = await fetchAPI('/api/items');
        
        if (data.items && data.items.length > 0) {
            container.innerHTML = data.items.map(item => `
                <div class="item-card">
                    <h3>🔹 ${item.name}</h3>
                    <p><strong>ID:</strong> ${item.id}</p>
                </div>
            `).join('');
        } else {
            container.innerHTML = '<p>No hay items disponibles</p>';
        }
    } catch (error) {
        container.innerHTML = `
            <div style="color: var(--error-color);">
                ❌ Error al cargar los items
            </div>
        `;
    }
}

// Verificar salud del servidor
async function checkHealth() {
    const container = document.getElementById('health-container');
    container.innerHTML = '<div class="loading"></div> Verificando...';

    try {
        const data = await fetchAPI('/health');
        
        container.innerHTML = `
            <div class="health-status">
                <div class="health-indicator"></div>
                <strong>Estado:</strong> ${data.status}
            </div>
            <div class="health-status">
                <strong>🌍 Entorno:</strong> ${data.environment}
            </div>
            <div class="health-status">
                <strong>📦 Versión:</strong> ${data.version}
            </div>
            <p style="color: var(--success-color); margin-top: 10px;">✅ El servidor está funcionando correctamente</p>
        `;
    } catch (error) {
        container.innerHTML = `
            <div style="color: var(--error-color);">
                <div class="health-status">
                    <div class="health-indicator" style="background-color: var(--error-color);"></div>
                    <strong>Estado:</strong> Error
                </div>
                <p>❌ No se pudo conectar con el servidor</p>
            </div>
        `;
    }
}

// Event Listeners
document.addEventListener('DOMContentLoaded', () => {
    // Cargar información de la API al inicio
    loadAPIInfo();

    // Botón para cargar items
    const loadItemsBtn = document.getElementById('load-items');
    if (loadItemsBtn) {
        loadItemsBtn.addEventListener('click', loadItems);
    }

    // Botón para verificar salud
    const checkHealthBtn = document.getElementById('check-health');
    if (checkHealthBtn) {
        checkHealthBtn.addEventListener('click', checkHealth);
    }

    console.log('✅ Cliente inicializado correctamente');
    console.log('🔗 API Base URL:', API_BASE_URL);
});
