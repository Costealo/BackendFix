# 🐛 Debug: Error "Price item not found"

## Problema

El frontend recibe error `400 Bad Request: Price item not found` al intentar agregar items a una planilla.

## Verificación del Backend

✅ **CONFIRMADO:** Los PriceItems SÍ existen y están accesibles:
- PriceItem ID 91 - "harina" $10/kg - Database "spy 3"
- PriceItem ID 68 - "harina" $10/kg - Database "sp 4"  
- PriceItem ID 90 - "harina" $10/kg - Database "spy 5"

✅ **CONFIRMADO:** El backend PUEDE agregar items correctamente cuando se llama con el formato correcto.

## Causa Probable

El error está en **cómo el frontend está enviando el request**. Posibles problemas:

### 1. Formato Incorrecto del JSON

**❌ INCORRECTO:**
```json
{
  "PriceItemId": 91,     // ← PascalCase
  "Quantity": 1,
  "Unit": "kg"
}
```

**✅ CORRECTO:**
```json
{
  "priceItemId": 91,     // ← camelCase
  "quantity": 1,
  "unit": "kg",
  "additionalCost": 0
}
```

### 2. Enviando `priceItemId` como String en lugar de Number

**❌ INCORRECTO:**
```json
{
  "priceItemId": "91",   // ← String
  "quantity": 1,
  "unit": "kg"
}
```

**✅ CORRECTO:**
```json
{
  "priceItemId": 91,     // ← Number
  "quantity": 1,
  "unit": "kg"
}
```

### 3. Token de Autenticación Incorrecto

Si el token pertenece a otro usuario, no podrá acceder a los PriceItems.

**Verificar:**
```javascript
console.log('Token:', localStorage.getItem('token'));
console.log('User ID:', parseJwt(token).nameid);  // Debe ser 27
```

### 4. Usando ID de Otro Campo

El frontend podría estar confundiendo el ID del item de la base de datos con otro ID.

**Verificar en los logs:**
```
DEBUG - Adding item with priceItemId: 91  // ✅ Correcto
DEBUG - Adding item with priceItemId: 16  // ❌ Esto es el databaseId, no el itemId
```

## Solución

### Paso 1: Verificar el Request en la Consola

Agregar logs JUSTO ANTES de hacer el POST:

```javascript
async function addItemToWorkbook(workbookId, priceItemId, quantity, unit) {
  const payload = {
    priceItemId: priceItemId,
    quantity: quantity,
    unit: unit,
    additionalCost: 0
  };
  
  // ⬇️ AGREGAR ESTOS LOGS
  console.log('=== DEBUG ADD ITEM ===');
  console.log('Workbook ID:', workbookId);
  console.log('Payload:', JSON.stringify(payload, null, 2));
  console.log('priceItemId type:', typeof payload.priceItemId);
  console.log('quantity type:', typeof payload.quantity);
  
  try {
    const response = await api.post(
      `/api/Workbooks/${workbookId}/items`,
      payload
    );
    console.log('✅ Success:', response.data);
    return response.data;
  } catch (error) {
    console.error('❌ Error:', error.response?.data || error.message);
    throw error;
  }
}
```

### Paso 2: Verificar en Network Tab

1. Abrir DevTools → Network
2. Intentar agregar ingrediente
3. Buscar el request `POST .../Workbooks/19/items`
4. Ver la pestaña "Payload" o "Request"

**Debe verse así:**
```json
{
  "priceItemId": 91,
  "quantity": 1.0,
  "unit": "kg",
  "additionalCost": 0
}
```

### Paso 3: Comparar con Request que Funciona

Este request **SÍ funcionó** en mi prueba:

```http
POST http://localhost:8080/api/Workbooks/20/items
Authorization: Bearer {token}
Content-Type: application/json

{
  "priceItemId": 91,
  "quantity": 1,
  "unit": "kg",
  "additionalCost": 0
}
```

**Respuesta exitosa:** `200 OK` con el item creado.

## Checklist de Verificación

- [ ] El `priceItemId` es un **número**, no un string
- [ ] Las keys están en **camelCase** (`priceItemId`, no `PriceItemId`)
- [ ] Se está enviando `additionalCost` (aunque sea 0)
- [ ] El token de autorización es correcto
- [ ] El `workbookId` existe y pertenece al usuario
- [ ] El `priceItemId` existe en alguna base de datos del usuario

## Próximos Pasos

1. Agregar los logs que sugerí
2. Intentar agregar un ingrediente
3. Copiar y pegar EXACTAMENTE lo que aparece en:
   - Console logs
   - Network tab → Request payload
   
4. Compartir esa información para diagnosticar el problema exacto.

---

**Nota:** El backend está funcionando correctamente. El problema está 100% en el frontend.
