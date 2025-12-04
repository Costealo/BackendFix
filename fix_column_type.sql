-- Check and fix column type for PaymentMethodType
-- This will ensure proper UTF-8/Unicode support

-- First, check current column type
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Subscriptions' 
AND COLUMN_NAME = 'PaymentMethodType';

-- If it's VARCHAR, we need to change it to NVARCHAR
-- Alter the column to NVARCHAR to support Unicode characters
ALTER TABLE Subscriptions
ALTER COLUMN PaymentMethodType NVARCHAR(50);

-- Now update with proper accent
UPDATE Subscriptions 
SET PaymentMethodType = N'Tarjeta de crédito'
WHERE UserId = (SELECT Id FROM Users WHERE Email = 'ani@gmail.com');

-- Verify
SELECT PaymentMethodType 
FROM Subscriptions 
WHERE UserId = (SELECT Id FROM Users WHERE Email = 'ani@gmail.com');
