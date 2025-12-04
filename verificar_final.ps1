# Final verification
$baseUrl = "http://localhost:8080"

Write-Host "VERIFICACION FINAL" -ForegroundColor Cyan

$loginBody = @{
    email = "ani@gmail.com"
    password = "456789"
} | ConvertTo-Json

try {
    $token = Invoke-RestMethod -Uri "$baseUrl/api/Auth/login" -Method Post -Body $loginBody -ContentType "application/json"
    Write-Host "Login exitoso" -ForegroundColor Green
    
    $headers = @{
        Authorization = "Bearer $token"
    }
    
    $profile = Invoke-RestMethod -Uri "$baseUrl/api/profile" -Method Get -Headers $headers
    
    Write-Host ""
    Write-Host "DATOS DEL PERFIL:" -ForegroundColor Yellow
    Write-Host "PaymentMethodType: $($profile.paymentMethodType)" -ForegroundColor Magenta
    Write-Host "ExpirationDate: $($profile.expirationDate)"
    Write-Host "SecurityCode: $($profile.securityCode)"
    Write-Host "Password: $($profile.password)"
    Write-Host ""
    
    Write-Host "JSON COMPLETO:" -ForegroundColor Cyan
    $profile | ConvertTo-Json -Depth 3
    
} catch {
    Write-Host "Error al verificar" -ForegroundColor Red
}
