# Script para verificar soporte de unidades genericas
$baseUrl = "http://localhost:8080"

Write-Host "VERIFICACION DE UNIDADES GENERICAS" -ForegroundColor Cyan

# 1. Login
Write-Host "1. Haciendo login..." -ForegroundColor Yellow
$loginBody = @{
    email = "prueba@gmail.com"
    password = "123456"
} | ConvertTo-Json

try {
    $token = Invoke-RestMethod -Uri "$baseUrl/api/Auth/login" -Method Post -Body $loginBody -ContentType "application/json"
    $headers = @{ Authorization = "Bearer $token" }
    Write-Host "   Login exitoso" -ForegroundColor Green
} catch {
    Write-Host "   Login fallo. Asegurate que el servidor este corriendo." -ForegroundColor Red
    exit
}

# 2. Verificar que las unidades genericas esten en el catalogo
Write-Host ""
Write-Host "2. Verificando catalogo de unidades..." -ForegroundColor Yellow
try {
    $validUnits = Invoke-RestMethod -Uri "$baseUrl/api/Units/valid" -Method Get -Headers $headers
    
    $genericUnits = @("unidad", "pieza", "paquete", "caja", "bolsa")
    $allFound = $true
    
    foreach ($unit in $genericUnits) {
        if ($validUnits -contains $unit) {
            Write-Host "   OK: '$unit' esta en el catalogo" -ForegroundColor Green
        } else {
            Write-Host "   ERROR: '$unit' NO esta en el catalogo" -ForegroundColor Red
            $allFound = $false
        }
    }
    
    if ($allFound) {
        Write-Host "   EXITO: Todas las unidades genericas estan disponibles" -ForegroundColor Green
    }
} catch {
    Write-Host "   Error verificando catalogo" -ForegroundColor Red
    exit
}

# 3. Crear base de datos con item usando "unidad"
Write-Host ""
Write-Host "3. Creando base de datos de prueba..." -ForegroundColor Yellow
$dbBody = @{
    name = "Test Unidades Genericas"
    status = 0
} | ConvertTo-Json

try {
    $db = Invoke-RestMethod -Uri "$baseUrl/api/PriceDatabase" -Method Post -Body $dbBody -Headers $headers -ContentType "application/json"
    Write-Host "   Base de datos creada: ID $($db.id)" -ForegroundColor Green
} catch {
    Write-Host "   Error creando base de datos" -ForegroundColor Red
    exit
}

# 4. Agregar item con unidad generica
Write-Host ""
Write-Host "4. Agregando item: Tornillos - 5 bolivianos por UNIDAD..." -ForegroundColor Yellow
$itemBody = @{
    product = "Tornillos"
    price = 5.00
    unit = "unidad"
} | ConvertTo-Json

try {
    $priceItem = Invoke-RestMethod -Uri "$baseUrl/api/PriceDatabase/$($db.id)/items" -Method Post -Body $itemBody -Headers $headers -ContentType "application/json"
    Write-Host "   Item creado exitosamente: ID $($priceItem.id)" -ForegroundColor Green
    Write-Host "   Precio: $($priceItem.price) Bs por $($priceItem.unit)" -ForegroundColor Cyan
} catch {
    Write-Host "   ERROR: No se pudo crear el item" -ForegroundColor Red
    Write-Host "   $($_.Exception.Message)" -ForegroundColor Red
    
    # Cleanup
    Invoke-RestMethod -Uri "$baseUrl/api/PriceDatabase/$($db.id)" -Method Delete -Headers $headers
    exit
}

# 5. Crear planilla
Write-Host ""
Write-Host "5. Creando planilla de prueba..." -ForegroundColor Yellow
$workbookBody = @{
    name = "Test Unidades Genericas"
    productionUnits = 1
    profitMarginPercentage = 0.20
    status = 0
} | ConvertTo-Json

