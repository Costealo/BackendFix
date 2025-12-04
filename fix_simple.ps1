# Execute SQL with proper UTF-8 encoding
$connectionString = "Server=tcp:costealoo-srv.database.windows.net,1433;Initial Catalog=costealoo-db;Persist Security Info=False;User ID=costealo;Password=PasswOrd3;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"

Write-Host "Fixing UTF-8 encoding issue..." -ForegroundColor Cyan

try {
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    
    Add-Type -AssemblyName "System.Data"
    
    $connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
    $connection.Open()
    Write-Host "Connected to database" -ForegroundColor Green
    
    # Delete the bad value
    Write-Host "Deleting old value..." -ForegroundColor Yellow
    $cmdDelete = $connection.CreateCommand()
    $cmdDelete.CommandText = "UPDATE s SET s.PaymentMethodType = NULL FROM Subscriptions s INNER JOIN Users u ON s.UserId = u.Id WHERE u.Email = 'ani@gmail.com'"
    $cmdDelete.ExecuteNonQuery() | Out-Null
    Write-Host "Old value deleted" -ForegroundColor Green
    
    # Insert new value with proper encoding
    Write-Host "Inserting new value..." -ForegroundColor Yellow
    $cmdUpdate = $connection.CreateCommand()
    $cmdUpdate.CommandText = "UPDATE s SET s.PaymentMethodType = @paymentMethod FROM Subscriptions s INNER JOIN Users u ON s.UserId = u.Id WHERE u.Email = 'ani@gmail.com'"
    
    $param = $cmdUpdate.Parameters.Add("@paymentMethod", [System.Data.SqlDbType]::NVarChar, 50)
    $param.Value = "Tarjeta de credito"
    
    $rows = $cmdUpdate.ExecuteNonQuery()
    Write-Host "Updated $rows row(s)" -ForegroundColor Green
    
    # Verify
    $cmdVerify = $connection.CreateCommand()
    $cmdVerify.CommandText = "SELECT s.PaymentMethodType FROM Subscriptions s INNER JOIN Users u ON s.UserId = u.Id WHERE u.Email = 'ani@gmail.com'"
    $result = $cmdVerify.ExecuteScalar()
    
    Write-Host "Database value: $result" -ForegroundColor Cyan
    
    $connection.Close()
    Write-Host "Done!" -ForegroundColor Green
    
} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    if ($connection -and $connection.State -eq 'Open') {
        $connection.Close()
    }
}
