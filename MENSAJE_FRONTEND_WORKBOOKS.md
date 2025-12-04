# 📨 Mensaje para el Frontend - Workbooks (Planillas) con Status

Hola equipo! 👋

## ✅ Implementación Completa

Ahora **Workbooks (Planillas)** funciona **EXACTAMENTE igual** que PriceDatabase (Bases de datos) con el soporte de status Draft/Published.

## 🔧 Endpoints Actualizados

### 1. Crear Planilla con Status
**Endpoint:** `POST /api/Workbooks`

```json
// Crear como BORRADOR
{
  "name": "Mi Planilla",
  "productionUnits": 10,
  "profitMarginPercentage": 0.20,
  "status": 0  // 0 = Borrador
}

// Crear como PUBLICADA
{
  "name": "Mi Planilla",
  "productionUnits": 10,
  "profitMarginPercentage": 0.20,
  "status": 1  // 1 = Publicada
}

// Si NO envían "status", se crea como Borrador (0) por defecto
{
  "name": "Mi Planilla",
  "productionUnits": 10
}
```

### 2. Actualizar Status con PUT
**Endpoint:** `PUT /api/Workbooks/{id}`

```json
// Cambiar de Publicada a Borrador
{
  "name": "Mi Planilla",
  "productionUnits": 10,
  "profitMarginPercentage": 0.20,
  "status": 0  // Vuelve a Borrador
}

// Cambiar de Borrador a Publicada
{
  "name": "Mi Planilla",
  "productionUnits": 10,
  "profitMarginPercentage": 0.20,
  "status": 1  // Se publica
}
```

### 3. Publicar con Endpoint Dedicado (Opcional)
**Endpoint:** `PUT /api/Workbooks/{id}/publish`

```javascript
// No necesita body, solo cambia status a Published (1)
await api.put(`/api/Workbooks/${id}/publish`, {}, {
  headers: { Authorization: `Bearer ${token}` }
});
```

## 📋 Flujo Frontend (Dashboard de Planillas)

### Al Crear Nueva Planilla:
```javascript
// Cuando presionan "Guardar como borrador"
const workbookData = {
  name: name,
  productionUnits: units,
  profitMarginPercentage: margin,
  status: 0  // ← Borrador
};

// Cuando presionan "Publicar" directamente
const workbookData = {
  name: name,
  productionUnits: units,
  profitMarginPercentage: margin,
  status: 1  // ← Publicada
};
```

### Al Editar Planilla Existente:
```javascript
// Cambiar de Publicada a Borrador
const updateData = {
  name: workbook.name,
  productionUnits: workbook.productionUnits,
  profitMarginPercentage: workbook.profitMarginPercentage,
  status: 0  // ← Vuelve a borradores
};

// O usar el endpoint dedicado para publicar
await api.put(`/api/Workbooks/${id}/publish`);
```

### Filtrar en la UI:
```javascript
// Obtener todas las planillas
const workbooks = await api.get('/api/Workbooks');

// Sección "Borradores"
const borradores = workbooks.data.filter(w => w.status === 0);

// Sección "Más recientes" (Publicadas)
const recientes = workbooks.data.filter(w => w.status === 1);
```

## 🎯 Resumen

| Acción Frontend | Request Backend | Resultado |
|----------------|-----------------|-----------|
| Guardar como borrador (crear) | `POST /api/Workbooks` con `status: 0` | Aparece en "Borradores" |
| Publicar directamente (crear) | `POST /api/Workbooks` con `status: 1` | Aparece en "Más recientes" |
| Editar y volver a borrador | `PUT /api/Workbooks/{id}` con `status: 0` | Se mueve a "Borradores" |
| Editar y publicar borrador | `PUT /api/Workbooks/{id}` con `status: 1` | Se mueve a "Más recientes" |
| Publicar borrador (botón) | `PUT /api/Workbooks/{id}/publish` | Se mueve a "Más recientes" |

**Ya está listo en el backend. Solo necesitan ajustar el frontend para enviar y filtrar por `status`.** 🚀
