using IzmirimCard.Api.Data;
using IzmirimCard.Api.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;

namespace IzmirimCard.Api.Controllers
{
    [Authorize]
    [Route("api/[controller]")]
    [ApiController]
    public class WalletController : ControllerBase
    {
        private readonly AppDbContext _context;

        public WalletController(AppDbContext context)
        {
            _context = context;
        }

        private string GetUserId() => User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "";

        [HttpGet("balance")]
        public async Task<IActionResult> GetBalance()
        {
            var userId = GetUserId();
            var user = await _context.Users.FirstOrDefaultAsync(u => u.CardId == userId);
            if (user == null) return NotFound();

            return Ok(new { balance = user.Balance });
        }

        [HttpPost("topup")]
        public async Task<IActionResult> TopUp([FromBody] TopUpRequest request)
        {
            var userId = GetUserId();
            var user = await _context.Users.FirstOrDefaultAsync(u => u.CardId == userId);
            if (user == null) return NotFound();

            user.Balance += request.Amount;
            
            _context.Transactions.Add(new Transaction
            {
                CardId = userId,
                Amount = request.Amount,
                TransactionType = "TOPUP"
            });

            await _context.SaveChangesAsync();
            return Ok(new { message = "Bakiye yüklendi", newBalance = user.Balance });
        }

        [HttpPost("pass")]
        public async Task<IActionResult> Pass()
        {
            var userId = GetUserId();
            var user = await _context.Users.FirstOrDefaultAsync(u => u.CardId == userId);
            if (user == null) return NotFound();

            double requiredAmount = user.UserType switch
            {
                "Tam" => 35.0,
                "Öğrenci" => 17.5,
                "Öğretmen" => 25.0,
                "Emekli" => 0.0,
                _ => 35.0
            };

            if (user.Balance < requiredAmount)
                return BadRequest(new { message = "Yetersiz bakiye", requiredAmount = requiredAmount });

            user.Balance -= requiredAmount;

            _context.Transactions.Add(new Transaction
            {
                CardId = userId,
                Amount = requiredAmount,
                TransactionType = "PASS"
            });

            await _context.SaveChangesAsync();
            return Ok(new { message = "Geçiş başarılı", deductedAmount = requiredAmount });
        }

        [HttpGet("history")]
        public async Task<IActionResult> GetHistory()
        {
            var userId = GetUserId();
            var history = await _context.Transactions
                .Where(t => t.CardId == userId)
                .OrderByDescending(t => t.Date)
                .Take(20)
                .ToListAsync();

            return Ok(history);
        }
    }

    public class TopUpRequest
    {
        public double Amount { get; set; }
    }
}