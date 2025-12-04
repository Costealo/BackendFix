# Script to execute SQL updates for ani@gmail.com
$connectionString = "Server=tcp:costealoo-srv.database.windows.net,1433;Initial Catalog=costealoo-db;Persist Security Info=False;User ID=costealo;Password=PasswOrd3;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"

Write-Host "Connecting to Azure SQL Database..." -ForegroundColor Cyan

try {
    # Load SQL Client assembly
    Add-Type -AssemblyName "System.Data"
    
    $connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
    $connection.Open()
    Write-Host "Connected successfully!" -ForegroundColor Green
    
    # Update PlainPassword
    Write-Host "`nUpdating PlainPassword..." -ForegroundColor Yellow
    $cmd1 = $connection.CreateCommand()
    $cmd1.CommandText = "UPDATE Users SET PlainPassword = '456789' WHERE Email = 'ani@gmail.com'"
    $rows1 = $cmd1.ExecuteNonQuery()
    Write-Host "Updated $rows1 user(s)" -ForegroundColor Green
    
    # Update Subscription
    Write-Host "`nUpdating Subscription..." -ForegroundColor Yellow
    $cmd2 = $connection.CreateCommand()
    $cmd2.CommandText = @"
UPDATE Subscriptions
SET 
    ExpirationDate = '12/30',
    SecurityCode = '123',
    CardHolderName = 'Ana Garcia',
    PaymentMethodType = 'Tarjeta de crédito'
WHERE UserId = (SELECT Id FROM Users WHERE Email = 'ani@gmail.com')
"@
    $rows2 = $cmd2.ExecuteNonQuery()
    Write-Host "Updated $rows2 subscription(s)" -ForegroundColor Green
    
    # Verify
    Write-Host "`nVerifying updates..." -ForegroundColor Yellow
    $cmd3 = $connection.CreateCommand()
    $cmd3.CommandText = @"
SELECT 
    u.Email,
    u.PlainPassword,
    s.CardLastFourDigits,
    s.ExpirationDate,
    s.SecurityCode,
    s.PaymentMethodType
FROM Users u
INNER JOIN Subscriptions s ON u.Id = s.UserId
WHERE u.Email = 'ani@gmail.com'
"@
    $reader = $cmd3.ExecuteReader()
    
    if ($reader.Read()) {
        Write-Host "`nVerification:" -ForegroundColor Cyan
        Write-Host "Email: $($reader['Email'])"
        Write-Host "PlainPassword: $($reader['PlainPassword'])"
        Write-Host "CardLastFourDigits: $($reader['CardLastFourDigits'])"
        Write-Host "ExpirationDate: $($reader['ExpirationDate'])"
        Write-Host "SecurityCode: $($reader['SecurityCode'])"
        Write-Host "PaymentMethodType: $($reader['PaymentMethodType'])"
    }
    $reader.Close()
    
    $connection.Close()
    Write-Host "`nSUCCESS: All updates completed!" -ForegroundColor Green
    
} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    if ($connection.State -eq 'Open') {
        $connection.Close()
    }
}
