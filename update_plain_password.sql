-- Update PlainPassword for demo user
-- Run this in SQL Server Management Studio or Azure Data Studio

UPDATE Users 
SET PlainPassword = '123456' 
WHERE Email = 'prueba@gmail.com';

-- Verify the update
SELECT Id, Name, Email, PlainPassword 
FROM Users 
WHERE Email = 'prueba@gmail.com';
