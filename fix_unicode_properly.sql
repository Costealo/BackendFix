-- Delete and reinsert with proper UTF-8 encoding
-- Run this SQL script directly in Azure Data Studio or SQL Server Management Studio

-- First, check what we have
SELECT 
    u.Email,
    s.PaymentMethodType,
    CAST(s.PaymentMethodType AS VARBINARY(MAX)) as HexValue
FROM Users u
INNER JOIN Subscriptions s ON u.Id = s.UserId
WHERE u.Email = 'ani@gmail.com';

-- Update using proper Unicode literal (N prefix)
UPDATE s
SET s.PaymentMethodType = N'Tarjeta de crédito'
FROM Subscriptions s
INNER JOIN Users u ON s.UserId = u.Id
WHERE u.Email = 'ani@gmail.com';

-- Verify the fix
SELECT 
    u.Email,
    s.PaymentMethodType
FROM Users u
INNER JOIN Subscriptions s ON u.Id = s.UserId
WHERE u.Email = 'ani@gmail.com';
