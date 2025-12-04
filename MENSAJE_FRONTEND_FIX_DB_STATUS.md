# 🐛 Fix: Actualización de Status en PriceDatabase

Hola equipo,

Confirmamos y corregimos el problema reportado sobre la actualización del estado de las Bases de Datos.

## 🔍 Causa Raíz
El DTO `UpdatePriceDatabaseDto` en el backend **no incluía la propiedad `Status`**. Por esta razón, aunque el frontend enviaba el campo correctamente en el JSON, el backend lo ignoraba durante la deserialización y nunca llegaba al controlador.

## 🛠️ Solución Aplicada
Hemos realizado los siguientes cambios en el backend:

1.  **DTO Actualizado:** Se agregó `public EntityStatus? Status { get; set; }` al `UpdatePriceDatabaseDto`.
2.  **Lógica del Controlador:** Se actualizó `PriceDatabaseController` para verificar si `Status` tiene valor y, de ser así, actualizar la entidad en la base de datos.

## ✅ Comportamiento Esperado
Ahora el endpoint `PUT /api/PriceDatabase/{id}` procesará correctamente el cambio de estado:

```json
// Para volver a Borrador
{
  "id": 16,
  "name": "Nombre DB",
  "userId": 27,
  "status": 0  // ✅ Ahora el backend procesará esto y cambiará el estado a Draft
}

// Para Publicar
{
  "id": 16,
  "name": "Nombre DB",
  "userId": 27,
  "status": 1  // ✅ Cambiará el estado a Published
}
```

El backend ya ha sido actualizado y reiniciado. Por favor, intenten nuevamente.

Gracias por el reporte detallado. 🚀
