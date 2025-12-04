# 📘 Guía: Ingredientes Manuales sin Cambios en Backend

## Solución Elegida: Opción 2

El frontend creará items en la base de datos automáticamente cuando el usuario agregue un ingrediente manual.

## Flujo Completo

```
Usuario escribe "Harina" manualmente
   ↓
Frontend busca "Harina" en todas las bases de datos del usuario
   ↓
   ¿Existe?
   ├─ SÍ → Usar el priceItemId existente
   └─ NO → Crear item en base de datos primero
       ↓
       Obtener/crear base de datos por defecto
       ↓
       POST /api/PriceDatabase/{dbId}/items
       ↓
       Obtener el priceItemId del item recién creado
       ↓
Agregar a la planilla con POST /api/Workbooks/{workbookId}/items
```

## Implementación Paso a Paso

### 1. Buscar Ingrediente en Bases de Datos

```javascript
async function searchIngredientInDatabases(productName) {
  try {
    // Obtener todas las bases de datos del usuario
    const response = await api.get('/api/PriceDatabase');
    const databases = response.data;
    
    // Buscar el producto en cada base de datos
    for (const db of databases) {
      // Obtener detalles de la base de datos (incluye items)
      const dbDetails = await api.get(`/api/PriceDatabase/${db.id}`);
      
      // Buscar el producto (case-insensitive)
      const item = dbDetails.data.items.find(i => 
        i.product.toLowerCase() === productName.toLowerCase()
      );
      
      if (item) {
        return {
          found: true,
          priceItemId: item.id,
          price: item.price,
          unit: item.unit,
          databaseName: db.name
        };
      }
    }
    
    return { found: false };
  } catch (error) {
    console.error('Error searching ingredient:', error);
    throw error;
  }
}
```

### 2. Obtener o Crear Base de Datos por Defecto

```javascript
async function getOrCreateDefaultDatabase() {
  try {
    // Obtener todas las bases de datos
    const response = await api.get('/api/PriceDatabase');
    const databases = response.data;
    
    // Buscar una base de datos llamada "Ingredientes" (borrador)
    let defaultDb = databases.find(db => 
      db.name === 'Ingredientes' && db.status === 0
    );
    
    if (!defaultDb) {
      // Si no existe, buscar cualquier base de datos en borrador
      defaultDb = databases.find(db => db.status === 0);
    }
    
    if (!defaultDb) {
      // Si no hay ninguna, crear una nueva
      const createResponse = await api.post('/api/PriceDatabase', {
        name: 'Ingredientes',
        status: 0  // Draft
      });
      defaultDb = createResponse.data;
    }
    
    return defaultDb;
  } catch (error) {
    console.error('Error getting/creating default database:', error);
    throw error;
  }
}
```

### 3. Crear Item en Base de Datos

```javascript
async function createPriceItem(databaseId, productName, price, unit) {
  try {
    const response = await api.post(`/api/PriceDatabase/${databaseId}/items`, {
      product: productName,
      price: price,
      unit: unit
    });
    
    return {
      priceItemId: response.data.id,
      product: response.data.product,
      price: response.data.price,
      unit: response.data.unit
    };
  } catch (error) {
    console.error('Error creating price item:', error);
    throw error;
  }
}
```

### 4. Agregar Item a la Planilla

```javascript
async function addItemToWorkbook(workbookId, priceItemId, quantity, unit) {
  try {
    const response = await api.post(`/api/Workbooks/${workbookId}/items`, {
      priceItemId: priceItemId,
      quantity: quantity,
      unit: unit,
      additionalCost: 0
    });
    
    return response.data;
  } catch (error) {
    console.error('Error adding item to workbook:', error);
    throw error;
  }
}
```

### 5. Función Principal: Agregar Ingrediente

