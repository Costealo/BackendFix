# 🔍 Diagnóstico: Planillas Vacías

## Problema Confirmado

Verifiqué la base de datos y **TODAS las planillas tienen 0 items guardados**. Por eso aparecen vacías cuando las abres.

```
Workbook ID: 17 - Name: lucas
  Items count: 0 ❌ (Sin items guardados)

Workbook ID: 16 - Name: liz
  Items count: 0 ❌ (Sin items guardados)

Workbook ID: 15 - Name: abi
  Items count: 0 ❌ (Sin items guardados)
```

## ¿Por Qué Están Vacías?

Según los logs del frontend que compartiste:

```
DEBUG - Ingredient data: {name: harina, amount: 10, cost: 10, priceItemId: null}
DEBUG - Skipping ingredient (no priceItemId)
DEBUG - Extra data: {name: nose, amount: 10, unitPrice: 10, priceItemId: null}
DEBUG - Skipping extra (no priceItemId)
```

**El frontend está saltando todos los ingredientes porque tienen `priceItemId: null`.**

## ✅ Solución

El backend **REQUIERE** que todos los ingredientes tengan un `priceItemId` válido (deben venir de una base de datos).

### Flujo Correcto:

1. **Usuario crea/edita planilla**
2. **Agrega ingrediente "harina"**
3. **Frontend debe verificar:**
   - ¿Existe "harina" en alguna base de datos del usuario?
   - **SI existe** → Usar ese `priceItemId`
   - **NO existe** → Mostrar modal: *"'harina' no está en tus bases de datos. ¿Agregarla?"*
     - Si acepta → Crear item en base de datos primero
     - Luego usar el nuevo `priceItemId`

4. **Llamar `POST /api/Workbooks/{id}/items`** con el `priceItemId` correcto

### Código de Ejemplo:

```javascript
async function addIngredient(workbookId, ingredientName, quantity, price) {
  // 1. Buscar en bases de datos
  let priceItem = await searchIngredientInDatabases(ingredientName);
  
  if (!priceItem) {
    // 2. No existe - preguntar al usuario
    const shouldCreate = confirm(
      `"${ingredientName}" no está en tus bases de datos.\n¿Deseas agregarlo?`
    );
    
    if (!shouldCreate) return; // Usuario canceló
    
    // 3. Crear en base de datos primero
    const databases = await getDatabases();
    let targetDb = databases.find(db => db.status === 0); // Buscar un borrador
    
    if (!targetDb) {
      // Crear nueva base de datos si no hay ninguna
      targetDb = await createDatabase({
        name: "Ingredientes",
        status: 0 // Draft
      });
    }
    
    // 4. Agregar item a la base de datos
    priceItem = await addPriceItem(targetDb.id, {
      product: ingredientName,
      price: price,
      unit: 'kg'
    });
  }
  
  // 5. AHORA SÍ agregar a la planilla con priceItemId
  await addWorkbookItem(workbookId, {
    priceItemId: priceItem.id,  // ✅ Ahora tiene ID válido
    quantity: quantity,
    unit: priceItem.unit
  });
}
```

## 📋 Endpoints Necesarios

### Buscar Ingrediente en Bases de Datos:
```javascript
async function searchIngredientInDatabases(productName) {
  const databases = await api.get('/api/PriceDatabase');
  
  for (const db of databases) {
    const details = await api.get(`/api/PriceDatabase/${db.id}`);
    const item = details.items.find(i => 
      i.product.toLowerCase() === productName.toLowerCase()
    );
    if (item) return item;
  }
  
  return null; // No encontrado
}
```

### Crear Item en Base de Datos:
```javascript
async function addPriceItem(databaseId, itemData) {
  const response = await api.post(
    `/api/PriceDatabase/${databaseId}/items`,
    itemData
  );
  return response.data;
}
```

### Agregar Item a Planilla:
```javascript
async function addWorkbookItem(workbookId, itemData) {
  const response = await api.post(
    `/api/Workbooks/${workbookId}/items`,
    {
      priceItemId: itemData.priceItemId,  // REQUERIDO
      quantity: itemData.quantity,
      unit: itemData.unit,
      additionalCost: 0
    }
  );
  return response.data;
}
```

## 🎯 Resumen

**Problema:** Frontend no está guardando items porque no tienen `priceItemId`

**Causa:** El backend requiere que todos los ingredientes existan en una base de datos

**Solución:** 
1. Buscar ingrediente en bases de datos
2. Si no existe, crearlo primero
3. Luego agregarlo a la planilla con el `priceItemId` correcto

**Resultado:** Las planillas se guardarán con sus items y aparecerán cuando las abras ✅

---

## 🔄 Sobre Editar y Eliminar

Para que funcione igual que las bases de datos:

### Modo Lectura (Default):
- Mostrar todos los ingredientes
- Botón "Editar" (verde, esquina superior derecha)
- Botón "Eliminar" (verde, esquina inferior izquierda)

### Modo Edición:
- Permitir agregar/quitar ingredientes
- Botón "Guardar" o "Publicar"

El backend ya soporta:
- ✅ `GET /api/Workbooks/{id}` - Ver planilla
- ✅ `PUT /api/Workbooks/{id}` - Editar planilla
- ✅ `DELETE /api/Workbooks/{id}` - Eliminar planilla
- ✅ `POST /api/Workbooks/{id}/items` - Agregar item
- ✅ `DELETE /api/Workbooks/{id}/items/{itemId}` - Quitar item

Solo falta que el frontend:
1. Guarde los items correctamente (con `priceItemId`)
2. Implemente el modo lectura/edición en la UI
