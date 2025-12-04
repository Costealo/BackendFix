# Script to check what GET /api/Workbooks/{id} returns
$baseUrl = "http://localhost:8080"

# Login as spy
$loginBody = @{ email = "spy@gmail.com"; password = "123456" } | ConvertTo-Json
$token = Invoke-RestMethod -Uri "$baseUrl/api/Auth/login" -Method Post -Body $loginBody -ContentType "application/json"
$headers = @{ Authorization = "Bearer $token" }

Write-Host "=== VERIFICANDO PLANILLA 'PAN' ===" -ForegroundColor Cyan

# Get workbook ID 7 (pan)
$workbook = Invoke-RestMethod -Uri "$baseUrl/api/Workbooks/7" -Method Get -Headers $headers

Write-Host "`nDatos de la planilla:" -ForegroundColor Yellow
Write-Host "  ID: $($workbook.id)"
Write-Host "  Name: $($workbook.name)"
Write-Host "  ProductionUnits: $($workbook.productionUnits)"
Write-Host "  ProfitMarginPercentage: $($workbook.profitMarginPercentage)"
Write-Host "  TargetSalePrice: $($workbook.targetSalePrice)"
Write-Host "  ActualProfitMargin: $($workbook.actualProfitMargin)"
Write-Host "`nItems count: $($workbook.items.Count)" -ForegroundColor $(if ($workbook.items.Count -gt 0) { "Green" } else { "Red" })

if ($workbook.items.Count -gt 0) {
    foreach ($item in $workbook.items) {
        Write-Host "`nItem ID: $($item.id)" -ForegroundColor Yellow
        Write-Host "  ProductName: $($item.productName)"
        Write-Host "  PriceItemId: $($item.priceItemId)"
        Write-Host "  OriginalPrice: $($item.originalPrice)"
        Write-Host "  OriginalUnit: $($item.originalUnit)"
        Write-Host "  QuantityUsed: $($item.quantityUsed)"
        Write-Host "  UnitUsed: $($item.unitUsed)"
        Write-Host "  CalculatedCost: $($item.calculatedCost)"
    }
} else {
    Write-Host "`n❌ NO HAY ITEMS - Por eso aparece vacía!" -ForegroundColor Red
}

Write-Host "`n=== JSON COMPLETO ===" -ForegroundColor Cyan
$workbook | ConvertTo-Json -Depth 5
