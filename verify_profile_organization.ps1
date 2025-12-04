# Script to verify profile organization field

$baseUrl = "http://localhost:8080"
$email = "prueba@gmail.com"
$password = "123456"

Write-Host "Verifying Profile Organization Field..." -ForegroundColor Cyan

# Login
$loginBody = @{
    email = $email
    password = $password
} | ConvertTo-Json

$loginResponse = Invoke-RestMethod -Uri "$baseUrl/api/Auth/login" -Method Post -Body $loginBody -ContentType "application/json"
$token = $loginResponse
Write-Host "Logged in successfully" -ForegroundColor Green

# Get Profile
$headers = @{
    Authorization = "Bearer $token"
}

$profile = Invoke-RestMethod -Uri "$baseUrl/api/profile" -Method Get -Headers $headers

Write-Host "Profile Response:" -ForegroundColor Yellow
$profile | ConvertTo-Json -Depth 3
