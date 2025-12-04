# Verify that login does NOT change organization
$baseUrl = "http://localhost:8080"

function Get-Token($email,$password,$org = $null) {
    $body = @{ email = $email; password = $password }
    if ($org) { $body.organization = $org }
    $json = $body | ConvertTo-Json -Depth 2
    try {
        $token = Invoke-RestMethod -Uri "$baseUrl/api/Auth/login" -Method Post -Body $json -ContentType "application/json"
        return $token
    } catch {
        Write-Host "Login error: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

function Get-Profile($token) {
    $headers = @{ Authorization = "Bearer $token" }
    try {
        $profile = Invoke-RestMethod -Uri "$baseUrl/api/profile" -Method Get -Headers $headers
        return $profile
    } catch {
        Write-Host "Profile error: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

$email = "ani@gmail.com"
$password = "456789"

# 1. Baseline: normal login
$token1 = Get-Token $email $password
$profile1 = Get-Profile $token1
Write-Host "Baseline organization: $($profile1.organization)" -ForegroundColor Cyan

# 2. Login with extra organization field (trying to change it)
$token2 = Get-Token $email $password "Independiente"
$profile2 = Get-Profile $token2
Write-Host "After login with org field organization: $($profile2.organization)" -ForegroundColor Cyan

if ($profile1.organization -eq $profile2.organization) {
    Write-Host "✅ Organization unchanged – login does not modify it." -ForegroundColor Green
} else {
    Write-Host "⚠️ Organization changed – issue persists!" -ForegroundColor Red
}
