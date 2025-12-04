$ErrorActionPreference = "Stop"

$registerBody = @{
    name = "Prueba User"
    email = "prueba@gmail.com"
    password = "Prueba123!"
    role = 0
} | ConvertTo-Json

try {
    Invoke-RestMethod -Uri "http://localhost:8080/api/Users" -Method Post -Body $registerBody -ContentType "application/json"
    Write-Host "Registration successful. User created."
} catch {
    Write-Host "Registration failed: $_"
}