```javascript
async function addIngredient(workbookId, ingredientName, quantity, price, unit) {
  try {
    // 1. Buscar si el ingrediente ya existe
    console.log(`Buscando "${ingredientName}" en bases de datos...`);
    const searchResult = await searchIngredientInDatabases(ingredientName);
    
    let priceItemId;
    
    if (searchResult.found) {
      // Ya existe - usar el existente
      console.log(`✅ Encontrado en base de datos "${searchResult.databaseName}"`);
      priceItemId = searchResult.priceItemId;
      
      // Opcional: Preguntar al usuario si quiere usar el precio existente
      // o el nuevo precio que ingresó
      if (searchResult.price !== price) {
        const useExisting = confirm(
          `"${ingredientName}" ya existe con precio $${searchResult.price}/${searchResult.unit}.\n` +
          `¿Usar el precio existente? (Cancelar para usar nuevo precio $${price}/${unit})`
        );
        
        if (!useExisting) {
          // Crear un nuevo item con el nuevo precio
          const db = await getOrCreateDefaultDatabase();
          const newItem = await createPriceItem(db.id, ingredientName, price, unit);
          priceItemId = newItem.priceItemId;
        }
      }
    } else {
      // No existe - crear nuevo
      console.log(`❌ No encontrado. Creando en base de datos...`);
      
      // Obtener o crear base de datos por defecto
      const db = await getOrCreateDefaultDatabase();
      console.log(`📁 Usando base de datos: ${db.name}`);
      
      // Crear el item en la base de datos
      const newItem = await createPriceItem(db.id, ingredientName, price, unit);
      console.log(`✅ Item creado con ID: ${newItem.priceItemId}`);
      
      priceItemId = newItem.priceItemId;
    }
    
    // 2. Agregar a la planilla
    console.log(`➕ Agregando a planilla (workbookId: ${workbookId})...`);
    await addItemToWorkbook(workbookId, priceItemId, quantity, unit);
    console.log(`✅ Ingrediente agregado exitosamente!`);
    
    return { success: true, priceItemId };
    
  } catch (error) {
    console.error('Error al agregar ingrediente:', error);
    return { success: false, error: error.message };
  }
}
```

## Ejemplo de Uso

```javascript
// Cuando el usuario presiona "Agregar Ingrediente"
const handleAddIngredient = async () => {
  const result = await addIngredient(
    workbookId,       // ID de la planilla actual
    'Harina',         // Nombre del ingrediente
    2.5,              // Cantidad
    10.50,            // Precio
    'kg'              // Unidad
  );
  
  if (result.success) {
    // Refrescar la planilla para mostrar el nuevo item
    await loadWorkbook(workbookId);
    showSuccessMessage('Ingrediente agregado');
  } else {
    showErrorMessage('Error: ' + result.error);
  }
};
```

## Manejo de Errores

```javascript
// Si el usuario no tiene ninguna base de datos
try {
  await addIngredient(workbookId, 'Harina', 2.5, 10.50, 'kg');
} catch (error) {
  if (error.response?.status === 400 && error.response.data.includes('limit reached')) {
    showErrorMessage('Has alcanzado el límite de bases de datos de tu plan');
  } else {
    showErrorMessage('Error al agregar ingrediente: ' + error.message);
  }
}
```

## Ventajas de Esta Solución

✅ **No requiere cambios en el backend**
✅ **Mantiene trazabilidad** - todos los precios están en bases de datos
✅ **Actualización automática** - si cambias el precio en la base de datos, se refleja en todas las planillas
✅ **Evita duplicados** - reutiliza items existentes
✅ **Funciona con el backend actual**

## Desventajas

⚠️ **Requiere cambios en el frontend** - más código a implementar
⚠️ **Siempre crea en base de datos** - aunque sea temporal

## Próximos Pasos

1. Implementar las funciones en el frontend
2. Probar el flujo completo
3. Verificar que los ingredientes se guarden correctamente
4. Confirmar que aparecen cuando abres la planilla

¿Necesitas ayuda con alguna parte de la implementación?
