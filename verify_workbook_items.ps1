# Script to check if workbooks have items in database
$baseUrl = "http://localhost:8080"

# Login
$loginBody = @{ email = "spy@gmail.com"; password = "123456" } | ConvertTo-Json
$token = Invoke-RestMethod -Uri "$baseUrl/api/Auth/login" -Method Post -Body $loginBody -ContentType "application/json"
$headers = @{ Authorization = "Bearer $token" }

Write-Host "=== VERIFICANDO WORKBOOKS Y SUS ITEMS ===" -ForegroundColor Cyan

# Get all workbooks
$workbooks = Invoke-RestMethod -Uri "$baseUrl/api/Workbooks" -Method Get -Headers $headers

foreach ($wb in $workbooks) {
    Write-Host "`nWorkbook ID: $($wb.id) - Name: $($wb.name)" -ForegroundColor Yellow
    
    # Get full details
    $details = Invoke-RestMethod -Uri "$baseUrl/api/Workbooks/$($wb.id)" -Method Get -Headers $headers
    
    Write-Host "  Items count: $($details.items.Count)" -ForegroundColor $(if ($details.items.Count -gt 0) { "Green" } else { "Red" })
    
    if ($details.items.Count -gt 0) {
        foreach ($item in $details.items) {
            Write-Host "    - PriceItemId: $($item.priceItemId), Quantity: $($item.quantity), Unit: $($item.unit)" -ForegroundColor Gray
        }
    } else {
        Write-Host "    (Sin items guardados)" -ForegroundColor Red
    }
}

Write-Host "`n=== VERIFICANDO BASES DE DATOS ===" -ForegroundColor Cyan
$databases = Invoke-RestMethod -Uri "$baseUrl/api/PriceDatabase" -Method Get -Headers $headers
Write-Host "Total bases de datos: $($databases.Count)" -ForegroundColor Yellow

foreach ($db in $databases) {
    Write-Host "`nDatabase ID: $($db.id) - Name: $($db.name)" -ForegroundColor Yellow
    $dbDetails = Invoke-RestMethod -Uri "$baseUrl/api/PriceDatabase/$($db.id)" -Method Get -Headers $headers
    Write-Host "  Items count: $($dbDetails.items.Count)" -ForegroundColor Green
    
    if ($dbDetails.items.Count -gt 0) {
        foreach ($item in $dbDetails.items) {
            Write-Host "    - ID: $($item.id), Product: $($item.product), Price: $($item.price), Unit: $($item.unit)" -ForegroundColor Gray
        }
    }
}
