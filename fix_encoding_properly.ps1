# Clear and rewrite with proper encoding
$connectionString = "Server=tcp:costealoo-srv.database.windows.net,1433;Initial Catalog=costealoo-db;Persist Security Info=False;User ID=costealo;Password=PasswOrd3;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"

Write-Host "Fixing encoding properly..." -ForegroundColor Cyan

try {
    Add-Type -AssemblyName "System.Data"
    
    $connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
    $connection.Open()
    
    # First set to NULL to clear bad data
    $cmd1 = $connection.CreateCommand()
    $cmd1.CommandText = "UPDATE Subscriptions SET PaymentMethodType = NULL WHERE UserId = (SELECT Id FROM Users WHERE Email = 'ani@gmail.com')"
    $cmd1.ExecuteNonQuery()
    Write-Host "Cleared old value" -ForegroundColor Yellow
    
    # Now set with proper encoding using SqlParameter
    $cmd2 = $connection.CreateCommand()
    $cmd2.CommandText = "UPDATE Subscriptions SET PaymentMethodType = @value WHERE UserId = (SELECT Id FROM Users WHERE Email = 'ani@gmail.com')"
    
    $param = New-Object System.Data.SqlClient.SqlParameter("@value", [System.Data.SqlDbType]::NVarChar, 50)
    $param.Value = "Tarjeta de crédito"
    $cmd2.Parameters.Add($param) | Out-Null
    
    $rows = $cmd2.ExecuteNonQuery()
    Write-Host "Updated $rows row(s) with proper encoding" -ForegroundColor Green
    
    # Verify
    $cmd3 = $connection.CreateCommand()
    $cmd3.CommandText = "SELECT PaymentMethodType FROM Subscriptions WHERE UserId = (SELECT Id FROM Users WHERE Email = 'ani@gmail.com')"
    $result = $cmd3.ExecuteScalar()
    Write-Host "New value: $result" -ForegroundColor Cyan
    
    $connection.Close()
    Write-Host "Done!" -ForegroundColor Green
    
} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    if ($connection -and $connection.State -eq 'Open') {
        $connection.Close()
    }
}
