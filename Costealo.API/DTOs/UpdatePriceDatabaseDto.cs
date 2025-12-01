using System.ComponentModel.DataAnnotations;

namespace Costealo.API.DTOs;

public class UpdatePriceDatabaseDto
{
    public int Id { get; set; }

    [Required]
    public string Name { get; set; } = string.Empty;

    public int UserId { get; set; }
}
