using System.Security.Claims;
using Costealo.API.Data;
using Costealo.API.DTOs;
using Costealo.API.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace Costealo.API.Controllers;

[Route("api/[controller]")]
[ApiController]
[Authorize]
public class ProfileController : ControllerBase
{
    private readonly ApplicationDbContext _context;

    public ProfileController(ApplicationDbContext context)
    {
        _context = context;
    }

    // GET: api/profile
    [HttpGet]
    public async Task<ActionResult<ProfileDto>> GetProfile()
    {
        var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier);
        if (userIdClaim == null)
        {
            return Unauthorized();
        }

        if (!int.TryParse(userIdClaim.Value, out int userId))
        {
            return BadRequest("Invalid user ID in token.");
        }

        var user = await _context.Users.FindAsync(userId);
        if (user == null)
        {
            return NotFound("User not found.");
        }

        // Get the active subscription for the user
        // Assuming one active subscription per user, or taking the latest one
        var subscription = await _context.Subscriptions
            .Where(s => s.UserId == userId && s.IsActive)
            .OrderByDescending(s => s.StartDate)
            .FirstOrDefaultAsync();

        // If no subscription found, create a default "Free" view or handle accordingly
        // For now, we'll assume every user should have a subscription (even if free) 
        // or we return nulls for subscription data if missing.
        // However, the requirements imply we should return plan info. 
        // If the user doesn't have a subscription record, we might want to return a default Free plan structure 
        // or just nulls. Let's return what we have.

        var profileDto = new ProfileDto
        {
            UserName = user.Name,
            Email = user.Email,
            
            // DEMO ONLY: Return plain text password for university demo
            Password = user.PlainPassword,
            
            // Organization type from user role
            Organization = user.Role.ToString(),
            
            // Payment Info from Subscription
            PaymentMethodType = subscription?.PaymentMethodType,
            CardLastFourDigits = subscription?.CardLastFourDigits,
            ExpirationDate = subscription?.ExpirationDate,
            
            // DEMO ONLY: Return real security code from database for university demo
            SecurityCode = subscription?.SecurityCode,

            // Subscription Info
            PlanType = subscription?.PlanType ?? SubscriptionPlan.Free,
            StartDate = subscription?.StartDate ?? DateTime.MinValue,
            EndDate = subscription?.EndDate,
            IsActive = subscription?.IsActive ?? false,
            MaxWorkbooks = subscription?.MaxWorkbooks ?? 5, // Default to Free limits if no sub
            MaxDatabases = subscription?.MaxDatabases ?? 1   // Default to Free limits if no sub
        };

        return Ok(profileDto);
    }
}
