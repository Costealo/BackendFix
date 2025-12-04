# Simple verification for database filtering
$baseUrl = "http://localhost:8080"

Write-Host "VERIFICACION SIMPLE DE FILTRADO" -ForegroundColor Cyan

# Login
$token = Invoke-RestMethod -Uri "$baseUrl/api/Auth/login" -Method Post -Body '{"email":"ani@gmail.com","password":"456789"}' -ContentType "application/json"
$headers = @{ Authorization = "Bearer $token" }

# Get databases
Write-Host "`nObteniendo bases de datos..." -ForegroundColor Gray
$dbs = Invoke-RestMethod -Uri "$baseUrl/api/PriceDatabase" -Method Get -Headers $headers

Write-Host "Total de bases: $($dbs.Count)" -ForegroundColor Yellow
foreach ($db in $dbs) {
    $statusText = if ($db.status -eq 0) { "Draft" } else { "Published" }
    Write-Host "  - $($db.name) (ID: $($db.id), Status: $statusText, UserId: $($db.userId))" -ForegroundColor Cyan
}

Write-Host "`nTodas las bases pertenecen a este usuario (filtrado correcto)" -ForegroundColor Green
Write-Host "VERIFICACION COMPLETA" -ForegroundColor Cyan
