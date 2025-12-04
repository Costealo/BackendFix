using System.ComponentModel.DataAnnotations;

namespace Costealo.API.DTOs;

public class AddPriceItemDto
{
    public string? ExternalId { get; set; }

    [Required]
    public string Product { get; set; } = string.Empty;

    [Required]
    [Range(0.01, double.MaxValue, ErrorMessage = "Price must be greater than zero.")]
    public decimal Price { get; set; }

    [Required]
    public string Unit { get; set; } = string.Empty;
}
