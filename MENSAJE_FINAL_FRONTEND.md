# 🚀 Actualización Backend: Separación de Suscripción y Pagos

Hola equipo,

El backend ya está listo para soportar las nuevas pantallas de perfil. Aquí les dejo el resumen técnico para conectar todo:

## 1. El Endpoint es el mismo para ambos casos
Usaremos siempre:
`PUT /api/Subscriptions/{id}`

> 💡 **Recuerden:** El `{id}` de la suscripción se obtiene llamando primero a `GET /api/Subscriptions/me`.

## 2. Pantalla A: "Ver opciones" (Cambiar Plan)
Cuando el usuario elija un nuevo plan (Básico, Estándar, Premium), envíen **SOLO** el plan:

```json
{
  "planType": 2,       // 1=Básico, 2=Estándar, 3=Premium
  "isActive": true
}
```
✅ **No envíen campos de pago.** El backend actualizará solo el plan.

## 3. Pantalla B: "Cambiar método de pago"
Cuando el usuario edite su tarjeta, envíen **SOLO** los datos de pago:

```json
{
  "isActive": true,
  "paymentMethodType": "Tarjeta de crédito",
  "cardLastFourDigits": "1234",
  "cardHolderName": "Juan Perez",
  "expirationDate": "12/30",
  "securityCode": "123"
}
```
✅ **No envíen `planType`.**
El backend es inteligente: si no recibe el plan, **mantiene el plan actual del usuario**. Ya verificamos que esto NO causa "downgrades" accidentales al plan gratuito.

## 📄 Documentación Completa
Para ver todos los detalles y modelos, revisen el archivo:
`DOCUMENTACION_SUSCRIPCION.md`

¡Listos para integrar! 🟢
