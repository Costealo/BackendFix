$ErrorActionPreference = "Stop"

# 1. Login
$randomId = Get-Random
$email = "prueba_test_$randomId@gmail.com"
$loginBody = @{
    email = $email
    password = "Prueba123!"
} | ConvertTo-Json

$token = $null

try {
    Write-Host "Attempting login with $email..."
    $response = Invoke-RestMethod -Uri "http://localhost:8080/api/Auth/login" -Method Post -Body $loginBody -ContentType "application/json"
    $token = $response
    Write-Host "Login successful. Token obtained."
} catch {
    Write-Host "Login failed. Trying to register..."
    $registerBody = @{
        name = "Prueba User"
        email = $email
        password = "Prueba123!"
        role = 0
    } | ConvertTo-Json
    
    try {
        Invoke-RestMethod -Uri "http://localhost:8080/api/Users" -Method Post -Body $registerBody -ContentType "application/json"
        Write-Host "Registration successful."
        
        # Login again
        $response = Invoke-RestMethod -Uri "http://localhost:8080/api/Auth/login" -Method Post -Body $loginBody -ContentType "application/json"
        $token = $response
        Write-Host "Login successful after registration."
    } catch {
        Write-Error "Registration failed: $_"
    }
}

if ($null -eq $token) {
    Write-Error "Could not obtain token."
}

$headers = @{
    Authorization = "Bearer $token"
}

# 2. Get Subscription
Write-Host "Getting subscription..."
try {
    $sub = Invoke-RestMethod -Uri "http://localhost:8080/api/Subscriptions/me" -Method Get -Headers $headers
    Write-Host "Current ExpirationDate: $($sub.expirationDate)"
} catch {
    Write-Error "Failed to get subscription: $_"
}

# If subscription doesn't exist (id=0 means default free), create one
if ($sub.id -eq 0) {
    Write-Host "Creating new subscription..."
    $createBody = @{
        planType = 1
        cardLastFourDigits = "1234"
        expirationDate = "12/25"
        paymentMethodType = "Tarjeta de débito"
    } | ConvertTo-Json
    
    try {
        $sub = Invoke-RestMethod -Uri "http://localhost:8080/api/Subscriptions" -Method Post -Body $createBody -Headers $headers -ContentType "application/json"
        Write-Host "Created subscription with ExpirationDate: $($sub.expirationDate)"
    } catch {
        Write-Error "Failed to create subscription: $_"
    }
}

# 3. Update Subscription (Always run this to verify persistence on update)
Write-Host "Updating subscription..."
$updateBody = @{
    planType = 1
    isActive = $true
    cardLastFourDigits = "5678"
    expirationDate = "11/28"
    paymentMethodType = "Tarjeta de crédito"
} | ConvertTo-Json

try {
    # Need to get the ID again in case it was just created
    $sub = Invoke-RestMethod -Uri "http://localhost:8080/api/Subscriptions/me" -Method Get -Headers $headers
    
    if ($sub.id -eq 0) {
        Write-Error "Subscription ID is still 0. Cannot update."
    }

    Invoke-RestMethod -Uri "http://localhost:8080/api/Subscriptions/$($sub.id)" -Method Put -Body $updateBody -Headers $headers -ContentType "application/json"
    
    # 4. Verify
    $sub = Invoke-RestMethod -Uri "http://localhost:8080/api/Subscriptions/me" -Method Get -Headers $headers
    Write-Host "Updated ExpirationDate: $($sub.expirationDate)"
    
    if ($sub.expirationDate -eq "11/28") {
        Write-Host "SUCCESS: ExpirationDate persisted correctly."
    } else {
        Write-Error "FAILURE: ExpirationDate did not persist."
    }
} catch {
    Write-Error "Failed to update subscription: $_"
}
