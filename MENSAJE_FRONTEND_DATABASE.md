# 🗄️ Actualización Backend: Base de Datos - Filtrado por Usuario y Borradores

Hola equipo,

El backend de **PriceDatabase** ya está actualizado para soportar:
1. **Filtrado por usuario** (seguridad)
2. **Estados Draft y Published** (borradores vs. publicadas)

---

## 🔒 1. Filtrado por Usuario (Seguridad)

**Problema resuelto**: Antes, `GET /api/PriceDatabase` devolvía bases de datos de TODOS los usuarios.

**Ahora**: Todos los endpoints filtran automáticamente por el `userId` del JWT. Cada usuario solo puede ver y manipular sus propias bases.

### Endpoints afectados:
- `GET /api/PriceDatabase` → Solo devuelve bases del usuario autenticado
- `GET /api/PriceDatabase/{id}` →  401/404 si la base no pertenece al usuario
- `PUT /api/PriceDatabase/{id}` → 401/404 si la base no pertenece al usuario
- `DELETE /api/PriceDatabase/{id}` → 401/404 si la base no pertenece al usuario
- `PUT /api/PriceDatabase/{id}/refresh` → 401/404 si la base no pertenece al usuario
- `GET /api/PriceDatabase/{id}/items` → 401/404 si la base no pertenece al usuario

**No necesitan hacer nada especial**: El backend usa el token JWT para identificar al usuario.

---

## 📝 2. Borradores vs. Publicadas

Ahora pueden marcar una base como **borrador** (Draft) o **publicada** (Published).

### Campo `status` al crear una base

Al llamar `POST /api/PriceDatabase`, pueden enviar opcionalmente el campo `status`:

```json
POST /api/PriceDatabase
{
  "name": "Mi base de precios",
  "status": 0  // 0 = Draft, 1 = Published
}
```

**Valores del campo `status`:**
- `0` = Draft (borrador)
- `1` = Published (publicada)
- **Si no envían `status`**: por defecto será Draft (`0`)

### Ejemplos de uso:

**Botón "Guardar borrador"** → enviar `status: 0`:
```json
{
  "name": "Base borrador",
  "status": 0
}
```

**Botón "Guardar" / "Rellenar"** → enviar `status: 1`:
```json
{
  "name": "Base final",
  "status": 1
}
```

---

## 🚀 3. Endpoint para Publicar Borradores

Si una base se guardó como borrador y luego quieren publicarla:

```http
PUT /api/PriceDatabase/{id}/publish
```

**Headers**: `Authorization: Bearer {token}`

**Respuesta**: `204 No Content` (éxito)

**Ejemplo**:
```bash
curl -X PUT http://localhost:8080/api/PriceDatabase/5/publish \
  -H "Authorization: Bearer {token}"
```

Este endpoint cambia el `status` de `0` (Draft) a `1` (Published).

---

## 📋 4. Mostrar Borradores vs. Publicadas en la UI

Al llamar `GET /api/PriceDatabase`, la respuesta incluye el campo `status`:

```json
[
  {
    "id": 1,
    "name": "Base borrador",
    "status": 0,  // Draft
    "itemCount": 5,
    ...
  },
  {
    "id": 2,
    "name": "Base final",
    "status": 1,  // Published
    "itemCount": 10,
    ...
  }
]
```

**En el frontend**:
- **Sección "Borradores"**: Filtrar por `status === 0`
- **Sección "Más recientes"**: Filtrar por `status === 1`

---

## ✅ Resumen de Cambios

| Acción | Antes | Después |
|--------|-------|---------|
| Listar bases | Devolvía de todos los usuarios | Solo del usuario autenticado |
| Crear base | Sin estado | Puede especificar Draft (`0`) o Published (`1`) |
| Publicar borrador | No existía | `PUT /api/PriceDatabase/{id}/publish` |
| Seguridad | Sin filtrado | Todos los endpoints filtran por `userId` |

---

¡Listo para integrar! Si tienen dudas, me avisan. 🚀
