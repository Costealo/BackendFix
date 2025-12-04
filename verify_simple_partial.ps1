# Simplified verification script
$baseUrl = "http://localhost:8080"
$email = "ani@gmail.com"
$password = "456789"

Write-Host "VERIFICACION SIMPLE" -ForegroundColor Cyan

# Login
try {
    $loginBody = @{ email = $email; password = $password } | ConvertTo-Json
    $tokenResponse = Invoke-RestMethod -Uri "$baseUrl/api/Auth/login" -Method Post -Body $loginBody -ContentType "application/json"
    
    if ($tokenResponse.token) { $token = $tokenResponse.token } else { $token = $tokenResponse }
    
    $headers = @{ Authorization = "Bearer $token" }
    Write-Host "Login OK" -ForegroundColor Green
} catch {
    Write-Host "Login Error: $($_.Exception.Message)" -ForegroundColor Red; exit
}

# Get Subscription
try {
    $response = Invoke-WebRequest -Uri "$baseUrl/api/Subscriptions/me" -Method Get -Headers $headers
    $content = $response.Content
    Write-Host "Content received: $content" -ForegroundColor Gray
    
    $sub = $content | ConvertFrom-Json
    $subId = $sub.id
    
    if (-not $subId) {
        Write-Host "ID not found in response" -ForegroundColor Red
        exit
    }
    
    Write-Host "Sub ID: $subId" -ForegroundColor Green
} catch {
    Write-Host "Get Sub Error: $($_.Exception.Message)" -ForegroundColor Red; exit
}

# Update Payment Only
try {
    $body = @{
        isActive = $true
        paymentMethodType = "Tarjeta de crédito"
        cardLastFourDigits = "8888"
    } | ConvertTo-Json
    
    Invoke-RestMethod -Uri "$baseUrl/api/Subscriptions/$subId" -Method Put -Headers $headers -Body $body -ContentType "application/json"
    Write-Host "Update Payment OK" -ForegroundColor Green
} catch {
    Write-Host "Update Payment Error: $($_.Exception.Message)" -ForegroundColor Red; exit
}

# Verify
try {
    $finalSub = Invoke-RestMethod -Uri "$baseUrl/api/Subscriptions/me" -Method Get -Headers $headers
    Write-Host "Final Plan: $($finalSub.planType)" -ForegroundColor Yellow
    Write-Host "Final Card: $($finalSub.cardLastFourDigits)" -ForegroundColor Yellow
    
    if ($finalSub.planType -eq 3) { Write-Host "SUCCESS: Plan kept as Premium" -ForegroundColor Green }
    else { Write-Host "FAILURE: Plan changed" -ForegroundColor Red }
} catch {
    Write-Host "Verify Error: $($_.Exception.Message)" -ForegroundColor Red
}
