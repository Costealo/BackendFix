# Script to update PlainPassword for demo user
# This will set the PlainPassword field so /api/profile returns the real password

$baseUrl = "http://localhost:8080"

# Login credentials
$email = "prueba@gmail.com"
$password = "123456"

Write-Host "Updating PlainPassword for user: $email" -ForegroundColor Cyan

# First, login to get the token
$loginBody = @{
    email = $email
    password = $password
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "$baseUrl/api/Auth/login" -Method Post -Body $loginBody -ContentType "application/json"
    $token = $loginResponse
    Write-Host "✓ Token obtained successfully" -ForegroundColor Green
} catch {
    Write-Host "✗ Login failed. Make sure the backend is running and credentials are correct." -ForegroundColor Red
    exit
}

# Now we need to update the User's PlainPassword field directly in the database
# Since there's no API endpoint to update PlainPassword, we'll use a SQL script

Write-Host "`nTo update the PlainPassword field, run this SQL command in your database:" -ForegroundColor Yellow
Write-Host @"

UPDATE Users 
SET PlainPassword = '123456' 
WHERE Email = 'prueba@gmail.com';

"@ -ForegroundColor White

Write-Host "`nOr you can use this PowerShell command to execute it directly:" -ForegroundColor Yellow
Write-Host @"

# Using SQL Server connection (adjust connection string as needed)
`$connectionString = "Server=localhost;Database=CostealoDb;Integrated Security=True;TrustServerCertificate=True"
`$connection = New-Object System.Data.SqlClient.SqlConnection(`$connectionString)
`$connection.Open()
`$command = `$connection.CreateCommand()
`$command.CommandText = "UPDATE Users SET PlainPassword = '123456' WHERE Email = 'prueba@gmail.com'"
`$rowsAffected = `$command.ExecuteNonQuery()
`$connection.Close()
Write-Host "Updated `$rowsAffected user(s)" -ForegroundColor Green

"@ -ForegroundColor White

Write-Host "`nAfter updating, test the profile endpoint:" -ForegroundColor Cyan
Write-Host "GET $baseUrl/api/profile" -ForegroundColor White
Write-Host "`nYou should see: `"password`": `"123456`"" -ForegroundColor Green
