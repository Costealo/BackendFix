# 🚨 Actualización Importante: Nuevo Puerto del Backend

Hola,

Hemos realizado una actualización en la configuración del backend para resolver conflictos de puertos locales. Por favor, actualiza tu configuración de conexión en el frontend:

- **Anterior:** `http://localhost:8080` ❌ (Ya no funciona)
- **Nuevo:** `http://localhost:5200` ✅

### 🛠️ Acción Requerida
Busca donde defines la `BASE_URL` de la API en tu proyecto (probablemente en un archivo de constantes, `.env`, o servicio de API) y cámbialo a:

```javascript
const BASE_URL = "http://localhost:5200";
```

**Nota:** Esto solo afecta la conexión local entre tu frontend y el backend. La base de datos sigue estando en Azure, por lo que tus datos persisten.

¡Gracias!
