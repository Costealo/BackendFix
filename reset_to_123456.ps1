$ErrorActionPreference = "Stop"

# Temporarily add password reset endpoint
$code = @'
using Costealo.API.Data;
using Costealo.API.Models;
using Costealo.API.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace Costealo.API.Controllers;

[Route("api/[controller]")]
[ApiController]
public class AuthController : ControllerBase
{
    private readonly IAuthService _authService;
    private readonly ApplicationDbContext _context;

    public AuthController(IAuthService authService, ApplicationDbContext context)
    {
        _authService = authService;
        _context = context;
    }

    // POST: api/Auth/register-first-admin
    [HttpPost("register-first-admin")]
    public async Task<ActionResult<User>> RegisterFirstAdmin(AdminRegistrationDto request)
    {
        // Check if any admin already exists
        if (await _context.Users.AnyAsync(u => u.Role == UserRole.Admin))
        {
            return Forbid("An admin already exists. Use the protected endpoint to create additional admins.");
        }

        var admin = new User
        {
            Name = request.Name,
            Email = request.Email,
            Role = UserRole.Admin
        };

        var result = await _authService.RegisterAsync(admin, request.Password);
        if (result == null)
        {
            return BadRequest("Admin already exists.");
        }

        return Ok(result);
    }

    // POST: api/Auth/register-admin
    [HttpPost("register-admin")]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<User>> RegisterAdmin(AdminRegistrationDto request)
    {
        var admin = new User
        {
            Name = request.Name,
            Email = request.Email,
            Role = UserRole.Admin
        };

        var result = await _authService.RegisterAsync(admin, request.Password);
        if (result == null)
        {
            return BadRequest("Admin already exists.");
        }

        return Ok(result);
    }

    // POST: api/Auth/login
    [HttpPost("login")]
    public async Task<ActionResult<string>> Login(LoginDto request)
    {
        var token = await _authService.LoginAsync(request.Email, request.Password);
        if (token == null)
        {
            return BadRequest("Invalid email or password.");
        }

        return Ok(token);
    }

    // TEMPORARY - Remove after use
    [HttpPost("reset-password-temp")]
    public async Task<IActionResult> ResetPasswordTemp(string email, string newPassword)
    {
        var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == email);
        if (user == null) return NotFound("User not found");

        using (var hmac = new System.Security.Cryptography.HMACSHA512())
        {
            var salt = hmac.Key;
            var hash = hmac.ComputeHash(System.Text.Encoding.UTF8.GetBytes(newPassword));
            user.PasswordHash = Convert.ToBase64String(salt) + "." + Convert.ToBase64String(hash);
        }
        
        await _context.SaveChangesAsync();
        return Ok("Password reset successful");
    }
}

public class AdminRegistrationDto
{
    public string Name { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string Password { get; set; } = string.Empty;
}

public class LoginDto
{
    public string Email { get; set; } = string.Empty;
    public string Password { get; set; } = string.Empty;
}
'@

Set-Content -Path "c:\backend\Costealo-Backend-Oficial-\Costealo.API\Controllers\AuthController.cs" -Value $code

Write-Host "Restarting backend..."
taskkill /F /IM Costealo.API.exe 2>$null
Start-Sleep -Seconds 2

$job = Start-Job -ScriptBlock {
    Set-Location "C:\backend\Costealo-Backend-Oficial-"
    dotnet run --project Costealo.API
}

Start-Sleep -Seconds 8

Write-Host "Resetting password to 123456..."
try {
    Invoke-RestMethod -Uri "http://localhost:8080/api/Auth/reset-password-temp?email=prueba@gmail.com&newPassword=123456" -Method Post
    Write-Host "Password reset successful!"
} catch {
    Write-Error "Failed to reset password: $_"
}

Write-Host "Stopping backend..."
Stop-Job $job
Remove-Job $job
taskkill /F /IM Costealo.API.exe 2>$null

Write-Host "Removing temporary endpoint..."
$code = @'
using Costealo.API.Data;
using Costealo.API.Models;
using Costealo.API.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace Costealo.API.Controllers;

[Route("api/[controller]")]
[ApiController]
public class AuthController : ControllerBase
{
    private readonly IAuthService _authService;
    private readonly ApplicationDbContext _context;

    public AuthController(IAuthService authService, ApplicationDbContext context)
    {
        _authService = authService;
        _context = context;
    }

    // POST: api/Auth/register-first-admin
    [HttpPost("register-first-admin")]
    public async Task<ActionResult<User>> RegisterFirstAdmin(AdminRegistrationDto request)
    {
        // Check if any admin already exists
        if (await _context.Users.AnyAsync(u => u.Role == UserRole.Admin))
        {
            return Forbid("An admin already exists. Use the protected endpoint to create additional admins.");
        }

        var admin = new User
        {
            Name = request.Name,
            Email = request.Email,
            Role = UserRole.Admin
        };

        var result = await _authService.RegisterAsync(admin, request.Password);
        if (result == null)
        {
            return BadRequest("Admin already exists.");
        }

        return Ok(result);
    }

    // POST: api/Auth/register-admin
    [HttpPost("register-admin")]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<User>> RegisterAdmin(AdminRegistrationDto request)
    {
        var admin = new User
        {
            Name = request.Name,
            Email = request.Email,
            Role = UserRole.Admin
        };

        var result = await _authService.RegisterAsync(admin, request.Password);
        if (result == null)
        {
            return BadRequest("Admin already exists.");
        }

        return Ok(result);
    }

    // POST: api/Auth/login
    [HttpPost("login")]
    public async Task<ActionResult<string>> Login(LoginDto request)
    {
        var token = await _authService.LoginAsync(request.Email, request.Password);
        if (token == null)
        {
            return BadRequest("Invalid email or password.");
        }

        return Ok(token);
    }
}

public class AdminRegistrationDto
{
    public string Name { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string Password { get; set; } = string.Empty;
}

public class LoginDto
{
    public string Email { get; set; } = string.Empty;
    public string Password { get; set; } = string.Empty;
}
'@

Set-Content -Path "c:\backend\Costealo-Backend-Oficial-\Costealo.API\Controllers\AuthController.cs" -Value $code

Write-Host "Restarting backend with clean code..."
Start-Process powershell -ArgumentList "-Command", "cd 'C:\backend\Costealo-Backend-Oficial-'; dotnet run --project Costealo.API" -WindowStyle Hidden

Write-Host "Done! Password for prueba@gmail.com is now 123456"
