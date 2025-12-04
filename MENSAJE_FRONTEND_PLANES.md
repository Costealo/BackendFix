# 📨 Mensaje para el Frontend - Corrección de Planes y Mapeo

Hola equipo! 👋

Hemos realizado ajustes importantes en el backend para corregir inconsistencias con los planes.

## ✅ 1. Corrección del Plan de Emma
Confirmamos que el usuario **Emma** ahora tiene correctamente asignado el **Plan Estándar** en la base de datos.

- **PlanType**: 2 (Estándar)
- **Límites**: 25 planillas, 2 bases de datos.

## ⚠️ 2. Corrección de Mapeo de Nombres (IMPORTANTE)

Detectamos que el frontend estaba mostrando "Estándar" cuando el plan era "Básico" (1). Por favor, verifiquen su mapeo de `planType` a nombre para que coincida con el backend:

| PlanType (Backend) | Nombre Correcto | Límites (Planillas / Bases) |
|-------------------|-----------------|-----------------------------|
| `0`               | **Free / Gratis** | 10 / 1                      |
| `1`               | **Básico**      | 10 / 1                      |
| `2`               | **Estándar**    | 25 / 2                      |
| `3`               | **Premium**     | Ilimitado                   |

> **Nota:** Antes el plan Básico tenía límite de 2 bases, ahora se corrigió a **1 base** para coincidir con la definición oficial. El Estándar tiene **2 bases**.

## 🔄 3. Funcionalidad de Publicar/Borrador

El backend ahora permite cambiar el estado de una base de datos en ambas direcciones (Borrador ↔ Publicada) mediante el endpoint de actualización:

**Endpoint:** `PUT /api/PriceDatabase/{id}`

```json
{
  "id": 123,
  "name": "Nombre Base",
  "userId": 456,
  "status": 0  // 0 = Borrador, 1 = Publicada
}
```

- Si envían `status: 0`, la base vuelve a ser borrador.
- Si envían `status: 1`, se publica.
- Si no envían el campo `status`, se mantiene el valor actual.

¡Gracias! 🚀
