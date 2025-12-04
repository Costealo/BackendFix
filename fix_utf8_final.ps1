# Execute SQL with proper UTF-8 encoding using .NET SqlCommand
$connectionString = "Server=tcp:costealoo-srv.database.windows.net,1433;Initial Catalog=costealoo-db;Persist Security Info=False;User ID=costealo;Password=PasswOrd3;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"

Write-Host "Fixing UTF-8 encoding issue..." -ForegroundColor Cyan

try {
    # Ensure we're using UTF-8
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    
    Add-Type -AssemblyName "System.Data"
    
    $connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
    $connection.Open()
    Write-Host "Connected to database" -ForegroundColor Green
    
    # Delete the bad value completely
    Write-Host "`nDeleting old value..." -ForegroundColor Yellow
    $cmdDelete = $connection.CreateCommand()
    $cmdDelete.CommandText = @"
UPDATE s
SET s.PaymentMethodType = NULL
FROM Subscriptions s
INNER JOIN Users u ON s.UserId = u.Id
WHERE u.Email = 'ani@gmail.com'
"@
    $cmdDelete.ExecuteNonQuery() | Out-Null
    Write-Host "Old value deleted" -ForegroundColor Green
    
    # Insert new value with proper encoding using parameterized query
    Write-Host "`nInserting new value with proper encoding..." -ForegroundColor Yellow
    $cmdUpdate = $connection.CreateCommand()
    $cmdUpdate.CommandText = @"
UPDATE s
SET s.PaymentMethodType = @paymentMethod
FROM Subscriptions s
INNER JOIN Users u ON s.UserId = u.Id
WHERE u.Email = 'ani@gmail.com'
"@
    
    # Use SqlParameter with explicit NVarChar type
    $param = $cmdUpdate.Parameters.Add("@paymentMethod", [System.Data.SqlDbType]::NVarChar, 50)
    $param.Value = "Tarjeta de crédito"
    
    $rows = $cmdUpdate.ExecuteNonQuery()
    Write-Host "Updated $rows row(s)" -ForegroundColor Green
    
    # Verify by reading back
    Write-Host "`nVerifying..." -ForegroundColor Yellow
    $cmdVerify = $connection.CreateCommand()
    $cmdVerify.CommandText = @"
SELECT s.PaymentMethodType
FROM Subscriptions s
INNER JOIN Users u ON s.UserId = u.Id
WHERE u.Email = 'ani@gmail.com'
"@
    $result = $cmdVerify.ExecuteScalar()
    
    # Convert to bytes to see actual encoding
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($result)
    $hex = ($bytes | ForEach-Object { $_.ToString("X2") }) -join " "
    
    Write-Host "Database value: $result" -ForegroundColor Cyan
    Write-Host "Hex bytes: $hex" -ForegroundColor Gray
    
    # Check if it's correct
    $expected = "Tarjeta de crédito"
    if ($result -eq $expected) {
        Write-Host "`n✓ SUCCESS: Value is correct!" -ForegroundColor Green
    } else {
        Write-Host "`n✗ FAILED: Value is still incorrect" -ForegroundColor Red
        Write-Host "Expected: $expected" -ForegroundColor Yellow
        Write-Host "Got: $result" -ForegroundColor Yellow
    }
    
    $connection.Close()
    
} catch {
    Write-Host "`nERROR: $($_.Exception.Message)" -ForegroundColor Red
    if ($connection -and $connection.State -eq 'Open') {
        $connection.Close()
    }
}

Write-Host "`nNow test the API endpoint /api/profile to verify the fix" -ForegroundColor Cyan
