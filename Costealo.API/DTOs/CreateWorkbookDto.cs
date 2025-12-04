using System.ComponentModel.DataAnnotations;
using Costealo.API.Models;

namespace Costealo.API.DTOs;

public class CreateWorkbookDto
{
    [Required]
    public string Name { get; set; } = string.Empty;
    
    public decimal ProductionUnits { get; set; } = 1;
    public decimal ProfitMarginPercentage { get; set; } = 0.20m;
    
    public decimal? TargetSalePrice { get; set; }
    
    // Optional: allows setting status as Draft (0) or Published (1) on creation
    public EntityStatus? Status { get; set; }
}

public class UpdateWorkbookDto : CreateWorkbookDto
{
}
