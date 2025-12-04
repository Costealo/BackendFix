# Fix encoding - Direct SQL approach
$connectionString = "Server=tcp:costealoo-srv.database.windows.net,1433;Initial Catalog=costealoo-db;Persist Security Info=False;User ID=costealo;Password=PasswOrd3;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"

Write-Host "Fixing PaymentMethodType encoding..." -ForegroundColor Cyan

try {
    Add-Type -AssemblyName "System.Data"
    
    $connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
    $connection.Open()
    
    # First, let's see what's currently stored
    $cmd1 = $connection.CreateCommand()
    $cmd1.CommandText = "SELECT PaymentMethodType, CONVERT(VARBINARY(MAX), PaymentMethodType) as HexValue FROM Subscriptions WHERE UserId = (SELECT Id FROM Users WHERE Email = 'ani@gmail.com')"
    $reader = $cmd1.ExecuteReader()
    if ($reader.Read()) {
        Write-Host "Current value: $($reader['PaymentMethodType'])" -ForegroundColor Yellow
    }
    $reader.Close()
    
    # Update - replace the bad text with good text
    $cmd2 = $connection.CreateCommand()
    $cmd2.CommandText = @"
UPDATE Subscriptions 
SET PaymentMethodType = REPLACE(PaymentMethodType, 'Tarjeta de crÃ©dito', 'Tarjeta de credito')
WHERE UserId = (SELECT Id FROM Users WHERE Email = 'ani@gmail.com')
"@
    $rows = $cmd2.ExecuteNonQuery()
    Write-Host "Updated $rows row(s)" -ForegroundColor Green
    
    # Verify
    $cmd3 = $connection.CreateCommand()
    $cmd3.CommandText = "SELECT PaymentMethodType FROM Subscriptions WHERE UserId = (SELECT Id FROM Users WHERE Email = 'ani@gmail.com')"
    $newValue = $cmd3.ExecuteScalar()
    Write-Host "New value: $newValue" -ForegroundColor Green
    
    $connection.Close()
    
} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    if ($connection -and $connection.State -eq 'Open') {
        $connection.Close()
    }
}