try {
    $workbook = Invoke-RestMethod -Uri "$baseUrl/api/Workbooks" -Method Post -Body $workbookBody -Headers $headers -ContentType "application/json"
    Write-Host "   Planilla creada: ID $($workbook.id)" -ForegroundColor Green
} catch {
    Write-Host "   Error creando planilla" -ForegroundColor Red
    Invoke-RestMethod -Uri "$baseUrl/api/PriceDatabase/$($db.id)" -Method Delete -Headers $headers
    exit
}

# 6. Agregar item a planilla (100 unidades)
Write-Host ""
Write-Host "6. Agregando a planilla: 100 UNIDADES de tornillos..." -ForegroundColor Yellow
$wbItemBody = @{
    priceItemId = $priceItem.id
    quantity = 100
    unit = "unidad"
    additionalCost = 0
} | ConvertTo-Json

try {
    Invoke-RestMethod -Uri "$baseUrl/api/Workbooks/$($workbook.id)/items" -Method Post -Body $wbItemBody -Headers $headers -ContentType "application/json"
    Write-Host "   Item agregado a planilla" -ForegroundColor Green
} catch {
    Write-Host "   Error agregando item" -ForegroundColor Red
    Invoke-RestMethod -Uri "$baseUrl/api/Workbooks/$($workbook.id)" -Method Delete -Headers $headers
    Invoke-RestMethod -Uri "$baseUrl/api/PriceDatabase/$($db.id)" -Method Delete -Headers $headers
    exit
}

# 7. Obtener planilla con calculos
Write-Host ""
Write-Host "7. Verificando calculos..." -ForegroundColor Yellow
try {
    $result = Invoke-RestMethod -Uri "$baseUrl/api/Workbooks/$($workbook.id)" -Method Get -Headers $headers
    
    if ($result.items.Count -gt 0) {
        $item = $result.items[0]
        
        Write-Host ""
        Write-Host "RESULTADO:" -ForegroundColor Cyan
        Write-Host "  Producto: $($item.productName)" -ForegroundColor White
        Write-Host "  Precio Original: $($item.originalPrice) Bs por $($item.originalUnit)" -ForegroundColor White
        Write-Host "  Cantidad Usada: $($item.quantityUsed) $($item.unitUsed)" -ForegroundColor White
        Write-Host "  Costo Calculado: $($item.calculatedCost) Bs" -ForegroundColor Cyan
        Write-Host "  Mensaje: $($item.conversionMessage)" -ForegroundColor Gray
        
        Write-Host ""
        Write-Host "VALIDACION:" -ForegroundColor Yellow
        Write-Host "  Precio: 5 Bs/unidad" -ForegroundColor White
        Write-Host "  Cantidad: 100 unidades" -ForegroundColor White
        Write-Host "  Esperado: 5 x 100 = 500 Bs" -ForegroundColor White
        
        if ($item.calculatedCost -eq 500.00) {
            Write-Host ""
            Write-Host "EXITO: Calculo correcto con unidades genericas!" -ForegroundColor Green
            Write-Host "El sistema detecto que es unidad generica y uso ratio 1:1" -ForegroundColor Green
        } else {
            Write-Host ""
            Write-Host "ERROR: Costo calculado = $($item.calculatedCost) (esperado: 500)" -ForegroundColor Red
        }
    } else {
        Write-Host "ERROR: No hay items en la planilla" -ForegroundColor Red
    }
    
} catch {
    Write-Host "Error obteniendo planilla" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

# 8. Cleanup
Write-Host ""
Write-Host "8. Limpiando datos de prueba..." -ForegroundColor Gray
try {
    Invoke-RestMethod -Uri "$baseUrl/api/Workbooks/$($workbook.id)" -Method Delete -Headers $headers
    Invoke-RestMethod -Uri "$baseUrl/api/PriceDatabase/$($db.id)" -Method Delete -Headers $headers
    Write-Host "   Limpieza completada" -ForegroundColor Green
} catch {
    Write-Host "   Advertencia: No se pudo limpiar completamente" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "VERIFICACION COMPLETADA" -ForegroundColor Cyan
