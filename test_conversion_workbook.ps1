# Script para testear conversion de unidades en planillas
$baseUrl = "http://localhost:8080"

Write-Host "TEST DE CONVERSION DE UNIDADES EN PLANILLAS" -ForegroundColor Cyan

# 1. Login
Write-Host "Haciendo login..." -ForegroundColor Yellow
$loginBody = @{
    email = "prueba@gmail.com"
    password = "123456"
} | ConvertTo-Json

try {
    $token = Invoke-RestMethod -Uri "$baseUrl/api/Auth/login" -Method Post -Body $loginBody -ContentType "application/json"
    $headers = @{ Authorization = "Bearer $token" }
    Write-Host "Login exitoso" -ForegroundColor Green
} catch {
    Write-Host "Login fallo" -ForegroundColor Red
    exit
}

# 2. Crear base de datos de precios
Write-Host "Creando base de datos de precios..." -ForegroundColor Yellow
$dbBody = @{
    name = "Test Conversiones"
    status = 0
} | ConvertTo-Json

try {
    $db = Invoke-RestMethod -Uri "$baseUrl/api/PriceDatabase" -Method Post -Body $dbBody -Headers $headers -ContentType "application/json"
    Write-Host "Base de datos creada: ID $($db.id)" -ForegroundColor Green
} catch {
    Write-Host "Error creando base de datos" -ForegroundColor Red
    exit
}

# 3. Agregar item con precio en KILOGRAMOS
Write-Host "Agregando Harina: 10 dolares por KILOGRAMO..." -ForegroundColor Yellow
$itemBody = @{
    product = "Harina"
    price = 10.00
    unit = "kilogram"
} | ConvertTo-Json

try {
    $priceItem = Invoke-RestMethod -Uri "$baseUrl/api/PriceDatabase/$($db.id)/items" -Method Post -Body $itemBody -Headers $headers -ContentType "application/json"
    Write-Host "Item creado: ID $($priceItem.id)" -ForegroundColor Green
} catch {
    Write-Host "Error creando item" -ForegroundColor Red
    exit
}

# 4. Crear planilla
Write-Host "Creando planilla..." -ForegroundColor Yellow
$workbookBody = @{
    name = "Test Conversion"
    productionUnits = 10
    profitMarginPercentage = 0.20
    status = 0
} | ConvertTo-Json

try {
    $workbook = Invoke-RestMethod -Uri "$baseUrl/api/Workbooks" -Method Post -Body $workbookBody -Headers $headers -ContentType "application/json"
    Write-Host "Planilla creada: ID $($workbook.id)" -ForegroundColor Green
} catch {
    Write-Host "Error creando planilla" -ForegroundColor Red
    exit
}

# 5. Agregar item a planilla usando GRAMOS
Write-Host "Agregando a planilla: 100 GRAMOS de harina..." -ForegroundColor Yellow
$wbItemBody = @{
    priceItemId = $priceItem.id
    quantity = 100
    unit = "gram"
    additionalCost = 0
} | ConvertTo-Json

try {
    Invoke-RestMethod -Uri "$baseUrl/api/Workbooks/$($workbook.id)/items" -Method Post -Body $wbItemBody -Headers $headers -ContentType "application/json"
    Write-Host "Item agregado a planilla" -ForegroundColor Green
} catch {
    Write-Host "Error agregando item" -ForegroundColor Red
    exit
}

# 6. Obtener planilla con calculos
Write-Host "Obteniendo planilla con calculos..." -ForegroundColor Yellow
try {
    $result = Invoke-RestMethod -Uri "$baseUrl/api/Workbooks/$($workbook.id)" -Method Get -Headers $headers
    
    Write-Host "RESULTADO DEL CALCULO" -ForegroundColor Cyan
    Write-Host "Planilla: $($result.name)" -ForegroundColor White
    
    if ($result.items.Count -gt 0) {
        $item = $result.items[0]
        
        Write-Host "Item:" -ForegroundColor Yellow
        Write-Host "   Producto: $($item.productName)" -ForegroundColor White
        Write-Host "   Precio Original: $($item.originalPrice) por $($item.originalUnit)" -ForegroundColor White
        Write-Host "   Cantidad Usada: $($item.quantityUsed) $($item.unitUsed)" -ForegroundColor White
        Write-Host "   Costo Calculado: $($item.calculatedCost)" -ForegroundColor Cyan
        Write-Host "   Mensaje de Conversion: $($item.conversionMessage)" -ForegroundColor Gray
        
        Write-Host "Validacion:" -ForegroundColor Yellow
        Write-Host "   Precio en DB: 10 dolares por kg" -ForegroundColor White
        Write-Host "   Cantidad usada: 100g = 0.1 kg" -ForegroundColor White
        Write-Host "   Costo esperado: 10 x 0.1 = 1.00 dolar" -ForegroundColor White
        
        if ($item.calculatedCost -eq 1.00) {
            Write-Host "CONVERSION CORRECTA!" -ForegroundColor Green
        } elseif ($item.calculatedCost -eq 10.00) {
            Write-Host "ERROR: Esta usando precio sin conversion" -ForegroundColor Red
        } else {
            Write-Host "Costo calculado: $($item.calculatedCost) (verificar)" -ForegroundColor Yellow
        }
        
    } else {
        Write-Host "No hay items en la planilla" -ForegroundColor Red
    }
    
} catch {
    Write-Host "Error obteniendo planilla" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit
}

# 7. Cleanup
Write-Host "Limpiando datos de prueba..." -ForegroundColor Gray
try {
    Invoke-RestMethod -Uri "$baseUrl/api/Workbooks/$($workbook.id)" -Method Delete -Headers $headers
    Invoke-RestMethod -Uri "$baseUrl/api/PriceDatabase/$($db.id)" -Method Delete -Headers $headers
    Write-Host "Limpieza completada" -ForegroundColor Green
} catch {
    Write-Host "Advertencia: No se pudo limpiar completamente" -ForegroundColor Yellow
}

Write-Host "TEST COMPLETADO" -ForegroundColor Cyan
