# 📨 Mensaje para el Frontend - Flujo de Publicación de Borradores

Hola equipo! 👋

## ✅ Problema 1 resuelto (Backend)
El mensaje de error del límite de bases ya muestra el nombre correcto del plan:
- Antes: "Database limit reached for your **Basico** plan"  
- Ahora: "Database limit reached for your **Básico** plan" (o Estándar, Premium según corresponda)

**Ya está corregido en el backend.** 🎉

---

## 📝 Problema 2: Flujo de Borradores → Publicadas (Frontend)

El backend YA está funcionando correctamente y devuelve el campo `status`:
- `status: 0` = Borrador
- `status: 1` = Publicada

### Lo que necesitan hacer en el frontend:

#### 1️⃣ Cuando el usuario edita un borrador y presiona **"Publicar"**:

```javascript
// Llamar al endpoint de publicación
await api.put(`/api/PriceDatabase/${id}/publish`, {}, {
  headers: { Authorization: `Bearer ${token}` }
});

// Refrescar la lista de bases
const databases = await api.get('/api/PriceDatabase', {
  headers: { Authorization: `Bearer ${token}` }
});

// Actualizar el estado local
setDatabases(databases.data);
```

#### 2️⃣ En la UI, filtrar por `status`:

```javascript
// Sección "Borradores"
const borradores = databases.filter(db => db.status === 0);

// Sección "Más recientes"  
const recientes = databases.filter(db => db.status === 1);
```

### Flujo completo:

```
Usuario edita borrador (status: 0)
  ↓
Presiona "Publicar"
  ↓
Frontend llama: PUT /api/PriceDatabase/{id}/publish
  ↓
Frontend refetch: GET /api/PriceDatabase
  ↓
Backend devuelve la base con status: 1
  ↓
Frontend filtra:
  - Borradores (status === 0) → NO aparece aquí
  - Más recientes (status === 1) → SÍ aparece aquí ✅
```

### Botones en la pantalla de edición:

| Botón | Acción | Resultado |
|-------|--------|-----------|
| **"Guardar"** (dentro de un borrador) | `PUT /api/PriceDatabase/{id}` con los cambios | Mantiene `status: 0`, sigue en Borradores |
| **"Publicar"** | `PUT /api/PriceDatabase/{id}/publish` | Cambia a `status: 1`, se mueve a Más recientes |

---

## 🚀 Resumen para el frontend

**El backend ya está listo y funciona.** Solo necesitan:
1. Conectar el botón "Publicar" al endpoint `PUT /api/PriceDatabase/{id}/publish`
2. Hacer un refetch después de publicar
3. Filtrar correctamente por `status` en cada sección

¡Eso es todo! El resto ya está funcionando. 💪
