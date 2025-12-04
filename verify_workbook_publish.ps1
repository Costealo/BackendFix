# Script to verify Workbook publish workflow
$baseUrl = "http://localhost:8080"

# Login
$loginBody = @{ email = "emma@gmail.com"; password = "123456" } | ConvertTo-Json
$token = Invoke-RestMethod -Uri "$baseUrl/api/Auth/login" -Method Post -Body $loginBody -ContentType "application/json"
$headers = @{ Authorization = "Bearer $token" }

Write-Host "=== CREANDO WORKBOOK COMO BORRADOR ===" -ForegroundColor Cyan
$createBody = @{
    name = "Test Workbook"
    productionUnits = 10
    profitMarginPercentage = 0.20
    status = 0  # Draft
} | ConvertTo-Json

$workbook = Invoke-RestMethod -Uri "$baseUrl/api/Workbooks" -Method Post -Headers $headers -Body $createBody -ContentType "application/json"
Write-Host "Workbook creado - ID: $($workbook.id), Status: $($workbook.status)" -ForegroundColor Yellow

Write-Host "`n=== PUBLICANDO WORKBOOK ===" -ForegroundColor Cyan
Invoke-RestMethod -Uri "$baseUrl/api/Workbooks/$($workbook.id)/publish" -Method Put -Headers $headers

Write-Host "`n=== VERIFICANDO STATUS ACTUALIZADO ===" -ForegroundColor Cyan
$updated = Invoke-RestMethod -Uri "$baseUrl/api/Workbooks/$($workbook.id)" -Method Get -Headers $headers
Write-Host "Status despues de publicar: $($updated.status)" -ForegroundColor $(if ($updated.status -eq 1) { "Green" } else { "Red" })

Write-Host "`n=== LISTANDO TODOS LOS WORKBOOKS ===" -ForegroundColor Cyan
$all = Invoke-RestMethod -Uri "$baseUrl/api/Workbooks" -Method Get -Headers $headers
Write-Host "Total workbooks: $($all.Count)" -ForegroundColor Yellow
foreach ($w in $all) {
    $statusText = if ($w.status -eq 0) { "DRAFT" } else { "PUBLISHED" }
    Write-Host "  - ID: $($w.id), Name: $($w.name), Status: $statusText ($($w.status))" -ForegroundColor $(if ($w.status -eq 1) { "Green" } else { "Gray" })
}

Write-Host "`n=== FILTRANDO BORRADORES vs PUBLICADAS ===" -ForegroundColor Cyan
$drafts = $all | Where-Object { $_.status -eq 0 }
$published = $all | Where-Object { $_.status -eq 1 }
Write-Host "Borradores: $($drafts.Count)" -ForegroundColor Gray
Write-Host "Publicadas: $($published.Count)" -ForegroundColor Green
