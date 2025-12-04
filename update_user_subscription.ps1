$ErrorActionPreference = "Stop"

# 1. Login
$email = "prueba@gmail.com"
$password = "Prueba123!"

$loginBody = @{
    email = $email
    password = $password
} | ConvertTo-Json

$token = $null

try {
    Write-Host "Attempting login with $email..."
    $response = Invoke-RestMethod -Uri "http://localhost:8080/api/Auth/login" -Method Post -Body $loginBody -ContentType "application/json"
    $token = $response
    Write-Host "Login successful. Token obtained."
} catch {
    Write-Error "Login failed: $_"
}

$headers = @{
    Authorization = "Bearer $token"
}

# 2. Get Subscription
Write-Host "Getting subscription..."
try {
    $sub = Invoke-RestMethod -Uri "http://localhost:8080/api/Subscriptions/me" -Method Get -Headers $headers
    Write-Host "Current Subscription ID: $($sub.id)"
    Write-Host "Current ExpirationDate: $($sub.expirationDate)"
} catch {
    Write-Error "Failed to get subscription: $_"
}

# 3. Create or Update
if ($sub.id -eq 0) {
    Write-Host "Creating new subscription..."
    $createBody = @{
        planType = 1 # Basico
        cardLastFourDigits = "1234"
        expirationDate = "11/28"
        paymentMethodType = "Tarjeta de débito"
    } | ConvertTo-Json
    
    try {
        $sub = Invoke-RestMethod -Uri "http://localhost:8080/api/Subscriptions" -Method Post -Body $createBody -Headers $headers -ContentType "application/json"
        Write-Host "Created subscription with ExpirationDate: $($sub.expirationDate)"
    } catch {
        Write-Error "Failed to create subscription: $_"
    }
} else {
    Write-Host "Updating existing subscription..."
    $updateBody = @{
        planType = 1 # Basico
        isActive = $true
        cardLastFourDigits = "1234"
        expirationDate = "11/28"
        paymentMethodType = "Tarjeta de débito"
    } | ConvertTo-Json

    try {
        Invoke-RestMethod -Uri "http://localhost:8080/api/Subscriptions/$($sub.id)" -Method Put -Body $updateBody -Headers $headers -ContentType "application/json"
        Write-Host "Subscription updated."
        
        # Verify
        $sub = Invoke-RestMethod -Uri "http://localhost:8080/api/Subscriptions/me" -Method Get -Headers $headers
        Write-Host "New ExpirationDate: $($sub.expirationDate)"
    } catch {
        Write-Error "Failed to update subscription: $_"
    }
}
