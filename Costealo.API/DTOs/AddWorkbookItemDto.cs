using System.ComponentModel.DataAnnotations;

namespace Costealo.API.DTOs;

public class AddWorkbookItemDto
{
    // Optional: Use this for items from price database
    public int? PriceItemId { get; set; }
    
    // Optional: Use these for manual items (when PriceItemId is null)
    public string? ManualItemName { get; set; }
    public decimal? ManualItemPrice { get; set; }
    
    [Required]
    public decimal Quantity { get; set; }
    
    [Required]
    public string Unit { get; set; } = string.Empty;
    
    public decimal AdditionalCost { get; set; }
}
