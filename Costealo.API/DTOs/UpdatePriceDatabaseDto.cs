using System.ComponentModel.DataAnnotations;
using Costealo.API.Models;

namespace Costealo.API.DTOs;

public class UpdatePriceDatabaseDto
{
    public int Id { get; set; }

    [Required]
    public string Name { get; set; } = string.Empty;

    public int UserId { get; set; }
    
    // Optional: allows changing status between Draft (0) and Published (1)
    public EntityStatus? Status { get; set; }
}
