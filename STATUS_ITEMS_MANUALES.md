# 🚧 En Progreso: Soporte para Items Manuales en Planillas

Hola equipo,

Estoy implementando el soporte para items manuales (sin `priceItemId`) en el backend. Este es un cambio significativo que requiere:

## Cambios en Progreso:

1. ✅ **Modelo `WorkbookItem`** - Agregando campos `ManualItemName` y `ManualItemPrice`
2. ✅ **DTO `AddWorkbookItemDto`** - Haciendo `PriceItemId` opcional y agregando campos manuales
3. 🔄 **Controller `AddItem`** - Actualizando lógica para aceptar ambos tipos
4. 🔄 **Migración de Base de Datos** - Agregando nuevas columnas
5. 🔄 **Lógica de Cálculo** - Actualizando `CalculateWorkbook` para manejar items manuales

## Formato del Request (Cuando Esté Listo):

### Para Items de Base de Datos:
```json
POST /api/Workbooks/{id}/items
{
  "priceItemId": 123,
  "quantity": 2.5,
  "unit": "kg",
  "additionalCost": 0
}
```

### Para Items Manuales (NUEVO):
```json
POST /api/Workbooks/{id}/items
{
  "manualItemName": "Harina",
  "manualItemPrice": 10.50,
  "quantity": 2.5,
  "unit": "kg",
  "additionalCost": 0
}
```

## Validación:

- Si envían `priceItemId` → El backend verificará que existe y que el usuario tiene acceso
- Si NO envían `priceItemId` → El backend requerirá `manualItemName` y `manualItemPrice`
- No pueden enviar ambos al mismo tiempo

## Tiempo Estimado:

Estoy trabajando en esto ahora. Debería estar listo en aproximadamente 15-20 minutos.

Les avisaré cuando esté completo y probado. 🚀

---

**Nota:** Por favor no intenten usar la funcionalidad de items manuales hasta que les confirme que está lista. El backend actual aún requiere `priceItemId`.
