# Script to update subscription with SecurityCode for demo
# Run this to add a SecurityCode to the existing subscription

$baseUrl = "http://localhost:8080"

# First, login to get the token
$loginBody = @{
    email = "prueba@gmail.com"
    password = "123456"
} | ConvertTo-Json

$loginResponse = Invoke-RestMethod -Uri "$baseUrl/api/Auth/login" -Method Post -Body $loginBody -ContentType "application/json"
$token = $loginResponse

Write-Host "Token obtained: $token" -ForegroundColor Green

# Get current subscription
$headers = @{
    Authorization = "Bearer $token"
}

$subscription = Invoke-RestMethod -Uri "$baseUrl/api/Subscriptions/me" -Method Get -Headers $headers
Write-Host "Current subscription ID: $($subscription.id)" -ForegroundColor Cyan

# Update subscription with SecurityCode
$updateBody = @{
    planType = $subscription.planType
    isActive = $subscription.isActive
    cardLastFourDigits = $subscription.cardLastFourDigits
    cardHolderName = $subscription.cardHolderName
    expirationDate = $subscription.expirationDate
    paymentMethodType = $subscription.paymentMethodType
    securityCode = "999"  # Add the CVV here
} | ConvertTo-Json

$updateResponse = Invoke-RestMethod -Uri "$baseUrl/api/Subscriptions/$($subscription.id)" -Method Put -Body $updateBody -Headers $headers -ContentType "application/json"

Write-Host "Subscription updated with SecurityCode: 999" -ForegroundColor Green

# Verify the profile now returns the SecurityCode
$profile = Invoke-RestMethod -Uri "$baseUrl/api/profile" -Method Get -Headers $headers
Write-Host "`nProfile Response:" -ForegroundColor Yellow
$profile | ConvertTo-Json -Depth 3

Write-Host "`nSecurityCode in profile: $($profile.securityCode)" -ForegroundColor Magenta
