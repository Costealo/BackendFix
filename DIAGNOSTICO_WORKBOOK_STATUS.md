# 🔍 Diagnóstico: Estado de Workbooks (Planillas)

## Estado Actual del Backend

### ✅ PriceDatabase (Bases de Datos)
El backend **SÍ** soporta el campo `status` para bases de datos:
- `CreatePriceDatabaseDto` tiene campo `Status`
- `PUT /api/PriceDatabase/{id}` permite actualizar el status
- `PUT /api/PriceDatabase/{id}/publish` cambia a Published

### ❌ Workbooks (Planillas)
El backend **NO** soporta el campo `status` para planillas:
- `CreateWorkbookDto` **no tiene** campo `Status`
- `UpdateWorkbookDto` **no tiene** campo `Status`
- El backend siempre crea workbooks con `Status = EntityStatus.Draft` (línea 106 de WorkbooksController)
- El backend **ignora** cualquier campo `status` que envíe el frontend

## 🐛 Problema Identificado

El frontend está enviando:
```javascript
{
  "name": "Mi Planilla",
  "status": 1  // ← El backend IGNORA este campo
}
```

Pero el backend está creando:
```csharp
var workbook = new Workbook
{
    Name = dto.Name,
    Status = EntityStatus.Draft  // ← Siempre Draft, ignora lo que envía el frontend
};
```

## 🛠️ Solución Necesaria

Para que funcione como en PriceDatabase, necesitamos:

### 1. Actualizar `CreateWorkbookDto.cs`:
```csharp
using System.ComponentModel.DataAnnotations;
using Costealo.API.Models;

namespace Costealo.API.DTOs;

public class CreateWorkbookDto
{
    [Required]
    public string Name { get; set; } = string.Empty;
    
    public decimal ProductionUnits { get; set; } = 1;
    public decimal ProfitMarginPercentage { get; set; } = 0.20m;
    
    public decimal? TargetSalePrice { get; set; }
    
    public EntityStatus? Status { get; set; }  // ← AGREGAR ESTO
}
```

### 2. Actualizar `WorkbooksController.cs` (CreateWorkbook):
```csharp
var workbook = new Workbook
{
    Name = dto.Name,
    ProductionUnits = dto.ProductionUnits,
    ProfitMarginPercentage = dto.ProfitMarginPercentage,
    TargetSalePrice = dto.TargetSalePrice,
    UserId = userId,
    CreatedAt = DateTime.UtcNow,
    Status = dto.Status ?? EntityStatus.Draft  // ← CAMBIAR ESTO
};
```

### 3. Actualizar `WorkbooksController.cs` (UpdateWorkbook):
```csharp
workbook.TargetSalePrice = dto.TargetSalePrice;

// AGREGAR ESTO:
if (dto.Status.HasValue)
{
    workbook.Status = dto.Status.Value;
}

// TaxPercentage, OperationalCostPercentage, and OperationalCostFixed are not user-editable
```

## 📋 Respuesta al Frontend

**No necesitan revisar logs del navegador.** El problema está en el backend:

1. El backend actualmente **ignora** el campo `status` que están enviando
2. Siempre crea workbooks con `status: 0` (Draft)
3. No hay forma de cambiar el status vía API

**Solución temporal:**
- Esperar a que se actualice el backend

**Verificación (una vez actualizado el backend):**
1. Crear planilla con "Publicar" → debería enviar `status: 1`
2. Hacer `GET /api/Workbooks/{id}` → debería retornar `"status": 1`
3. Si retorna `"status": 0`, entonces el frontend no está enviando el campo

## 🎯 ¿Qué necesitas decidir?

1. ¿Quieres que agregue soporte para `status` en Workbooks igual que en PriceDatabase?
2. ¿O Workbooks no debería tener estado Draft/Published?
