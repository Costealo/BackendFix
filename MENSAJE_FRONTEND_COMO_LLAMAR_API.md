# 🔧 Mensaje para Frontend: Cómo Llamar los Endpoints Correctamente

## Problema Actual

El frontend está enviando requests con formato incorrecto y/o está confundiendo los IDs.

---

## 📋 ENDPOINTS CORRECTOS DEL BACKEND

### 1. Agregar Item a Planilla

**Endpoint:**
```
POST /api/Workbooks/{workbookId}/items
```

**Headers:**
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Body (JSON):**
```json
{
  "priceItemId": 91,        // ← NUMBER (no string!)
  "quantity": 2.5,          // ← NUMBER
  "unit": "kg",             // ← STRING
  "additionalCost": 0       // ← NUMBER
}
```

**Respuesta Exitosa (201 Created):**
```json
{
  "id": 123,
  "workbookId": 19,
  "priceItemId": 91,
  "quantity": 2.5,
  "unit": "kg",
  "additionalCost": 0
}
```

---

## ❌ LO QUE ESTÁ MAL (Lo que PROBABLEMENTE están haciendo)

### Error 1: PascalCase en lugar de camelCase
```javascript
// ❌ MAL
const payload = {
  PriceItemId: 91,      // ← Incorrecto
  Quantity: 2.5,        // ← Incorrecto
  Unit: "kg"            // ← Incorrecto
};
```

### Error 2: Enviando IDs como String
```javascript
// ❌ MAL
const payload = {
  priceItemId: "91",    // ← String en lugar de Number
  quantity: 2.5,
  unit: "kg"
};
```

### Error 3: Confundiendo Database ID con PriceItem ID
```javascript
// ❌ MAL - Están enviando el ID de la base de datos
const databaseId = 16;  // ← Este NO es el priceItemId
const payload = {
  priceItemId: databaseId,  // ← ERROR! 
  quantity: 2.5,
  unit: "kg"
};
```

**IMPORTANTE:** 
- Database ID (16, 17, 18) ≠ PriceItem ID (91, 68, 90)
- Necesitan usar el `id` del **item**, NO el `priceDatabaseId`

---

## ✅ CÓDIGO CORRECTO

### Ejemplo Completo: Agregar Ingrediente de Base de Datos

```javascript
async function addIngredientFromDatabase(workbookId, ingredientData) {
  // ingredientData viene de la base de datos seleccionada
  // Ejemplo: { id: 91, product: 'harina', price: 10, unit: 'kg' }
  
  const payload = {
    priceItemId: ingredientData.id,  // ← Usar el .id del item, no del database
    quantity: parseFloat(cantidad),   // ← Asegurarse que sea número
    unit: ingredientData.unit,        // ← Usar la unidad del item
    additionalCost: 0
  };
  
  console.log('Payload a enviar:', JSON.stringify(payload, null, 2));
  
  try {
    const response = await fetch(
      `http://localhost:8080/api/Workbooks/${workbookId}/items`,
      {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('token')}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(payload)
      }
    );
    
    if (!response.ok) {
      const errorText = await response.text();
      console.error('Error del servidor:', errorText);
      throw new Error(errorText);
    }
    
    const item = await response.json();
    console.log('✅ Item agregado:', item);
    return item;
    
  } catch (error) {
    console.error('❌ Error al agregar item:', error);
    throw error;
  }
}
```

### Cómo Obtener el PriceItem Correcto

```javascript
async function getPriceItemFromDatabase(databaseId, productName) {
  try {
    // 1. Obtener detalles de la base de datos
    const response = await fetch(
      `http://localhost:8080/api/PriceDatabase/${databaseId}`,
      {
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('token')}`
        }
      }
    );
    
    const database = await response.json();
    
    // 2. Buscar el producto en los items
    const item = database.items.find(i => 
      i.product.toLowerCase() === productName.toLowerCase()
    );
    
    if (!item) {
      throw new Error(`Producto "${productName}" no encontrado en la base de datos`);
    }
    
    // 3. Retornar el item completo
    return {
      id: item.id,              // ← ESTE es el priceItemId correcto
      product: item.product,
      price: item.price,
      unit: item.unit
    };
    
  } catch (error) {
    console.error('Error al obtener item:', error);
    throw error;
  }
}
```

### Uso Completo:

```javascript
// Cuando el usuario selecciona "harina" de la base de datos "spy 3" (ID: 16)
const databaseId = 16;
const productName = 'harina';

// 1. Obtener el PriceItem
const priceItem = await getPriceItemFromDatabase(databaseId, productName);
// priceItem = { id: 91, product: 'harina', price: 10, unit: 'kg' }

// 2. Agregar a la planilla
await addIngredientFromDatabase(19, priceItem);
// Esto enviará: { priceItemId: 91, quantity: 2.5, unit: 'kg', additionalCost: 0 }
```

---

## 🔍 VERIFICACIÓN

### Antes de Enviar el Request, Verificar:
```javascript
console.log('=== VERIFICACIÓN ANTES DE ENVIAR ===');
console.log('1. priceItemId es NUMBER?', typeof payload.priceItemId === 'number');
console.log('2. priceItemId NO es database ID?', payload.priceItemId !== databaseId);
console.log('3. Las keys están en camelCase?', 'priceItemId' in payload);
console.log('4. Tiene additionalCost?', 'additionalCost' in payload);
console.log('Payload final:', JSON.stringify(payload, null, 2));
```

**Debe imprimir:**
```
=== VERIFICACIÓN ANTES DE ENVIAR ===
1. priceItemId es NUMBER? true
2. priceItemId NO es database ID? true
3. Las keys están en camelCase? true
4. Tiene additionalCost? true
Payload final: {
  "priceItemId": 91,
  "quantity": 2.5,
  "unit": "kg",
  "additionalCost": 0
}
```

---

## 🎯 RESUMEN RÁPIDO

| Campo | Valor Correcto | Valor Incorrecto |
|-------|---------------|------------------|
| Key name | `priceItemId` | ~~`PriceItemId`~~ |
| Value type | `91` (number) | ~~`"91"` (string)~~ |
| Value source | `item.id` | ~~`database.id`~~ |
| Example | `priceItemId: 91` | ~~`priceItemId: 16`~~ |

---

## ❓ Preguntas Frecuentes

**Q: ¿De dónde saco el priceItemId?**
A: Del campo `id` de cada item en `database.items[]`, NO del `database.id`

**Q: ¿Qué pasa si envío el database ID por error?**
A: El backend responderá `400 Bad Request: Price item not found`

**Q: ¿Por qué necesito additionalCost?**
A: El backend lo requiere. Si no tienen costo adicional, envíen `0`

**Q: ¿Puedo omitir el unit?**
A: No, es requerido. Usen la misma unidad del item de la base de datos

---

## 🧪 PRUEBA RÁPIDA

Ejecuten esto en la consola del navegador:

```javascript
// Agregar item a planilla de prueba
fetch('http://localhost:8080/api/Workbooks/20/items', {
  method: 'POST',
  headers: {
    'Authorization': 'Bearer ' + localStorage.getItem('token'),
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    priceItemId: 91,
    quantity: 1,
    unit: 'kg',
    additionalCost: 0
  })
})
.then(r => r.json())
.then(data => console.log('✅ Éxito:', data))
.catch(err => console.error('❌ Error:', err));
```

Si funciona, verán `✅ Éxito: { id: ..., workbookId: 20, ... }`

---

**IMPORTANTE:** El backend está funcionando correctamente. Solo necesitan ajustar cómo envían los datos.
