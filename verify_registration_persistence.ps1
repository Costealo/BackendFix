# Script to verify registration persistence
$baseUrl = "http://localhost:8080"
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$email = "newuser_$timestamp@test.com"
$password = "123456"

Write-Host "Registering user: $email" -ForegroundColor Cyan

# Register
$registerBody = @{
    name = "Test User"
    email = $email
    password = $password
    role = 0
    planType = 1
    cardLastFourDigits = "8888"
    cardHolderName = "Test User Holder"
    expirationDate = "12/30"
    paymentMethodType = "Tarjeta de crédito"
    securityCode = "777"
} | ConvertTo-Json

try {
    $reg = Invoke-RestMethod -Uri "$baseUrl/api/Users" -Method Post -Body $registerBody -ContentType "application/json"
    Write-Host "Registered. ID: $($reg.id)" -ForegroundColor Green
} catch {
    Write-Host "Registration Failed: $($_.Exception.Message)" -ForegroundColor Red
    exit
}

# Login
Write-Host "Logging in..." -ForegroundColor Cyan
$loginBody = @{
    email = $email
    password = $password
} | ConvertTo-Json

try {
    $token = Invoke-RestMethod -Uri "$baseUrl/api/Auth/login" -Method Post -Body $loginBody -ContentType "application/json"
    Write-Host "Token obtained (length: $($token.Length))" -ForegroundColor Green
} catch {
    Write-Host "Login Failed: $($_.Exception.Message)" -ForegroundColor Red
    exit
}

# Get Profile
Write-Host "Getting Profile..." -ForegroundColor Cyan
$headers = @{
    Authorization = "Bearer $token"
}

try {
    $profile = Invoke-RestMethod -Uri "$baseUrl/api/profile" -Method Get -Headers $headers
    Write-Host "Profile retrieved." -ForegroundColor Green
    
    # Check fields
    Write-Host "CardLastFourDigits: $($profile.cardLastFourDigits)"
    Write-Host "ExpirationDate: $($profile.expirationDate)"
    Write-Host "SecurityCode: $($profile.securityCode)"
    Write-Host "Organization: $($profile.organization)"
    
    if ($profile.securityCode -eq "777") {
        Write-Host "SUCCESS: SecurityCode persisted!" -ForegroundColor Green
    } else {
        Write-Host "FAILURE: SecurityCode NOT persisted!" -ForegroundColor Red
    }
} catch {
    Write-Host "Get Profile Failed: $($_.Exception.Message)" -ForegroundColor Red
    exit
}
