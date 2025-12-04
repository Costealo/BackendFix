# Fix by using simple text without accents
$connectionString = "Server=tcp:costealoo-srv.database.windows.net,1433;Initial Catalog=costealoo-db;Persist Security Info=False;User ID=costealo;Password=PasswOrd3;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"

Write-Host "Updating to simple text..." -ForegroundColor Cyan

try {
    Add-Type -AssemblyName "System.Data"
    
    $connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
    $connection.Open()
    
    # Update to simple text
    $cmd = $connection.CreateCommand()
    $cmd.CommandText = "UPDATE Subscriptions SET PaymentMethodType = 'Tarjeta de credito' WHERE UserId = (SELECT Id FROM Users WHERE Email = 'ani@gmail.com')"
    $rows = $cmd.ExecuteNonQuery()
    Write-Host "Updated $rows row(s)" -ForegroundColor Green
    
    # Verify
    $cmd2 = $connection.CreateCommand()
    $cmd2.CommandText = "SELECT PaymentMethodType FROM Subscriptions WHERE UserId = (SELECT Id FROM Users WHERE Email = 'ani@gmail.com')"
    $result = $cmd2.ExecuteScalar()
    Write-Host "New value: $result" -ForegroundColor Yellow
    
    $connection.Close()
    Write-Host "Done!" -ForegroundColor Green
    
} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    if ($connection -and $connection.State -eq 'Open') {
        $connection.Close()
    }
}
