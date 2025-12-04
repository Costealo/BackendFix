# Verification script for PriceDatabase user filtering and draft/published status
$baseUrl = "http://localhost:8080"

Write-Host "=== VERIFICACION DE PRICEDATABASE ===" -ForegroundColor Cyan

# Function to login and get token
function Get-UserToken($email, $password) {
    $body = @{ email = $email; password = $password } | ConvertTo-Json
    $token = Invoke-RestMethod -Uri "$baseUrl/api/Auth/login" -Method Post -Body $body -ContentType "application/json"
    return $token
}

# Login as ani
Write-Host "`n1. Login como ani@gmail.com..." -ForegroundColor Gray
$token1 = Get-UserToken "ani@gmail.com" "456789"
$headers1 = @{ Authorization = "Bearer $token1" }
Write-Host "Token obtenido" -ForegroundColor Green

# Get current databases
Write-Host "`n2. Obteniendo bases actuales..." -ForegroundColor Gray
$dbsBefore = Invoke-RestMethod -Uri "$baseUrl/api/PriceDatabase" -Method Get -Headers $headers1
Write-Host "Bases actuales: $($dbsBefore.Count)" -ForegroundColor Yellow

# Create Draft database
Write-Host "`n3. Creando base DRAFT..." -ForegroundColor Gray
$draftBody = @{
    name = "Test Draft DB"
    status = 0
} | ConvertTo-Json
$draftDb = Invoke-RestMethod -Uri "$baseUrl/api/PriceDatabase" -Method Post -Headers $headers1 -Body $draftBody -ContentType "application/json"
Write-Host "Base Draft creada: ID=$($draftDb.id), Status=$($draftDb.status)" -ForegroundColor Green

# Create Published database
Write-Host "`n4. Creando base PUBLISHED..." -ForegroundColor Gray
$pubBody = @{
    name = "Test Published DB"
    status = 1
} | ConvertTo-Json
$pubDb = Invoke-RestMethod -Uri "$baseUrl/api/PriceDatabase" -Method Post -Headers $headers1 -Body $pubBody -ContentType "application/json"
Write-Host "Base Published creada: ID=$($pubDb.id), Status=$($pubDb.status)" -ForegroundColor Green

# Verify ani sees both
Write-Host "`n5. Verificando que ani ve sus bases..." -ForegroundColor Gray
$dbsAfter = Invoke-RestMethod -Uri "$baseUrl/api/PriceDatabase" -Method Get -Headers $headers1
$testDbs = $dbsAfter | Where-Object { $_.name -like "Test*DB" }
Write-Host "Bases de test encontradas: $($testDbs.Count)" -ForegroundColor Yellow

if ($testDbs.Count -ge 2) {
    Write-Host "CORRECTO: Usuario ve sus bases" -ForegroundColor Green
    $drafts = ($testDbs | Where-Object { $_.status -eq 0 }).Count
    $pubs = ($testDbs | Where-Object { $_.status -eq 1 }).Count
    Write-Host "  Borradores: $drafts" -ForegroundColor Cyan
    Write-Host "  Publicadas: $pubs" -ForegroundColor Cyan
} else {
    Write-Host "ERROR: No se encontraron bases de test" -ForegroundColor Red
}

# Test publish endpoint
Write-Host "`n6. Probando endpoint /publish..." -ForegroundColor Gray
try {
    Invoke-RestMethod -Uri "$baseUrl/api/PriceDatabase/$($draftDb.id)/publish" -Method Put -Headers $headers1
    Write-Host "CORRECTO: Endpoint publish funciona" -ForegroundColor Green
    
    $updatedDb = Invoke-RestMethod -Uri "$baseUrl/api/PriceDatabase/$($draftDb.id)" -Method Get -Headers $headers1
    if ($updatedDb.status -eq 1) {
        Write-Host "CORRECTO: Estado cambio a Published" -ForegroundColor Green
    } else {
        Write-Host "ERROR: Estado no cambio" -ForegroundColor Red
    }
} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

# Cleanup
Write-Host "`n7. Limpiando..." -ForegroundColor Gray
try {
    Invoke-RestMethod -Uri "$baseUrl/api/PriceDatabase/$($draftDb.id)" -Method Delete -Headers $headers1
    Invoke-RestMethod -Uri "$baseUrl/api/PriceDatabase/$($pubDb.id)" -Method Delete -Headers $headers1
    Write-Host "Bases eliminadas" -ForegroundColor Green
} catch {
    Write-Host "Advertencia: No se pudo limpiar" -ForegroundColor Yellow
}

Write-Host "`n=== COMPLETO ===" -ForegroundColor Cyan
