$baseUrl = "http://localhost:8080"
$loginBody = @{ email = "emma@gmail.com"; password = "123456" } | ConvertTo-Json
$token = Invoke-RestMethod -Uri "$baseUrl/api/Auth/login" -Method Post -Body $loginBody -ContentType "application/json"
$headers = @{ Authorization = "Bearer $token" }

# Get Subscription ID
$sub = Invoke-RestMethod -Uri "$baseUrl/api/Subscriptions/me" -Method Get -Headers $headers
# If deactivated, /me might return default free plan (fake). We need to find the real one.
# But we know the ID is 20. Let's try to fetch it directly if we can, or just assume 20.
# Actually, let's just use ID 20 directly as we found it earlier.
$subId = 20

Write-Host "Updating Plan for Subscription $subId..."
# We must send isActive = true to reactivate it
$updateBody = @{ planType = 2; isActive = $true } | ConvertTo-Json
Invoke-RestMethod -Uri "$baseUrl/api/Subscriptions/$subId" -Method Put -Headers $headers -Body $updateBody -ContentType "application/json"

# Verify
$profile = Invoke-RestMethod -Uri "$baseUrl/api/profile" -Method Get -Headers $headers
Write-Host "PlanType: $($profile.planType)"
Write-Host "MaxWorkbooks: $($profile.maxWorkbooks)"
Write-Host "MaxDatabases: $($profile.maxDatabases)"
Write-Host "IsActive: $($profile.isActive)"
