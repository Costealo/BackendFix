# Script to verify registration with aliases
$baseUrl = "http://localhost:8080"
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$email = "aliasuser_$timestamp@test.com"
$password = "123456"

Write-Host "Registering user with aliases: $email" -ForegroundColor Cyan

# Register with aliases (cvv, expiryDate)
$registerBody = @{
    name = "Alias User"
    email = $email
    password = $password
    role = 0
    planType = 1
    cardLastFourDigits = "9999"
    cardHolderName = "Alias User Holder"
    paymentMethodType = "Tarjeta de crédito"
    
    # Using aliases
    expiryDate = "01/30"
    cvv = "555"
} | ConvertTo-Json

try {
    $reg = Invoke-RestMethod -Uri "$baseUrl/api/Users" -Method Post -Body $registerBody -ContentType "application/json"
    Write-Host "Registered. ID: $($reg.id)" -ForegroundColor Green
} catch {
    Write-Host "Registration Failed: $($_.Exception.Message)" -ForegroundColor Red
    
    if ($_.Exception.Response) {
        $stream = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($stream)
        Write-Host "Response: $($reader.ReadToEnd())" -ForegroundColor Red
    }
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
    Write-Host "Token obtained" -ForegroundColor Green
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
    
    Write-Host "ExpirationDate: $($profile.expirationDate)"
    Write-Host "SecurityCode: $($profile.securityCode)"
    
    if ($profile.securityCode -eq "555" -and $profile.expirationDate -eq "01/30") {
        Write-Host "SUCCESS: Aliases worked!" -ForegroundColor Green
    } else {
        Write-Host "FAILURE: Aliases did NOT work!" -ForegroundColor Red
    }
} catch {
    Write-Host "Get Profile Failed: $($_.Exception.Message)" -ForegroundColor Red
    exit
}
