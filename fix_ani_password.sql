-- Fix ani@gmail.com plain password
-- Run this in your database to populate the PlainPassword field

UPDATE Users
SET PlainPassword = '456789'
WHERE Email = 'ani@gmail.com';

-- Verify the update
SELECT Id, Name, Email, PlainPassword
FROM Users
WHERE Email = 'ani@gmail.com';
