# 🔍 ANÁLISIS: Plan de Emma

## ✅ Confirmación Backend
Emma está guardada en la BD con:
- `planType: 1` = **Básico**
- `maxWorkbooks: 10` ✅ (correcto para Básico)
- `maxDatabases: 2` ❌ (incorrecto, debería ser 1 para Básico)

## ❌ Problema 1: Frontend muestra "Estándar" cuando es "Básico"

**Causa**: El frontend tiene un mapeo incorrecto.

En el frontend, probablemente tienen algo como:
```javascript
const  PLAN_NAMES = {
  0: "Free",
  1: "Estándar",  // ❌ INCORRECTO - debería ser "Básico"
  2: "Premium"
}
```

**Solución (FRONTEND)**:
```javascript
const PLAN_NAMES = {
  0: "Free",
  1: "Básico",    // ✅ Correcto
  2: "Estándar",  // ✅ Correcto  
  3: "Premium"    // ✅ Correcto
}
```

## ❌ Problema 2: Límites incorrectos en el modelo

**Antes (incorrecto)**:
- Free: 5 workbooks, 1 DB
- Básico: 10 workbooks, **2 DBs** ❌
- Estándar: 25 workbooks, **3 DBs** ❌
- Premium: ilimitado

**Ahora (correcto según tu imagen)**:
- Free: 10 workbooks, 1 DB
- Básico: 10 workbooks, **1 DB** ✅
- Estándar: 25 workbooks, **2 DBs** ✅
- Premium: ilimitado

**Ya corregí esto** en `Subscription.cs` pero aún NO compilé.

## 📋 ¿Emma debería tener qué plan?

Si Emma realmente necesita:
- 25 planillas
- 2 bases de datos

Entonces Emma debería tener `planType: 2` (Estándar), no `planType: 1` (Básico).

## 🛠️ Opciones:

### Opción A: Corregir el plan de Emma en la BD (Backend)
```sql
UPDATE Subscriptions 
SET PlanType = 2  -- Cambiar de Básico a Estándar
WHERE UserId = 24;
```

### Opción B: Dejar el plan como está y solo corregir el frontend
El frontend debe decir "Básico" en lugar de "Estándar".

---

**¿Cuál prefieres?**
1. ¿Emma realmente debería tener plan Estándar (cambio en BD)?
2. ¿O solo necesitas que el frontend muestre correctamente "Básico"?
