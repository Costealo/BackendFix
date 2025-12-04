# Script to verify partial subscription updates (PlanType optional)
$baseUrl = "http://localhost:8080"
$email = "ani@gmail.com"
$password = "456789"

Write-Host "=== VERIFICACIÓN DE ACTUALIZACIÓN PARCIAL (REQ) ===" -ForegroundColor Cyan

# 1. Login
$loginBody = @{ email = $email; password = $password } | ConvertTo-Json
try {
    $tokenResponse = Invoke-RestMethod -Uri "$baseUrl/api/Auth/login" -Method Post -Body $loginBody -ContentType "application/json"
    
    # Handle if token is returned as object or string
    if ($tokenResponse.token) { $token = $tokenResponse.token } else { $token = $tokenResponse }
    
    Write-Host "Token length: $($token.Length)" -ForegroundColor Gray
    $headers = @{ Authorization = "Bearer $token" }
    Write-Host "✓ Login exitoso" -ForegroundColor Green
} catch {
    Write-Host "✗ Error login: $($_.Exception.Message)" -ForegroundColor Red; exit
}

# 2. Get Subscription ID (Using Invoke-WebRequest to see raw body)
try {
    Write-Host "Obteniendo suscripción (RAW)..." -ForegroundColor Gray
    $response = Invoke-WebRequest -Uri "$baseUrl/api/Subscriptions/me" -Method Get -Headers $headers
    
    $rawContent = $response.Content
    Write-Host "Raw Content: $rawContent" -ForegroundColor Gray
    
    $sub = $rawContent | ConvertFrom-Json
    
    $subId = $sub.id
    if (-not $subId) { $subId = $sub.Id }
    
    if (-not $subId) {
        Write-Host "✗ ERROR: No se pudo obtener el ID de la suscripción" -ForegroundColor Red
        exit
    }

    Write-Host "✓ ID Suscripción: $subId" -ForegroundColor Green
    Write-Host "  Plan Actual: $($sub.planType)" -ForegroundColor Yellow
} catch {
    Write-Host "✗ Error getting sub: $($_.Exception.Message)" -ForegroundColor Red; exit
}

# 3. Set Plan to Premium (3) explicitly first
Write-Host "`nEstableciendo Plan a Premium (3)..." -ForegroundColor Cyan
$updatePlanBody = @{ planType = 3; isActive = $true } | ConvertTo-Json
try {
    Invoke-RestMethod -Uri "$baseUrl/api/Subscriptions/$subId" -Method Put -Headers $headers -Body $updatePlanBody -ContentType "application/json"
    Write-Host "✓ Plan actualizado a Premium" -ForegroundColor Green
} catch {
    Write-Host "✗ Error updating plan: $($_.Exception.Message)" -ForegroundColor Red; exit
}

# 4. Update ONLY Payment Info (NO planType sent)
Write-Host "`nActualizando SOLO Pago (sin enviar planType)..." -ForegroundColor Cyan
$updatePaymentBody = @{
    isActive = $true
    paymentMethodType = "Tarjeta de crédito"
    cardLastFourDigits = "9999"
    securityCode = "888"
} | ConvertTo-Json

Write-Host "Enviando JSON:" -ForegroundColor Gray
Write-Host $updatePaymentBody -ForegroundColor Gray

try {
    Invoke-RestMethod -Uri "$baseUrl/api/Subscriptions/$subId" -Method Put -Headers $headers -Body $updatePaymentBody -ContentType "application/json"
    Write-Host "✓ Actualización de pago enviada" -ForegroundColor Green
} catch {
    Write-Host "✗ Error updating payment: $($_.Exception.Message)" -ForegroundColor Red; exit
}

# 5. Verify Plan is STILL Premium
Write-Host "`nVerificando estado final..." -ForegroundColor Cyan
$finalSub = Invoke-RestMethod -Uri "$baseUrl/api/Subscriptions/me" -Method Get -Headers $headers

Write-Host "Plan Final: $($finalSub.planType)" -ForegroundColor Yellow
Write-Host "Tarjeta Final: $($finalSub.cardLastFourDigits)" -ForegroundColor Yellow

if ($finalSub.planType -eq 3) {
    Write-Host "✓ ÉXITO: El plan se mantuvo en Premium (3)!" -ForegroundColor Green
} else {
    Write-Host "✗ FALLO: El plan cambió a $($finalSub.planType)" -ForegroundColor Red
}

if ($finalSub.cardLastFourDigits -eq "9999") {
    Write-Host "✓ ÉXITO: La tarjeta se actualizó a 9999!" -ForegroundColor Green
} else {
    Write-Host "✗ FALLO: La tarjeta no se actualizó" -ForegroundColor Red
}
