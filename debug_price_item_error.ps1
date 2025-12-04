# Script to debug the "Price item not found" error
$baseUrl = "http://localhost:8080"

# Login
$loginBody = @{ email = "spy@gmail.com"; password = "123456" } | ConvertTo-Json
$token = Invoke-RestMethod -Uri "$baseUrl/api/Auth/login" -Method Post -Body $loginBody -ContentType "application/json"
$headers = @{ Authorization = "Bearer $token" }

Write-Host "=== VERIFICANDO PRICE ITEMS ===" -ForegroundColor Cyan

# Los IDs que aparecen en los logs son: 91, 68, 90
$priceItemIds = @(91, 68, 90)

foreach ($itemId in $priceItemIds) {
    Write-Host "`nVerificando PriceItem ID: $itemId" -ForegroundColor Yellow
    
    try {
        # El backend no tiene endpoint directo para PriceItems, necesito obtenerlos via databases
        # Voy a buscar en qué database está
        $databases = Invoke-RestMethod -Uri "$baseUrl/api/PriceDatabase" -Method Get -Headers $headers
        
        $found = $false
        foreach ($db in $databases) {
            $dbDetails = Invoke-RestMethod -Uri "$baseUrl/api/PriceDatabase/$($db.id)" -Method Get -Headers $headers
            $item = $dbDetails.items | Where-Object { $_.id -eq $itemId }
            
            if ($item) {
                Write-Host "  ✅ ENCONTRADO en database: $($db.name) (ID: $($db.id))" -ForegroundColor Green
                Write-Host "     Product: $($item.product)"
                Write-Host "     Price: $($item.price)"
                Write-Host "     Unit: $($item.unit)"
                Write-Host "     Database UserId: $($db.userId)"
                $found = $true
                break
            }
        }
        
        if (-not $found) {
            Write-Host "  ❌ NO ENCONTRADO - Este item no existe" -ForegroundColor Red
        }
    } catch {
        Write-Host "  ❌ ERROR: $_" -ForegroundColor Red
    }
}

Write-Host "`n=== INTENTANDO CREAR PLANILLA Y AGREGAR ITEM ===" -ForegroundColor Cyan

# Crear planilla de prueba
try {
    $createWorkbook = @{
        name = "Test Debug"
        productionUnits = 1
        profitMarginPercentage = 0.20
        status = 0
    } | ConvertTo-Json
    
    $newWorkbook = Invoke-RestMethod -Uri "$baseUrl/api/Workbooks" -Method Post -Headers $headers -Body $createWorkbook -ContentType "application/json"
    Write-Host "✅ Planilla creada: ID $($newWorkbook.id)" -ForegroundColor Green
    
    # Intentar agregar item 91
    Write-Host "`nIntentando agregar PriceItem 91..." -ForegroundColor Yellow
    $addItem = @{
        priceItemId = 91
        quantity = 1
        unit = "kg"
        additionalCost = 0
    } | ConvertTo-Json
    
    try {
        $result = Invoke-RestMethod -Uri "$baseUrl/api/Workbooks/$($newWorkbook.id)/items" -Method Post -Headers $headers -Body $addItem -ContentType "application/json"
        Write-Host "✅ Item agregado exitosamente!" -ForegroundColor Green
    } catch {
        Write-Host "❌ ERROR al agregar item: $($_.Exception.Message)" -ForegroundColor Red
        if ($_.Exception.Response) {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $responseText = $reader.ReadToEnd()
            Write-Host "   Respuesta del servidor: $responseText" -ForegroundColor Red
        }
    }
    
} catch {
    Write-Host "❌ ERROR al crear planilla: $_" -ForegroundColor Red
}
