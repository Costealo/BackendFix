# 📋 DOCUMENTACIÓN - ACTUALIZACIÓN DE SUSCRIPCIÓN Y PAGO

## 1️⃣ ENDPOINT: Actualizar Suscripción o Pago

Para actualizar tanto el **Plan** como el **Método de Pago**, se usa el mismo endpoint `PUT`.

### Request
```
PUT /api/Subscriptions/{id}
Headers:
  Authorization: Bearer {JWT_TOKEN}
  Content-Type: application/json
```
> **Nota:** El `{id}` de la suscripción NO viene en `/api/profile`. 
> 
> ⚠️ **IMPORTANTE:** Primero deben llamar a `GET /api/Subscriptions/me` para obtener el ID de la suscripción activa antes de hacer el PUT.

---

## 2️⃣ FLUJO RECOMENDADO PARA EL FRONTEND

### Paso 1: Obtener ID de Suscripción
Antes de guardar, llamar a:
```
GET /api/Subscriptions/me
```
**Respuesta:**
```json
{
    "id": 15,  <-- ESTE ES EL ID QUE NECESITAN
    "userId": 25,
    "planType": 1,
    "isActive": true,
    ...
}
```

### Paso 2: Enviar Actualización (PUT)
Usar el ID obtenido para hacer el PUT a `/api/Subscriptions/15`.

#### Escenario A: Actualizar SOLO el Plan
(Botón "Mejorar suscripción")

```json
{
  "planType": 2,          // 0=Free, 1=Básico, 2=Estándar, 3=Premium
  "isActive": true        // Siempre true para mantenerla activa
}
```

#### Escenario B: Actualizar SOLO Método de Pago
(Botón "Cambiar método de pago")

```json
{
  "planType": 1,          // Mantener el plan actual
  "isActive": true,
  "paymentMethodType": "Tarjeta de crédito", // O "Tarjeta de débito"
  "cardLastFourDigits": "5678",
  "cardHolderName": "Ana García",
  "expirationDate": "05/28",
  "securityCode": "456"
}
```

---

## 3️⃣ MODELO DE DATOS (UpdateSubscriptionDto)

Todos los campos son opcionales, excepto `PlanType` e `IsActive`.

```json
{
  "planType": 0 | 1 | 2 | 3,       // Requerido
  "isActive": true,                // Requerido (enviar true)
  
  // Campos de pago (enviar solo si cambiaron)
  "paymentMethodType": "string",   // "Tarjeta de crédito" o "Tarjeta de débito"
  "cardLastFourDigits": "string",
  "cardHolderName": "string",
  "expirationDate": "string",      // "MM/YY"
  "securityCode": "string"         // CVV
}
```

---

## 4️⃣ RESUMEN PARA EL DESARROLLADOR FRONTEND

1. **Al cargar el perfil:**
   - Llamar a `GET /api/Subscriptions/me` y guardar el `id` de la suscripción en una variable (ej: `currentSubscriptionId`).

2. **Al hacer clic en "Guardar Cambios":**
   - Recopilar los datos del formulario.
   - Hacer `PUT /api/Subscriptions/{currentSubscriptionId}` con los datos nuevos.
   - Si es exitoso (Status 204), mostrar mensaje de éxito.

---

## ⚠️ NOTAS IMPORTANTES

- El endpoint `/api/profile` es de **SOLO LECTURA**. No intenten hacer POST o PUT a esa ruta.
- Para actualizar, SIEMPRE usar `/api/Subscriptions/{id}`.
- Recuerden enviar `isActive: true` en el PUT, de lo contrario podrían desactivar la suscripción accidentalmente.
