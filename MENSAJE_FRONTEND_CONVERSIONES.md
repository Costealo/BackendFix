# 🔄 CONVERSIONES DE UNIDADES EN PLANILLAS - GUÍA FRONTEND

## ⚠️ PROBLEMA IDENTIFICADO

Cuando agregas un item a la planilla con unidades diferentes a las del PriceDatabase, **NO debes hacer ningún cálculo manual**. El backend ya hace todas las conversiones automáticamente.

---

## 📋 ESTRUCTURA DE DATOS QUE RECIBES

Cuando llamas a `GET /api/Workbooks/{id}`, recibes esto para cada item:

```json
{
  "id": 1,
  "priceItemId": 42,
  "productName": "Harina",
  
  // ❌ ESTOS SON VALORES DEL PRICE DATABASE (SIN CONVERTIR)
  "originalPrice": 10.00,
  "originalUnit": "kilogram",
  
  // ✅ ESTOS SON VALORES QUE USASTE EN LA PLANILLA
  "quantityUsed": 100,
  "unitUsed": "gram",
  
  "additionalCost": 0,
  
  // ✅ ESTE ES EL COSTO YA CALCULADO CON CONVERSIÓN
  "calculatedCost": 1.00,
  
  // ℹ️ MENSAJE INFORMATIVO DE LA CONVERSIÓN
  "conversionMessage": "Converted 1 kilogram to 1000 gram"
}
```

---

## ✅ CÓMO USAR LOS DATOS CORRECTAMENTE

### ❌ **INCORRECTO** (Lo que probablemente estás haciendo):

```javascript
// ¡NO HAGAS ESTO!
const itemCost = item.originalPrice * item.quantityUsed;
// Resultado: $10 * 100 = $1000 ❌ (INCORRECTO)
```

### ✅ **CORRECTO**:

```javascript
// Simplemente usa el valor ya calculado
const itemCost = item.calculatedCost;
// Resultado: $1.00 ✅ (CORRECTO)
```

---

## 🧮 EJEMPLO COMPLETO

### Escenario:
- **Base de datos**: Harina a $10 por **kilogramo**
- **Planilla**: Usuario agrega **100 gramos** de harina

### Lo que el backend hace automáticamente:
1. Detecta que las unidades son diferentes (`kilogram` vs `gram`)
2. Llama al servicio de conversión: `1 kg = 1000 g`
3. Calcula el precio por gramo: `$10 / 1000 = $0.01`
4. Multiplica por la cantidad usada: `$0.01 * 100 = $1.00`
5. Te envía `calculatedCost: 1.00`

### Tu trabajo en el frontend:
```javascript
// Simplemente mostrar el valor
<Text>{item.calculatedCost} Bs.</Text>
```

---

## 📊 CASO DE USO: MOSTRAR TABLA DE ITEMS

```javascript
// Ejemplo en Flutter/Dart
items.map((item) {
  return TableRow(
    children: [
      Text(item.productName),
      
      // Mostrar unidades originales (info)
      Text('${item.originalPrice} Bs/${item.originalUnit}'),
      
      // Mostrar cantidad usada
      Text('${item.quantityUsed} ${item.unitUsed}'),
      
      // ✅ USAR COSTO CALCULADO (no hacer cálculos)
      Text('${item.calculatedCost} Bs.'),
      
      // Opcional: mostrar mensaje de conversión
      Tooltip(
        message: item.conversionMessage,
        child: Icon(Icons.info)
      ),
    ],
  );
}).toList()
```

---

## 🎯 RESUMEN

| Campo | Usar para | ❌ NO usar para |
|-------|-----------|----------------|
| `originalPrice` | Mostrar precio de referencia | Calcular costos |
| `originalUnit` | Mostrar unidad de referencia | Calcular costos |
| `quantityUsed` | Mostrar cantidad usada | Calcular costos |
| `unitUsed` | Mostrar unidad usada | Calcular costos |
| **`calculatedCost`** | **✅ Mostrar costo total** | Nada, úsalo directo |
| `conversionMessage` | Info/debug | Nada |

---

## 🔍 CÓMO VERIFICAR SI ESTÁ FUNCIONANDO

1. Crea un item en PriceDatabase: **Azúcar** a **$5 por kilogram**
2. Agrégalo a una planilla: **200 gram**
3. El `calculatedCost` debería ser: **$1.00** (5 * 0.2)
4. Si ves **$1000** o **$5**, estás multiplicando mal en el frontend

---

## ❓ PREGUNTAS FRECUENTES

### P: ¿Qué pasa si las unidades son las mismas?
**R:** El backend detecta esto y hace el cálculo directo. El `calculatedCost` será `originalPrice * quantityUsed`.

### P: ¿Qué pasa si la conversión falla?
**R:** El backend asume 1:1 automáticamente. El `conversionMessage` dirá "Conversion failed, assumed 1:1".

### P: ¿Cómo sé si se hizo una conversión?
**R:** Lee el campo `conversionMessage`. Si dice "Same unit, direct calculation", no hubo conversión. Si dice "Converted X to Y", sí hubo.

### P: ¿Debo validar las unidades en el frontend?
**R:** NO. El backend ya valida las unidades al crear el item. Simplemente confía en los datos que recibes.

---

## 🚀 ENDPOINTS RELEVANTES

### Obtener planilla individual (CON cálculos):
```
GET /api/Workbooks/{id}
```
Respuesta incluye `calculatedCost` con conversiones aplicadas.

### Obtener lista de planillas:
```
GET /api/Workbooks
```
Respuesta es un resumen. Para ver detalles calculados, usa el endpoint individual.

### Agregar item a planilla:
```
POST /api/Workbooks/{id}/items
Body:
{
  "priceItemId": 42,
  "quantity": 100,
  "unit": "gram",      // ← Puede ser diferente al unit del PriceItem
  "additionalCost": 0
}
```

---

## ✅ CHECKLIST DE IMPLEMENTACIÓN

- [ ] Estoy usando `item.calculatedCost` directamente
- [ ] NO estoy multiplicando `originalPrice * quantityUsed`
- [ ] Muestro `originalPrice` y `originalUnit` solo como referencia
- [ ] Muestro `quantityUsed` y `unitUsed` para que el usuario sepa qué ingresó
- [ ] (Opcional) Muestro `conversionMessage` como tooltip o debug info
- [ ] El costo total de la planilla es la suma de todos los `calculatedCost`

---

**¿Dudas?** Contacta al equipo de backend. 🚀
