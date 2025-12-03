using System.ComponentModel.DataAnnotations;

namespace Costealo.API.Models;

public class User
{
    [Key]
    public int Id { get; set; }

    [Required]
    [MaxLength(100)]
    public string Name { get; set; } = string.Empty;

    [Required]
    [EmailAddress]
    public string Email { get; set; } = string.Empty;

    [Required]
    public string PasswordHash { get; set; } = string.Empty;

    // DEMO ONLY: Plain text password for university demo
    // WARNING: Never use in production!
    public string? PlainPassword { get; set; }

    [Required]
    public UserRole Role { get; set; }
}
