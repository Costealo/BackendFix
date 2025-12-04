# Script to verify Emma's actual plan in database
$baseUrl = "http://localhost:8080"

# Login as Emma
$loginBody = @{ email = "emma@gmail.com"; password = "123456" } | ConvertTo-Json
$token = Invoke-RestMethod -Uri "$baseUrl/api/Auth/login" -Method Post -Body $loginBody -ContentType "application/json"
$headers = @{ Authorization = "Bearer $token" }

# Get profile
$profile = Invoke-RestMethod -Uri "$baseUrl/api/profile" -Method Get -Headers $headers

Write-Host "=== PERFIL DE EMMA ===" -ForegroundColor Cyan
Write-Host "Email: $($profile.email)" -ForegroundColor Yellow
Write-Host "PlanType (numero): $($profile.planType)" -ForegroundColor Yellow
Write-Host "MaxWorkbooks: $($profile.maxWorkbooks)" -ForegroundColor Yellow
Write-Host "MaxDatabases: $($profile.maxDatabases)" -ForegroundColor Yellow

Write-Host "`n=== INTERPRETACION ===" -ForegroundColor Cyan
$planName = switch ($profile.planType) {
    0 { "Free" }
    1 { "Basico" }
    2 { "Estandar" }
    3 { "Premium" }
    default { "Desconocido" }
}
Write-Host "Plan real en BD: $planName" -ForegroundColor Green

# Get subscription directly
$sub = Invoke-RestMethod -Uri "$baseUrl/api/Subscriptions/me" -Method Get -Headers $headers
Write-Host "`n=== SUSCRIPCION DIRECTA ===" -ForegroundColor Cyan
Write-Host "ID: $($sub.id)" -ForegroundColor Yellow
Write-Host "PlanType: $($sub.planType)" -ForegroundColor Yellow
Write-Host "UserId: $($sub.userId)" -ForegroundColor Yellow
