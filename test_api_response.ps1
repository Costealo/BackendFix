# Test the API endpoint to see the actual JSON response
$baseUrl = "http://localhost:8080"

Write-Host "Testing API response..." -ForegroundColor Cyan

# Login as ani
$loginBody = @{
    email = "ani@gmail.com"
    password = "456789"
} | ConvertTo-Json

try {
    $token = Invoke-RestMethod -Uri "$baseUrl/api/Auth/login" -Method Post -Body $loginBody -ContentType "application/json; charset=utf-8"
    Write-Host "Logged in!" -ForegroundColor Green
    
    # Get profile
    $headers = @{
        Authorization = "Bearer $token"
    }
    
    $profile = Invoke-RestMethod -Uri "$baseUrl/api/profile" -Method Get -Headers $headers
    
    Write-Host "`nAPI Response:" -ForegroundColor Yellow
    Write-Host "PaymentMethodType: $($profile.paymentMethodType)" -ForegroundColor Cyan
    
    # Show the raw JSON
    $json = $profile | ConvertTo-Json -Depth 3
    Write-Host "`nFull JSON:" -ForegroundColor Yellow
    Write-Host $json
    
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}
