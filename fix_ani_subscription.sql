-- Fix ani@gmail.com subscription data
-- Run this in your database to populate the missing fields

UPDATE Subscriptions
SET 
    ExpirationDate = '12/30',
    SecurityCode = '123',
    CardHolderName = 'Ana Garcia',
    PaymentMethodType = 'Tarjeta de crédito'
WHERE UserId = (SELECT Id FROM Users WHERE Email = 'ani@gmail.com');

-- Verify the update
SELECT 
    u.Email,
    s.CardLastFourDigits,
    s.ExpirationDate,
    s.SecurityCode,
    s.PaymentMethodType
FROM Users u
INNER JOIN Subscriptions s ON u.Id = s.UserId
WHERE u.Email = 'ani@gmail.com';
