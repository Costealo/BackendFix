# Script to verify if Login endpoint updates user role
$baseUrl = "http://localhost:8080"
$email = "ani@gmail.com"
$password = "456789"

Write-Host "=== VERIFICACION DE LOGIN ===" -ForegroundColor Cyan

# 1. Check Initial Role
Write-Host "1. Verificando rol inicial..." -ForegroundColor Gray

$loginBody = @{ email = $email; password = $password } | ConvertTo-Json
try {
    $tokenResponse = Invoke-RestMethod -Uri "$baseUrl/api/Auth/login" -Method Post -Body $loginBody -ContentType "application/json"
    if ($tokenResponse.token) { $token = $tokenResponse.token } else { $token = $tokenResponse }
    $headers = @{ Authorization = "Bearer $token" }
    
    $profile = Invoke-RestMethod -Uri "$baseUrl/api/profile" -Method Get -Headers $headers
    Write-Host "Rol Inicial en DB: $($profile.organization)" -ForegroundColor Yellow
    $initialOrg = $profile.organization
} catch {
    Write-Host "Error getting initial profile: $($_.Exception.Message)" -ForegroundColor Red; exit
}

# 2. Attempt Login with DIFFERENT Organization
$targetOrg = "Independiente"
if ($initialOrg -eq "Independiente") { $targetOrg = "Empresa" }

Write-Host "`n2. Intentando login enviando organizacion: $targetOrg" -ForegroundColor Cyan

$roleVal = 1
if ($targetOrg -eq "Empresa") { $roleVal = 0 }

$maliciousLoginBody = @{
    email = $email
    password = $password
    organization = $targetOrg
    role = $roleVal
    userRole = $roleVal
} | ConvertTo-Json

Write-Host "JSON enviado:" -ForegroundColor Gray
Write-Host $maliciousLoginBody -ForegroundColor Gray

try {
    $tokenResponse2 = Invoke-RestMethod -Uri "$baseUrl/api/Auth/login" -Method Post -Body $maliciousLoginBody -ContentType "application/json"
    Write-Host "Login 'malicioso' exitoso" -ForegroundColor Green
} catch {
    Write-Host "Error en login malicioso: $($_.Exception.Message)" -ForegroundColor Red; exit
}

# 3. Check Role Again
Write-Host "`n3. Verificando rol despues del login..." -ForegroundColor Gray
try {
    if ($tokenResponse2.token) { $token2 = $tokenResponse2.token } else { $token2 = $tokenResponse2 }
    $headers2 = @{ Authorization = "Bearer $token2" }
    
    $profileAfter = Invoke-RestMethod -Uri "$baseUrl/api/profile" -Method Get -Headers $headers2
    Write-Host "Rol Final en DB: $($profileAfter.organization)" -ForegroundColor Yellow
    
    if ($profileAfter.organization -eq $initialOrg) {
        Write-Host "`nCORRECTO: El rol NO cambio." -ForegroundColor Green
    } else {
        Write-Host "`nFALLO CRITICO: El rol CAMBIO de '$initialOrg' a '$($profileAfter.organization)'" -ForegroundColor Red
    }
} catch {
    Write-Host "Error getting final profile: $($_.Exception.Message)" -ForegroundColor Red; exit
}
