# 📋 DOCUMENTACIÓN BACKEND - PERFIL DE USUARIO

## Backend URL
```
http://localhost:8080
```

---

## 1️⃣ ENDPOINT: Obtener Perfil de Usuario

### Request
```
GET /api/profile
Headers:
  Authorization: Bearer {JWT_TOKEN}
```

### Response
```json
{
  "userName": "string",
  "email": "string",
  "password": "string",
  "organization": "string",
  "paymentMethodType": "string",
  "cardLastFourDigits": "string",
  "expirationDate": "string",
  "securityCode": "string",
  "planType": number,
  "startDate": "string",
  "endDate": "string | null",
  "isActive": boolean,
  "maxWorkbooks": number,
  "maxDatabases": number
}
```

### Ejemplo de Respuesta
```json
{
  "userName": "Ana García",
  "email": "ana@gmail.com",
  "password": "MiPassword123",
  "organization": "Empresa",
  "paymentMethodType": "Tarjeta de crédito",
  "cardLastFourDigits": "1234",
  "expirationDate": "12/30",
  "securityCode": "123",
  "planType": 1,
  "startDate": "2025-12-02T02:49:07.223332",
  "endDate": null,
  "isActive": true,
  "maxWorkbooks": 10,
  "maxDatabases": 2
}
```

---

## 2️⃣ ENDPOINT: Registro de Usuario

### Request
```
POST /api/Users
Content-Type: application/json
```

### Body (Todos los campos de suscripción son opcionales)
```json
{
  "name": "string",
  "email": "string",
  "password": "string",
  "role": 0 | 1,
  
  "planType": 0 | 1 | 2 | 3,
  "cardLastFourDigits": "string",
  "cardHolderName": "string",
  "expirationDate": "string",
  "paymentMethodType": "string",
  "securityCode": "string"
}
```

### Ejemplo de Request
```json
{
  "name": "Ana García",
  "email": "ana@gmail.com",
  "password": "MiPassword123",
  "role": 0,
  
  "planType": 1,
  "cardLastFourDigits": "1234",
  "cardHolderName": "Ana García",
  "expirationDate": "12/30",
  "paymentMethodType": "Tarjeta de crédito",
  "securityCode": "123"
}
```

---

## 3️⃣ VALORES VÁLIDOS

### `role`
- `0` = Empresa
- `1` = Independiente

### `planType`
- `0` = Free
- `1` = Básico
- `2` = Estándar
- `3` = Premium

### `paymentMethodType`
- `"Tarjeta de débito"` ✅ CON ACENTO
- `"Tarjeta de crédito"` ✅ CON ACENTO

### `expirationDate`
- Formato: `"MM/YY"`
- Ejemplo: `"12/30"`

### `securityCode`
- String de 3-4 dígitos
- Ejemplo: `"123"` o `"1234"`

---

## 4️⃣ ALIASES ACEPTADOS (Registro)

El backend acepta estos nombres alternativos:

| Campo Oficial | Aliases Aceptados |
|--------------|-------------------|
| `securityCode` | `cvv`, `cvc` |
| `expirationDate` | `expiryDate` |

**Ejemplo con aliases:**
```json
{
  "name": "Ana García",
  "email": "ana@gmail.com",
  "password": "MiPassword123",
  "role": 0,
  "cvv": "123",
  "expiryDate": "12/30"
}
```

---

## 5️⃣ NOTAS IMPORTANTES

✅ **Todos los campos de suscripción son opcionales** en el registro
✅ **Si no se envían, el usuario tendrá plan Free por defecto**
✅ **El endpoint `/api/profile` devuelve TODOS los datos reales** (sin asteriscos ni placeholders)
✅ **La contraseña y CVV se muestran en texto plano** (solo para demo universitaria)

---

## 6️⃣ EJEMPLO COMPLETO DE FLUJO

### 1. Registro
```javascript
POST /api/Users
{
  "name": "Ana García",
  "email": "ana@gmail.com",
  "password": "MiPassword123",
  "role": 0,
  "planType": 1,
  "cardLastFourDigits": "1234",
  "cardHolderName": "Ana García",
  "expirationDate": "12/30",
  "paymentMethodType": "Tarjeta de crédito",
  "securityCode": "123"
}
```

### 2. Login
```javascript
POST /api/Auth/login
{
  "email": "ana@gmail.com",
  "password": "MiPassword123"
}

// Response: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

### 3. Obtener Perfil
```javascript
GET /api/profile
Headers: {
  "Authorization": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}

// Response: { userName: "Ana García", password: "MiPassword123", ... }
```

---

## ⚠️ ADVERTENCIA DE SEGURIDAD

**ESTO ES SOLO PARA DEMO UNIVERSITARIA**

En producción NUNCA:
- ❌ Guardar contraseñas en texto plano
- ❌ Guardar CVV en la base de datos
- ❌ Devolver contraseñas o CVV en APIs
