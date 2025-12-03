using Costealo.API.Models;

namespace Costealo.API.DTOs;

public class ProfileDto
{
    // Personal Information
    public string UserName { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    
    // DEMO ONLY: Plain text password for university demo
    public string? Password { get; set; }
    
    // Organization type (Empresa or Independiente)
    public string Organization { get; set; } = string.Empty;

    // Payment Information
    public string? PaymentMethodType { get; set; }
    public string? CardLastFourDigits { get; set; }
    public string? ExpirationDate { get; set; }
    public string? SecurityCode { get; set; } // Will likely be "***" or null as we don't store it

    // Subscription Information
    public SubscriptionPlan PlanType { get; set; }
    public DateTime StartDate { get; set; }
    public DateTime? EndDate { get; set; }
    public bool IsActive { get; set; }
    public int MaxWorkbooks { get; set; }
    public int MaxDatabases { get; set; }
}
