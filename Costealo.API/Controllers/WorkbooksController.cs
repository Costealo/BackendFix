using System.Security.Claims;
using Costealo.API.Data;
using Costealo.API.DTOs;
using Costealo.API.Models;
using Costealo.API.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace Costealo.API.Controllers;

[Authorize]
[ApiController]
[Route("api/[controller]")]
public class WorkbooksController : ControllerBase
{
    private readonly ApplicationDbContext _context;
    private readonly IUnitConversionService _conversionService;
    private readonly ISubscriptionService _subscriptionService;

    public WorkbooksController(ApplicationDbContext context, IUnitConversionService conversionService, ISubscriptionService subscriptionService)
    {
        _context = context;
        _conversionService = conversionService;
        _subscriptionService = subscriptionService;
    }

    // GET: api/workbooks
    [HttpGet]
    public async Task<ActionResult<IEnumerable<WorkbookSummaryDto>>> GetWorkbooks()
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var workbooks = await _context.Workbooks
            .Where(w => w.UserId == userId)
            .Include(w => w.Items)
            .ThenInclude(i => i.PriceItem)
            .OrderByDescending(w => w.CreatedAt)
            .ToListAsync();

        var summaryList = new List<WorkbookSummaryDto>();
        foreach (var workbook in workbooks)
        {
            var details = await CalculateWorkbook(workbook);
            summaryList.Add(new WorkbookSummaryDto
            {
                Id = workbook.Id,
                Name = workbook.Name,
                ProductionUnits = workbook.ProductionUnits,
                CreatedAt = workbook.CreatedAt,
                SellingPrice = details.SuggestedPrice,
                ProfitMargin = details.ActualProfitMargin != 0 ? details.ActualProfitMargin : workbook.ProfitMarginPercentage,
                Status = workbook.Status.ToString()
            });
        }
        return summaryList;
    }

    // GET: api/workbooks/{id}
    [HttpGet("{id}")]
    public async Task<ActionResult<WorkbookDto>> GetWorkbook(int id)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var workbook = await _context.Workbooks
            .Include(w => w.Items)
            .ThenInclude(i => i.PriceItem)
            .FirstOrDefaultAsync(w => w.Id == id && w.UserId == userId);
        if (workbook == null) return NotFound();
        return await CalculateWorkbook(workbook);
    }

    // POST: api/workbooks
    [HttpPost]
    public async Task<ActionResult<Workbook>> CreateWorkbook(CreateWorkbookDto dto)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        if (!await _subscriptionService.CanCreateWorkbook(userId))
        {
            var subscription = await _subscriptionService.GetUserSubscription(userId);
            return BadRequest($"Workbook limit reached for your {subscription.PlanType} plan. Upgrade to create more workbooks.");
        }
        var workbook = new Workbook
        {
            Name = dto.Name,
            ProductionUnits = dto.ProductionUnits,
            ProfitMarginPercentage = dto.ProfitMarginPercentage,
            TargetSalePrice = dto.TargetSalePrice,
            UserId = userId,
            CreatedAt = DateTime.UtcNow,
            Status = EntityStatus.Draft
        };
        _context.Workbooks.Add(workbook);
        await _context.SaveChangesAsync();
        return CreatedAtAction(nameof(GetWorkbook), new { id = workbook.Id }, workbook);
    }

    // PUT: api/workbooks/{id}
    [HttpPut("{id}")]
    public async Task<IActionResult> UpdateWorkbook(int id, UpdateWorkbookDto dto)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var workbook = await _context.Workbooks.FirstOrDefaultAsync(w => w.Id == id && w.UserId == userId);
        if (workbook == null) return NotFound();
        workbook.Name = dto.Name;
        workbook.ProductionUnits = dto.ProductionUnits;
        workbook.ProfitMarginPercentage = dto.ProfitMarginPercentage;
        workbook.TargetSalePrice = dto.TargetSalePrice;
        await _context.SaveChangesAsync();
        return NoContent();
    }

    // DELETE: api/workbooks/{id}
    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteWorkbook(int id)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var workbook = await _context.Workbooks.FirstOrDefaultAsync(w => w.Id == id && w.UserId == userId);
        if (workbook == null) return NotFound();
        _context.Workbooks.Remove(workbook);
        await _context.SaveChangesAsync();
        return NoContent();
    }

    // PUT: api/workbooks/{id}/publish
    [HttpPut("{id}/publish")]
    public async Task<IActionResult> PublishWorkbook(int id)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var workbook = await _context.Workbooks.FirstOrDefaultAsync(w => w.Id == id && w.UserId == userId);
        if (workbook == null) return NotFound();
        workbook.Status = EntityStatus.Published;
        await _context.SaveChangesAsync();
        return NoContent();
    }

    // POST: api/workbooks/{id}/items
    [HttpPost("{id}/items")]
    public async Task<ActionResult<WorkbookItem>> AddItem(int id, AddWorkbookItemDto dto)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var workbook = await _context.Workbooks.FirstOrDefaultAsync(w => w.Id == id && w.UserId == userId);
        if (workbook == null) return NotFound();
        var priceItem = await _context.PriceItems
            .Include(p => p.PriceDatabase)
            .FirstOrDefaultAsync(p => p.Id == dto.PriceItemId);
        if (priceItem == null) return BadRequest("Price item not found.");
        if (priceItem.PriceDatabase == null || priceItem.PriceDatabase.UserId != userId) return Forbid("You do not have access to this price item.");
        var item = new WorkbookItem
        {
            WorkbookId = id,
            PriceItemId = dto.PriceItemId,
            Quantity = dto.Quantity,
            Unit = dto.Unit,
            AdditionalCost = dto.AdditionalCost
        };
        _context.WorkbookItems.Add(item);
        await _context.SaveChangesAsync();
        return CreatedAtAction(nameof(GetWorkbook), new { id = id }, item);
    }

    // DELETE: api/workbooks/{id}/items/{itemId}
    [HttpDelete("{id}/items/{itemId}")]
    public async Task<IActionResult> RemoveItem(int id, int itemId)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var workbook = await _context.Workbooks.FirstOrDefaultAsync(w => w.Id == id && w.UserId == userId);
        if (workbook == null) return NotFound();
        var item = await _context.WorkbookItems.FirstOrDefaultAsync(i => i.Id == itemId && i.WorkbookId == id);
        if (item == null) return NotFound();
        _context.WorkbookItems.Remove(item);
        await _context.SaveChangesAsync();
        return NoContent();
    }

    // --- Calculation Logic ---
    private async Task<WorkbookDto> CalculateWorkbook(Workbook workbook)
    {
        var dto = new WorkbookDto
        {
            Id = workbook.Id,
            Name = workbook.Name,
            ProductionUnits = workbook.ProductionUnits,
            ProfitMarginPercentage = workbook.ProfitMarginPercentage,
            TargetSalePrice = workbook.TargetSalePrice
        };
        decimal totalProductionCost = 0;
        decimal totalAdditionalCost = 0;
        decimal totalWeight = 0;
        foreach (var item in workbook.Items)
        {
            var itemDto = new WorkbookItemDto
            {
                Id = item.Id,
                PriceItemId = item.PriceItemId,
                ProductName = item.PriceItem?.Product,
                OriginalPrice = item.PriceItem?.Price,
                OriginalUnit = item.PriceItem?.Unit,
                QuantityUsed = item.Quantity,
                UnitUsed = item.Unit,
                AdditionalCost = item.AdditionalCost
            };
            string conversionMsg = "";
            if (item.PriceItem != null && !string.Equals(item.Unit, item.PriceItem.Unit, StringComparison.OrdinalIgnoreCase))
            {
                var factor = await _conversionService.ConvertAsync(1, item.PriceItem.Unit, item.Unit);
                if (factor.HasValue && factor.Value != 0)
                {
                    decimal pricePerItemUnit = item.PriceItem.Price / factor.Value;
                    itemDto.CalculatedCost = (pricePerItemUnit * item.Quantity) + item.AdditionalCost;
                    conversionMsg = $"Converted 1 {item.PriceItem.Unit} to {factor.Value} {item.Unit}";
                }
                else
                {
                    itemDto.CalculatedCost = (item.PriceItem.Price * item.Quantity) + item.AdditionalCost;
                    conversionMsg = "Conversion failed, assumed 1:1";
                }
            }
            else if (item.PriceItem != null)
            {
                itemDto.CalculatedCost = (item.PriceItem.Price * item.Quantity) + item.AdditionalCost;
                conversionMsg = "Same unit, direct calculation";
            }
            else
            {
                itemDto.CalculatedCost = item.AdditionalCost;
                conversionMsg = "No PriceItem, using manual cost";
            }
            itemDto.ConversionMessage = conversionMsg;
            dto.Items.Add(itemDto);
            totalProductionCost += (itemDto.CalculatedCost - item.AdditionalCost);
            totalAdditionalCost += item.AdditionalCost;
            var weightInGrams = await _conversionService.ConvertAsync(item.Quantity, item.Unit, "gram");
            if (weightInGrams.HasValue) totalWeight += weightInGrams.Value;
        }
        dto.TotalWeight = totalWeight;
        dto.UnitWeight = workbook.ProductionUnits > 0 ? totalWeight / workbook.ProductionUnits : 0;
        dto.ProductionCost = totalProductionCost;
        dto.AdditionalCost = totalAdditionalCost;
        dto.OperationalCost = ((totalProductionCost + totalAdditionalCost) * workbook.OperationalCostPercentage) + workbook.OperationalCostFixed;
        dto.SubtotalCost = totalProductionCost + totalAdditionalCost + dto.OperationalCost;
        dto.TaxAmount = dto.SubtotalCost * workbook.TaxPercentage;
        dto.TotalCost = dto.SubtotalCost + dto.TaxAmount;
        dto.UnitCost = workbook.ProductionUnits > 0 ? dto.TotalCost / workbook.ProductionUnits : 0;
        dto.SuggestedPrice = dto.UnitCost * (1 + workbook.ProfitMarginPercentage);
        if (workbook.TargetSalePrice.HasValue && workbook.TargetSalePrice.Value > 0)
        {
            if (dto.UnitCost > 0)
                dto.ActualProfitMargin = (workbook.TargetSalePrice.Value / dto.UnitCost) - 1;
            else
                dto.ActualProfitMargin = 1;
        }
        return dto;
    }
}
