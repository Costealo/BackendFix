# Execute SQL to fix column type and update value
$connectionString = "Server=tcp:costealoo-srv.database.windows.net,1433;Initial Catalog=costealoo-db;Persist Security Info=False;User ID=costealo;Password=PasswOrd3;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"

Write-Host "Fixing column type and updating value..." -ForegroundColor Cyan

try {
    Add-Type -AssemblyName "System.Data"
    
    $connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
    $connection.Open()
    Write-Host "Connected!" -ForegroundColor Green
    
    # Check current column type
    Write-Host "`nChecking column type..." -ForegroundColor Yellow
    $cmd1 = $connection.CreateCommand()
    $cmd1.CommandText = "SELECT DATA_TYPE, CHARACTER_MAXIMUM_LENGTH FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Subscriptions' AND COLUMN_NAME = 'PaymentMethodType'"
    $reader = $cmd1.ExecuteReader()
    if ($reader.Read()) {
        Write-Host "Current type: $($reader['DATA_TYPE'])($($reader['CHARACTER_MAXIMUM_LENGTH']))" -ForegroundColor Cyan
    }
    $reader.Close()
    
    # Alter column to NVARCHAR
    Write-Host "`nAltering column to NVARCHAR..." -ForegroundColor Yellow
    $cmd2 = $connection.CreateCommand()
    $cmd2.CommandText = "ALTER TABLE Subscriptions ALTER COLUMN PaymentMethodType NVARCHAR(50)"
    $cmd2.ExecuteNonQuery()
    Write-Host "Column altered successfully!" -ForegroundColor Green
    
    # Update with proper accent
    Write-Host "`nUpdating value with accent..." -ForegroundColor Yellow
    $cmd3 = $connection.CreateCommand()
    $cmd3.CommandText = "UPDATE Subscriptions SET PaymentMethodType = N'Tarjeta de crédito' WHERE UserId = (SELECT Id FROM Users WHERE Email = 'ani@gmail.com')"
    $rows = $cmd3.ExecuteNonQuery()
    Write-Host "Updated $rows row(s)" -ForegroundColor Green
    
    # Verify
    Write-Host "`nVerifying..." -ForegroundColor Yellow
    $cmd4 = $connection.CreateCommand()
    $cmd4.CommandText = "SELECT PaymentMethodType FROM Subscriptions WHERE UserId = (SELECT Id FROM Users WHERE Email = 'ani@gmail.com')"
    $result = $cmd4.ExecuteScalar()
    Write-Host "Final value: $result" -ForegroundColor Green
    
    $connection.Close()
    Write-Host "`nSUCCESS!" -ForegroundColor Green
    
} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    if ($connection -and $connection.State -eq 'Open') {
        $connection.Close()
    }
}
