using System.ComponentModel.DataAnnotations;
using Costealo.API.Models;

namespace Costealo.API.DTOs;

public class CreatePriceDatabaseDto
{
    [Required]
    public string Name { get; set; } = string.Empty;
    
    public string? SourceUrl { get; set; }
    
    // Optional: defaults to Draft if not provided
    public EntityStatus? Status { get; set; }
}
